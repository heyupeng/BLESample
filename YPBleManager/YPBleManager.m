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
    
    _autoScanWhilePoweredOn = NO;
    _scanTimeoutPeriod = SCAN_TIME_OUT;
    _connectionTimeoutPeriod = CONNECTTION_TIME_OUT;
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

- (BOOL)filterUsingDevice:(YPBleDevice *)device {
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

@property (nonatomic) NSTimeInterval timerWorkTime; // 计时器运行时长记录器
@property (nonatomic) NSInteger timerRepeatTimes; // 计时器循环次数

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
    
    [self operationSetup];
}

- (void)operationSetup {
    _bleConfiguration = [[YPBleConfiguration alloc] init];
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

- (void)scannerCountdown:(NSTimeInterval)remainingTime {
    if (remainingTime >= 0) {
        return;
    }
    
    [self stopScan];
    
    if (self.discoverDevices.count == 0) {
        [self didReceiveOpError:BLEOpErrorNotFound];
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
    
    [self scannerCountdown:self.countDownTime - worktime];
}

/**
 The execution function of the timer;
 @param timer timer scheduled on the current run loop in a run loop mode.
 */
- (void)timerAction:(NSTimer *)timer {
    _timerWorkTime += timer.timeInterval;
    _timerRepeatTimes += 1;
    
    [self timer:timer didWorktime:_timerWorkTime repeats:_timerRepeatTimes];
}

- (void)createScannerTimer {
    [self invalidateTimer];
    
    _timerWorkTime = 0;
    _timerRepeatTimes = 0;
    _countDownTime = self.bleConfiguration.scanTimeoutPeriod;
    
    NSTimer * timer;
#if 1
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
#else
    void (^block)(NSTimeInterval) = ^(NSTimeInterval remainingTime) {
        [self scannerCountdown:remainingTime];
    };
    
    NSTimeInterval countdownTime = self.countDownTime;
    __block NSTimeInterval worktime = 0;
    __block NSInteger repeatTimes = 0;
    timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        worktime += timer.timeInterval;
        repeatTimes += 1;
        
        if (countdownTime - worktime < 0) {
            [self invalidateTimer];
        }
        
        block(countdownTime - worktime);
    }];
#endif
    
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
    
    if (self.bleDelegate && [self.bleDelegate respondsToSelector:@selector(bleManagerDidUpdateState:)]) {
        [self.bleDelegate bleManagerDidUpdateState:self];
    }
    
    if (self.bleConfiguration.autoScanWhilePoweredOn && central.state == CBManagerStatePoweredOn) {
        [self startScan];
    }
}

- (YPBleDevice *)bleDeviceFromCachesWithPeripheral:(CBPeripheral *)peripheral {
    YPBleDevice * device;
    for (YPBleDevice * aDevice in _discoverDevices) {
        if ([aDevice.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            device = aDevice;
            break;
        }
    }
    return device;
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    YPBleDevice * device = [self bleDeviceFromCachesWithPeripheral:peripheral];
    
    if (!device) {
        device = [[YPBleDevice alloc] initWithDevice:peripheral];
        [_discoverDevices addObject:device];
    }
    device.advertisementData = advertisementData;
    device.RSSI = RSSI;
    
    [device addRSSIRecord:RSSI];
        
    [self logWithFormat:@"Peripheral: %@ (%@ dBm) \n    specificData = %@", peripheral.name, RSSI, device.specificData.hexString];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_DidDiscoverDevice object:device];
    
    if (self.bleDelegate && [self.bleDelegate respondsToSelector:@selector(didDiscoverBleDevice:)]) {
        [self.bleDelegate didDiscoverBleDevice:device];
    }
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
    
    if (self.bleConfiguration.logger) {
        self.bleConfiguration.logger(string);
    }
}

