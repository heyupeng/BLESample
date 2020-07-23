//
//  YPBleManager.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "YPBleConst.h"

#define MAX_RSSI_VALUE 60
#define SCAN_TIME_OUT 30
#define CONNECT_TIME_OUT 10

@class YPBleDevice;

@protocol YPBleManagerDelegate;

@interface YPBleManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager * manager;
@property (nonatomic, strong) NSMutableArray * discoverDevices;
@property (nonatomic, strong) NSMutableArray * discoverperipheral;
@property (nonatomic, strong) YPBleDevice * currentDevice;

@property (nonatomic, weak) id<YPBleManagerDelegate> bleDelegate;

/// 默认NO。{manager.state == CBManagerStatePoweredOn}时为YES。
@property (nonatomic, readonly) BOOL bleEnabled;

@property (nonatomic) BOOL autoScanWhilePoweredOn;
@property (nonatomic, readonly) BOOL isScaning;
@property (nonatomic, readonly) BLEOperationState bleOpState;
@property (nonatomic, readonly) BLEOperationErrorCode bleOpError;

/* config */
@property (nonatomic) NSInteger RSSIValue;
@property (nonatomic, copy) NSString * localName;
@property (nonatomic, copy) NSString * mac;

@property (nonatomic) NSInteger scanTimeout;

@property (nonatomic) BOOL openConnectionTimekeeper;
@property (nonatomic) NSInteger connectionTime;

- (void)startScan;
- (void)stopScan;

- (void)connectDevice:(YPBleDevice *)device;
- (void)disconnectDevice:(YPBleDevice *)device;

+ (instancetype)share;
+ (void)destroy;

- (void)updateState;

@end

@protocol YPBleManagerDelegate <NSObject>
@optional
- (void)didUpdateState:(YPBleManager *)blueManager;

- (void)didDiscoverBleDevice:(YPBleDevice *)device;

- (void)didConnectedBleDevice:(YPBleDevice *)device;

@end
