//
//  YPBleManager.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPBleManager.h"

#import "YPBleDevice.h"
#import "YPBleConst.h"

#import "CoreBluetooth+YPExtension.h"
#import "NSData+YPHexString.h"

@implementation YPBleConfiguration

- (instancetype)init {
    self = [super init];
    if (self) { [self setup]; }
    return self;
}

- (void)setup {
    _services = nil;
    
    _RSSIValue = MAX_RSSI_VALUE;
    
    _localName = nil;
    _mac = nil;
    
//    self.unnamedIntercept = YES;
//    self.withoutDataIntercept = YES;
//    self.ignoreLocalNames = nil;
}

- (BOOL)filterUsingPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    if (abs(RSSI.intValue) > self.RSSIValue) { return NO; }
    if (self.unnamedIntercept && peripheral.name == nil) { return NO; }
    
    AdvertisementDataHelper * helper = [[AdvertisementDataHelper alloc] initWithAdvertisementData:advertisementData];
    
    NSString * localName = helper.localName;
    if (self.localName && self.localName.length > 0) {
        if (![localName localizedCaseInsensitiveContainsString:localName]) return NO;
    }
    
    if (self.ignoreLocalNames && self.ignoreLocalNames.count > 0 && localName) {
        for (NSString * ignoreLocalName in self.ignoreLocalNames) {
            if ([localName localizedCaseInsensitiveContainsString:ignoreLocalName]) return NO;
        }
    }
    
    if (self.withoutDataIntercept && helper.manufacturerData == nil && ![advertisementData.allKeys containsObject:CBAdvertisementDataServiceDataKey]) {
        return NO;
    }
    
    if (self.mac && self.mac.length > 0) {
        NSString * mac = helper.mac.hexString;
        return [mac.lowercaseString isEqualToString:self.mac.lowercaseString];
    }
    
    return YES;
}

- (BOOL)filter:(YPBleDevice *)device {
    return [self filterUsingPeripheral:device.peripheral advertisementData:device.advertisementData RSSI:device.RSSI];
}

@end

NSString * BLEGetCBManagerStateDescription(CBManagerState state);

static YPBleManager *shareManager;

@interface YPBleManager ()
{
    dispatch_block_t _connect_timer_block;
}

@property (nonatomic, strong) NSTimer * scannerTimer;
@property (nonatomic) NSInteger countDownTime;

@property (nonatomic) NSTimeInterval timeCounter; // 计时器运行时长记录器
@property (nonatomic) NSInteger timeRepeats; // 计时器循环次数

@end

@implementation YPBleManager

+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
    });
    return shareManager;
}

+ (void)destroy {
    if (shareManager) {
        shareManager = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuration];
    }
    return self;
}

- (void)setManager:(CBCentralManager *)manager {
    if ([manager isEqual:_manager]) {
        return;
    }
    _manager.delegate = nil;
    _manager = nil;
    _manager = manager;
    _manager.delegate = self;
}

- (void)configuration {
    _discoverDevices = [[NSMutableArray alloc] init];
    _discoverperipheral = [NSMutableArray new];
    
    [self deviceInterceptSetup];
    
    [self operationSetup];
}

- (void)deviceInterceptSetup {
    _bleConfiguration = [[YPBleConfiguration alloc] init];
}

- (void)operationSetup {
    _autoScanWhilePoweredOn = NO;
    _scanTimeout = SCAN_TIME_OUT;
    _openConnectionTimekeeper = NO;
    _connectionTime = CONNECT_TIME_OUT;
}

- (CBCentralManager *)createCenteralManager {
    dispatch_queue_t myQue = dispatch_queue_create("CenteralManagerQueue", DISPATCH_QUEUE_SERIAL);
    CBCentralManager * manager = [[CBCentralManager alloc] initWithDelegate:self queue:myQue];
    return manager;
}

- (void)updateState {
    if (!_manager) {
        _manager = [self createCenteralManager];
    } else {
        [self centralManagerDidUpdateState:_manager];
    }
}

- (void)scannerTimerCountDown {
    
}

- (void)scannerTimerTimeOut {
    [self stopScan];
    
    if (self.discoverDevices.count == 0) {
        [self didReceiveBleError:BLEOperationErrorNotFound];
    }
}

/**
 The execution function of the timer; some parameter is passed to this block when executed to aid in avoiding cyclical references

 @param timer timer scheduled on the current run loop in a run loop mode.
 @param worktime total time when the timer has been running
 @param repeats number of times the timer has been running
 */
- (void)timer:(NSTimer *)timer didWorktime:(NSTimeInterval)worktime repeats:(NSInteger)repeats {
    if(repeats%5 == 0) NSLog(@"Timer %.2f sec., repeats: %zi", worktime, repeats);
    
    if (self.countDownTime - worktime < 0) {
        [self scannerTimerTimeOut];
    } else {
        [self scannerTimerCountDown];
    }
}

/**
 The execution function of the timer;

 @param timer timer scheduled on the current run loop in a run loop mode.
 */
