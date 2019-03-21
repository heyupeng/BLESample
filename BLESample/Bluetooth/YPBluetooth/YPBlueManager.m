//
//  YPBlueManager.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPBlueManager.h"
#import "YPDeviceManager.h"

static YPBlueManager *shareManager;

@interface YPBlueManager ()

@property (nonatomic, strong) NSTimer * scannerTimer;
@property (nonatomic) NSInteger countDownTime;

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
    _scanTimeout = SCAN_TIME;
    
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
    NSLog(@"countDown: %ld", _countDownTime);
    _countDownTime --;
    if (_countDownTime < 0) {
        [self stopScan];
    }
}

- (void)createScannerTimer {
    _scannerTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(scannerTimerCountDown) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_scannerTimer forMode:NSRunLoopCommonModes];
}

- (void)scannerTimerFire {
    _countDownTime = self.scanTimeout;
    [self createScannerTimer];
}

- (void)scannerTimerInvalidate {
    if (_scannerTimer) {
        [_scannerTimer invalidate];
        _scannerTimer = nil;
    }
}

#pragma mark - central delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%@", [self getDescriptionForManagerState:central.state]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: YPBLE_DidUpdateState object: central];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict {
    NSLog(@"will Restore State: %@", dict.description);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if (abs([RSSI intValue]) > _RSSIValue) { return; }
    
    if (self.name && ![[advertisementData objectForKey:CBAdvertisementDataLocalNameKey] hasPrefix:self.name]) {return;}
    
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

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"connect device: %@", peripheral);
    
    [peripheral discoverServices:nil];
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

#pragma mark -
/**/
- (void)startScan {
    _isScaning = YES;
    _discoverperipheral = [NSMutableArray new];
    _discoverDevices = [NSMutableArray new];
    
    CBUUID * serviceUUID = [CBUUID UUIDWithString:@"FE95"];
    
    NSArray * services = @[];
    NSDictionary * options = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [_manager scanForPeripheralsWithServices:services options: options];
    
    [self scannerTimerFire];
}

- (void)stopScan {
    _isScaning = NO;
    [_manager stopScan];
    
    [self scannerTimerInvalidate];
}

- (void)connectDevice:(YPDeviceManager *)device {
    _currentDevice = device;
    device.peripheral.delegate = _currentDevice;
    _manager.delegate = self;
    
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
    [self scannerTimerInvalidate];
    
    if (_currentDevice) {
        [self disConnectDevice:_currentDevice];
    }
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
