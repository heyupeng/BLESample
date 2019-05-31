//
//  YPBlueManager.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "YPBlueDefines.h"

#define MAX_RSSI_VALUE 60
#define SCAN_TIME_OUT 30

typedef enum {
    BLEOperationStateNone = 0,
    BLEOperationStateScanning,
    BLEOperationStateStopScan,
    BLEOperationStateConnecting,
    BLEOperationStateConnected,
    BLEOperationStatedisConnecting,
    BLEOperationStatedisConnected,
} BLEOperationState; // Ble Operation State

@class YPBleDevice;

@protocol YPBlueManagerDelegate;

@interface YPBlueManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager * manager;
@property (nonatomic, strong) NSMutableArray * discoverDevices;
@property (nonatomic, strong) NSMutableArray * discoverperipheral;
@property (nonatomic, strong) YPBleDevice * currentDevice;

@property (nonatomic, weak) id<YPBlueManagerDelegate> bleDelegate;

@property (nonatomic) BOOL autoScanWhilePoweredOn;
@property (nonatomic) BOOL isScaning;

/* config */
@property (nonatomic) NSInteger RSSIValue;
@property (nonatomic, copy) NSString * localName;
@property (nonatomic, copy) NSString * mac;

@property (nonatomic) NSInteger scanTimeout;

- (void)startScan;
- (void)stopScan;

- (void)connectDevice:(YPBleDevice *)device;
- (void)disConnectDevice:(YPBleDevice *)device;

+ (instancetype)share;
+ (void)destroy;

- (void)updateState;

@end

@protocol YPBlueManagerDelegate <NSObject>
@optional
- (void)didUpdateState:(YPBlueManager *)blueManager;

- (void)didDiscoverBTDevice:(YPBleDevice *)device;

- (void)didConnectedBTDevice:(YPBleDevice *)device;

@end