- (void)timerAction:(NSTimer *)timer {
    _timeCounter += timer.timeInterval;
    _timeRepeats += 1;
    
    [self timer:timer didWorktime:_timeCounter repeats:_timeRepeats];
}

- (void)createScannerTimer {
    [self invalidateTimer];
    
    _timeCounter = 0;
    _timeRepeats = 0;
    _countDownTime = self.scanTimeout;
    
    NSTimer * timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    _scannerTimer = timer;
}

- (void)invalidateTimer {
    if (!_scannerTimer) return;
    
    if (_scannerTimer.valid) {
        [_scannerTimer invalidate];
    }
    _scannerTimer = nil;
}

#pragma mark - function
- (void)didUpdateState:(CBCentralManager *)central {
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_DidUpdateState object: central];
    
    if (central.state != CBManagerStatePoweredOn) {return;}
    if (!_autoScanWhilePoweredOn) {return;}
    
    [self startScan];
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([_discoverperipheral containsObject:peripheral]) {
//        return;
    }else {
        [_discoverperipheral addObject:peripheral];
    }
    
    YPBleDevice * device;
    for (YPBleDevice * aDevice in _discoverDevices) {
        if ([aDevice.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            device = aDevice;
            break;
        }
    }
    
    if (!device) {
        device = [[YPBleDevice alloc] initWithDevice:peripheral];
        [_discoverDevices addObject:device];
    }
    device.advertisementData = advertisementData;
    device.RSSI = RSSI;
    
    [device addRSSIRecord:RSSI];
        
    [self logWithFormat:@"Discovered peripheral: identifier(%@) RSSI(%@) specificData = %@", [peripheral identifier], RSSI, device.specificData.hexString.uppercaseString];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_DidDiscoverDevice object:device];
}

#pragma mark - func
- (BOOL)bleEnabled {
    if (!self.manager) {
        _manager = [self createCenteralManager];
        sleep(1.0);
    }
    CBManagerState state = self.manager.state;
    if (state == CBManagerStatePoweredOn) {
        return YES;
    }
    return NO;
}

- (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2){
    va_list args;
    va_start(args, format);
    NSString * string = [[NSString alloc]initWithFormat:format arguments:args];
    va_end(args);
    
    NSLog(@"%@", string);
//    [[YPLogger share] appendLog:string];
}

- (void)didReceiveBleError:(BLEOperationErrorCode)error {
    if (error == BLEOperationErrorNone) {return;}
    NSLog(@"Error: %@", BLEOperationErrorGetDetailDescription(error));
    
    _bleOpError = error;
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_BleOperationError object:@{@"bleOpError": @(_bleOpError)}];
}

#pragma mark - central delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Manager state: %@", BLEGetCBManagerStateDescription(central.state));
    
    [self didUpdateState:central];
    
    // 当断开之前管理器处于操作状态
    if(self.manager.state == CBManagerStatePoweredOff) {
        BLEOperationErrorCode error = BLEOperationErrorNone;
        if (self.isScaning == YES) {
            // 扫描被中断
            _isScaning = NO;
            [self updateBleOperationState:BLEOperationNone];
            error = BLEOperationErrorScanInterrupted;
        }
        else if (self.bleOpState == BLEOperationConnecting || self.bleOpState == BLEOperationConnected) {
            // 连接被中断
            [self updateBleOperationState:BLEOperationNone];
            error = BLEOperationErrorDisconnected;
        }
        
        if (error != BLEOperationErrorNone) {
            [self didReceiveBleError:error];
        }
    }
    else if (self.manager.state == CBManagerStateUnsupported) {
        [self didReceiveBleError:BLEOperationErrorUnsupported];
    }
    else if (self.manager.state == CBManagerStateUnauthorized) {
        [self didReceiveBleError:BLEOperationErrorUnauthorized];
    }
}

