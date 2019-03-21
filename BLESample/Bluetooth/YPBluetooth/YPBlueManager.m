//
//  YPBlueManager.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPBlueManager.h"

#import "YPDeviceManager.h"
#import "YPBlueConst.h"

static YPBlueManager *shareManager;

@interface YPBlueManager ()

@property (nonatomic, strong) NSTimer * scannerTimer;
@property (nonatomic) NSInteger countDownTime;

@property (nonatomic) NSTimeInterval timeCounter; // 计时器运行时长记录器
@property (nonatomic) NSInteger timeRepeats; // 计时器循环次数

@end

@implementation YPBlueManager

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
    _RSSIValue = MAX_RSSI_VALUE;
    _scanTimeout = SCAN_TIME_OUT;
    
    _discoverDevices = [[NSMutableArray alloc] init];
    _discoverperipheral = [NSMutableArray new];
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
}

/**
 The execution function of the timer; some parameter is passed to this block when executed to aid in avoiding cyclical references

 @param timer timer scheduled on the current run loop in a run loop mode.
 @param timeCounter total time when the timer has been running
 @param repeats number of times the timer has been running
 */
- (void)timer:(NSTimer *)timer didExecuteTime:(NSTimeInterval)timeCounter repeats:(NSInteger)repeats {
    NSLog(@"Timer counter: %.2f , repeats: %zi", timeCounter, repeats);

    _countDownTime --;
    if (_countDownTime < 0) {
        [self scanTimeout];
        return;
    }
    
    [self scannerTimerCountDown];
}

/**
 The execution function of the timer;

 @param timer timer scheduled on the current run loop in a run loop mode.
 */
- (void)timerAction:(NSTimer *)timer {
    _timeCounter += timer.timeInterval;
    _timeRepeats += 1;
    
    [self timer:timer didExecuteTime:_timeCounter repeats:_timeRepeats];
}

- (void)createScannerTimer {
    [self invalidateTimer];
    
    _timeCounter = 0;
    _timeRepeats = 0;
    
    _scannerTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_scannerTimer forMode:NSRunLoopCommonModes];
}

- (void)scannerTimerFire {
    _countDownTime = self.scanTimeout;
    [self createScannerTimer];
}

- (void)invalidateTimer {
    if (!_scannerTimer) return;
    
    if (_scannerTimer.valid) {
        [_scannerTimer invalidate];
    }
    _scannerTimer = nil;
}

- (BOOL)filterPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (abs([RSSI intValue]) > _RSSIValue) { return YES; }
    
    if (self.name && ![[advertisementData objectForKey:CBAdvertisementDataLocalNameKey] hasPrefix:self.name]) {return YES;}
    
    return NO;
}

#pragma mark - function
- (void)didUpdateState:(CBCentralManager *)central {
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLE_DidUpdateState object: central];
    
    if (!_autoScanWhilePoweredOn && central.state == CBManagerStatePoweredOn) {return;}
    
    [self startScan];
}

- (void)didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ([_discoverperipheral containsObject:peripheral]) {return;}
    [_discoverperipheral addObject:peripheral];
    
    for (YPDeviceManager * aDevice in _discoverDevices) {
        if ([aDevice.peripheral.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            return;
        }
    }
    NSLog(@"Discovered %@ RSSI: %@ advertisement: %@", [peripheral description], RSSI, [advertisementData description]);
    
    YPDeviceManager * device = [[YPDeviceManager alloc] initWithDevice:peripheral];
    device.advertisementData = advertisementData;
    device.RSSI = RSSI;
    [_discoverDevices addObject:device];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLE_DidDiscoverDevice object:device];
}

#pragma mark - central delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%@", [self getDescriptionForManagerState:central.state]);
    
    [self didUpdateState:central];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSLog(@"will Restore State: %@", dict.description);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    BOOL filter = [self filterPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    if (filter) {return;}
    
    [self didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connect device: %@", peripheral);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLE_DidConnectedDevice object:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected device");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLE_DidDisconnectedDevice object:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Fail to connecting device");
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"Retreived connected devices");
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"Retrieved peripherals: %@", peripherals);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLE_ReceiveDevices object:peripherals];
}

#pragma mark - Blue Operation

/**
 a collection of service allowed

 @return a collection of service allowed
 */
- (NSArray<CBUUID *> *)services {
    CBUUID * serviceUUID = [CBUUID UUIDWithString:@"FE95"];
    return @[serviceUUID];
}

/**/
- (void)startScan {
    _isScaning = YES;
    _discoverperipheral = [NSMutableArray new];
    _discoverDevices = [NSMutableArray new];
    
    NSArray * services = [self services];
    NSDictionary * options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_manager scanForPeripheralsWithServices:services options: options];
    
    [self scannerTimerFire];
}

- (void)stopScan {
    _isScaning = NO;
    [_manager stopScan];
    
    [self invalidateTimer];
}

- (void)connectDevice:(YPDeviceManager *)device {
    _currentDevice = device;
    device.peripheral.delegate = _currentDevice;
    _manager.delegate = self;
    
    [self stopScan];
    
    NSDictionary * options = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES};
    [_manager connectPeripheral:device.peripheral options:options];
}

- (void)disConnectDevice:(YPDeviceManager *)device {
    if (!device || !device.peripheral || device.peripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    [_manager cancelPeripheralConnection:device.peripheral];
}

- (void)dealloc {
    [self invalidateTimer];
    
    [self disConnectDevice:_currentDevice];
}

- (NSString *)getDescriptionForManagerState: (CBManagerState)state {
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
            desc = @"Bluetooth state is unauthorized";
            break;
        case CBManagerStateUnknown:
            desc = @"Bluetooth state is unknown";
            break;
        case CBManagerStateUnsupported:
            desc = @"Bluetooth is unsupported on this platform";
            break;
        default:
            desc = @"Unknown state";
            break;
    }
    return desc;
}

@end