#pragma mark - BLE Op state or error Notificatio or bleDelegate
/// bleManager 执行状态变化时， 发起广播或调用代理
- (void)didUpdateOpState:(BLEOpState)state {
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEManager_BleOperationStateDidChange object:@(state)];
    
    if (self.bleDelegate && [self.bleDelegate respondsToSelector:@selector(bleManagerOpState:)]) {
        [self.bleDelegate bleManagerOpState:state];
    }
}

- (void)didReceiveOpError:(BLEOpErrorCode)error {
    if (error == BLEOpErrorNone) {return;}
    NSLog(@"Error: %@", BLEOpErrorGetDetailDescription(error));
    
    _bleOpError = error;
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_BleOperationError object:@{@"bleOpError": @(_bleOpError)}];
    
    if (self.bleDelegate && [self.bleDelegate respondsToSelector:@selector(bleManagerOpError:)]) {
        [self.bleDelegate bleManagerOpError:error];
    }
}

#pragma mark - Blue Operation
- (void)updateBleOperationState:(BLEOpState)state {
    _bleOpState = state;
    switch (state) {
        case BLEOpNone:
            [self cancelConnectionTimerBlock]; // 连接时被中断，取消block；
            break;
        case BLEOpScanning:
            break;
        case BLEOpConnected:
            [self cancelConnectionTimerBlock];
            break;
        default:
            break;
    }
    
    [self didUpdateOpState:state];
}

- (BOOL)filterPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    return ![self.bleConfiguration filterUsingPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

#pragma mark - CentralManager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Manager state: %@", BLEGetCBManagerStateDescription(central.state));
    
    [self didUpdateState:central];
    
    // 当断开之前管理器处于操作状态
    if(self.manager.state == CBManagerStatePoweredOff) {
        BLEOpErrorCode error = BLEOpErrorNone;
        if (self.isScaning == YES) {
            // 扫描被中断
            _isScaning = NO;
            [self updateBleOperationState:BLEOpNone];
            error = BLEOpErrorScanInterrupted;
        }
        else if (self.bleOpState == BLEOpConnecting || self.bleOpState == BLEOpConnected) {
            // 连接被中断
            [self updateBleOperationState:BLEOpNone];
            error = BLEOpErrorDisconnected;
        }
        
        if (error != BLEOpErrorNone) {
            [self didReceiveOpError:error];
        }
    }
    else if (self.manager.state == CBManagerStateUnsupported) {
        [self didReceiveOpError:BLEOpErrorUnsupported];
    }
    else if (self.manager.state == CBManagerStateUnauthorized) {
        [self didReceiveOpError:BLEOpErrorUnauthorized];
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
    [self updateBleOperationState:BLEOpConnected];
    [self logWithFormat:@"BLE Operation: connected"];
    
    YPBleDevice * device = [self bleDeviceFromCachesWithPeripheral:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLEManager_DidConnectDevice object:device];
    
    if (self.bleDelegate && [self.bleDelegate respondsToSelector:@selector(didConnectBleDevice:)]) {
        [self.bleDelegate didConnectBleDevice:device];
    }
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Manager did fail to connecting device");
    if (error) {
        NSLog(@"Connection Error: Code=%zi LocalizedDescription=%@", error.code, error.localizedDescription);
        [self didReceiveOpError:BLEOpErrorConnectionFailed];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Manager did disconnected device");
    /*!
     1. 非主动断开、意外中断。
     连接信号中断，如:设备复位、距离过远。 即不是通过“{cancelPeripheralConnection}”断开, error 不为空;
     Error Domain=CBErrorDomain Code=6 "The connection has timed out unexpectedly." UserInfo={NSLocalizedDescription=The connection has timed out unexpectedly.}
        
     2. 开启自定义连接计时器，超时断开。
     在一定时间内，由 “{@link connectPeripheral:options:}” 开启的连接请求未能完成时，响应连接超时处理机制而调用“{cancelPeripheralConnection}”;
     */
    
    if (error) {
        // 1.连接意外中断
        NSLog(@"Disconnection Error: Code=%zi LocalizedDescription=%@", error.code, error.localizedDescription);
        [self didReceiveOpError:BLEOpErrorDisconnected];
        return;
    }
    else if (self.bleOpState == BLEOpConnecting) {
        // 2.自定义连接超时"
        NSLog(@"Disconnection Error: Cancel connection that timeout");
        [self didReceiveOpError:BLEOpErrorConnectionTimeout];
        return;
    }
    else {
        [self updateBleOperationState:BLEOpDisConnected];
        [self logWithFormat:@"BLE Operation: Disconnected"];
    }
    
    YPBleDevice * device = [self bleDeviceFromCachesWithPeripheral:peripheral];
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEManager_DidDisconnectDevice object:device];
    if (self.bleDelegate && [self.bleDelegate respondsToSelector:@selector(didDisconnectBleDevice:)]) {
        [self.bleDelegate didDisconnectBleDevice:device];
    }
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"Manager did retreived connected devices");
}