//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
//    NSLog(@"will Restore State: %@", dict.description);
//}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([self filterPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI]) {return;}
    
    [self didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Manager did connect device: %@", peripheral);
    [self updateBleOperationState:BLEOperationConnected];
    [self logWithFormat:@"BLE Operation: connected"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_DidConnectedDevice object:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Manager did disconnected device");
    /*!
     1. 非主动断开、意外中断(连接信号中断，如:设备复位、距离过远), 即不是通过“{cancelPeripheralConnection}”断开, error 不为空;
        Error Domain=CBErrorDomain Code=6 "The connection has timed out unexpectedly." UserInfo={NSLocalizedDescription=The connection has timed out unexpectedly.}
        
     2. 开启自定义连接计时器，超时断开; 在一定时间内，由“{@link connectPeripheral:options:}”开启的连接未能完成，当响应连接超时处理机制而调用“{cancelPeripheralConnection}”;
     */
    
    if (error) {
        // 1.连接意外中断
        NSLog(@"Disconnection Error: Code=%zi LocalizedDescription=%@", error.code, error.localizedDescription);
        [self didReceiveBleError:BLEOperationErrorDisconnected];
        return;
    }
    else if (self.bleOpState == BLEOperationConnecting) {
        // 2.自定义连接超时"
        NSLog(@"Disconnecton when connection does timeout");
        [self didReceiveBleError:BLEOperationErrorFailToConnect];
        return;
    }
    else {
        [self updateBleOperationState:BLEOperationDisConnected];
        [self logWithFormat:@"BLE Operation: Disconnected"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEManager_DidDisconnectedDevice object:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Manager did fail to connecting device");
    if (error) {
        NSLog(@"Connection Error: Code=%zi LocalizedDescription=%@", error.code, error.localizedDescription);
        [self didReceiveBleError:BLEOperationErrorFailToConnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"Manager did retreived connected devices");
}

#pragma mark - Blue Operation

- (void)updateBleOperationState:(BLEOperationState)state {
    _bleOpState = state;
    switch (state) {
        case BLEOperationNone:
            [self cancelConnectionTimerBlock]; // 连接时被中断，取消block；
            break;
        case BLEOperationScanning:
//            [self logWithFormat:@"BLE Operation: Scanning..."];
            break;
        case BLEOperationConnected:
            [self cancelConnectionTimerBlock];
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEManager_BleOperationStateDidChange object:@(state)];
}

- (BOOL)filterPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    return ![self.bleConfiguration filterUsingPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

/// 开启自有连接定时器。
- (void)openCustomTimerForConnecting:(YPBleDevice *)device {
    if (!self.openConnectionTimekeeper && self.connectionTime > 0) {return;}
    
    dispatch_block_t block = dispatch_block_create(DISPATCH_BLOCK_BARRIER, ^{
//        if (self.bleOpState == BLEOperationConnecting || device.peripheral.state == CBPeripheralStateConnecting) {
        if (device.peripheral.state == CBPeripheralStateConnecting) {
            [self.manager cancelPeripheralConnection:device.peripheral];
        }
    });
    _connect_timer_block = block;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.connectionTime * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

/// 取消自有连接定时器的回调的调用
- (void)cancelConnectionTimerBlock {
    if (!_connect_timer_block) {
        return;
    }
    dispatch_block_cancel(_connect_timer_block);
    _connect_timer_block = nil;
}

/**/
- (void)startScan {
    if (self.manager.state != CBManagerStatePoweredOn) {
        [self didReceiveBleError:BLEOperationErrorScanInterrupted];
        return;
    }
    
    _isScaning = YES;
    _discoverperipheral = [NSMutableArray new];
    _discoverDevices = [NSMutableArray new];
    _manager.delegate = self;
    
    NSArray * services = self.bleConfiguration.services;
    NSDictionary * options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_manager scanForPeripheralsWithServices:services options: options];
        
    [self updateBleOperationState:BLEOperationScanning];
    [self logWithFormat:@"BLE Operation: Scanning..."];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createScannerTimer];
    });
}

- (void)stopScan {
    [self invalidateTimer];
    
    if (!_isScaning) {return;}
    
    _isScaning = NO;
    [_manager stopScan];
    
    [self updateBleOperationState:BLEOperationStopScan];
    [self logWithFormat:@"BLE Operation: Stop scan"];
}

- (void)connectDevice:(YPBleDevice *)device {
    if (self.manager.state != CBManagerStatePoweredOn) {
        [self didReceiveBleError:BLEOperationDisConnected];
        return;
    }
    
    _currentDevice = device;
    device.peripheral.delegate = _currentDevice;
    _manager.delegate = self;
    
    [self stopScan];
    
    NSDictionary * options = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES};
    [_manager connectPeripheral:device.peripheral options:options];
    
    [self updateBleOperationState:BLEOperationConnecting];
    [self logWithFormat:@"BLE Operation: Connecting"];
    
    [self openCustomTimerForConnecting:device];
}

- (void)disconnectDevice:(YPBleDevice *)device {
    if (!device || !device.peripheral || device.peripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    [self logWithFormat:@"BLE Operation: DisConnecting"];
    
    [self updateBleOperationState:BLEOperationDisConnecting];
    [_manager cancelPeripheralConnection:device.peripheral];
}

- (void)dealloc {
    [self invalidateTimer];
    
    [self disconnectDevice:_currentDevice];
}

@end

NSString * BLEGetCBManagerStateDescription(CBManagerState state) {
    NSString * desc;
    switch (state) {
        case CBManagerStatePoweredOff:
            desc = @"Bluetooth is powered off";
            break;
        case CBManagerStatePoweredOn:
            desc = @"Bluetooth is powered on and ready";
            break;
        case CBManagerStateResetting:
            desc = @"Bluetooth is resetting";
            break;
        case CBManagerStateUnauthorized:
            desc = @"Bluetooth is unauthorized";
            break;
        case CBManagerStateUnknown:
            desc = @"Bluetooth is unknown";
            break;
        case CBManagerStateUnsupported:
            desc = @"Bluetooth is unsupported";
            break;
        default:
            desc = @"Unknown state";
            break;
    }
    return desc;
}