#pragma mark - 自有连接定时器(dispatch)
/// 开启自有连接定时器。
- (void)openCustomTimerForConnecting:(YPBleDevice *)device {
    if (!self.bleConfiguration.openConnectionTimer || self.bleConfiguration.connectionTimeoutPeriod <= 0) {return;}
    
    NSInteger sec = self.bleConfiguration.connectionTimeoutPeriod;
    dispatch_block_t block = ^{
        if (device.peripheral.state == CBPeripheralStateConnecting) {
            [self.manager cancelPeripheralConnection:device.peripheral];
        }
    };
    
    dispatch_block_t newBlock = dispatch_block_create(DISPATCH_BLOCK_BARRIER, block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(sec * NSEC_PER_SEC)), dispatch_get_main_queue(), newBlock);
    
    _connect_timer_block = newBlock;
}

/// 取消自有连接定时器的回调的调用
- (void)cancelConnectionTimerBlock {
    if (!_connect_timer_block) {
        return;
    }
    dispatch_block_cancel(_connect_timer_block);
    _connect_timer_block = nil;
}

#pragma mark - CentralManager 方法的二次封装
- (void)startScan {
    if (self.manager.state != CBManagerStatePoweredOn) {
        [self didReceiveOpError:BLEOpErrorScanInterrupted];
        return;
    }
    
    _discoverDevices = [NSMutableArray new];
    _manager.delegate = self;
    
    _isScaning = YES;
    NSArray * services = self.bleConfiguration.services;
    NSDictionary * options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_manager scanForPeripheralsWithServices:services options: options];
    
    [self logWithFormat:@"BLE Operation: Scanning..."];
    [self updateBleOperationState:BLEOpScanning];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self createScannerTimer];
    });
}

- (void)stopScan {
    [self invalidateTimer];
    
    if (!_isScaning) {return;}
    
    _isScaning = NO;
    [_manager stopScan];
    
    [self logWithFormat:@"BLE Operation: Stop scan"];
    [self updateBleOperationState:BLEOpStopScan];
}

- (void)connectDevice:(YPBleDevice *)device {
    if (self.manager.state != CBManagerStatePoweredOn) {
        [self didReceiveOpError:BLEOpErrorDisconnected];
        return;
    }
    
    _currentDevice = device;
    device.peripheral.delegate = device;
    _manager.delegate = self;
    
    [self stopScan];
    
    NSDictionary * options = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES};
    [_manager connectPeripheral:device.peripheral options:options];
    
    [self logWithFormat:@"BLE Operation: Connecting"];
    [self updateBleOperationState:BLEOpConnecting];
    
    [self openCustomTimerForConnecting:device];
}

- (void)disconnectDevice:(YPBleDevice *)device {
    if (!device || !device.peripheral || device.peripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    [self logWithFormat:@"BLE Operation: DisConnecting"];
    [self updateBleOperationState:BLEOpDisConnecting];
    
    [_manager cancelPeripheralConnection:device.peripheral];
}

#pragma mark - dealloc
- (void)dealloc {
    [self invalidateTimer];
    [self cancelConnectionTimerBlock];
    
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
