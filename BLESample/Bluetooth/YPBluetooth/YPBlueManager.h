//
//  YPBlueManager.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlueDefines.h"

#define MAX_RSSI_VALUE 60
#define SCAN_TIME_OUT 30

@class YPDeviceManager;

@protocol YPBlueManagerDelegate;

@interface YPBlueManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager * manager;
@property (nonatomic, strong) NSMutableArray * discoverDevices;
@property (nonatomic, strong) NSMutableArray * discoverperipheral;
@property (nonatomic, strong) YPDeviceManager * currentDevice;

@property (nonatomic) BOOL autoScanWhilePoweredOn;
@property (nonatomic) BOOL isScaning;

/* config */
@property (nonatomic, copy) NSString * name;
@property (nonatomic) NSInteger RSSIValue;
@property (nonatomic) NSInteger scanTimeout;

- (void)startScan;
- (void)stopScan;

- (void)connectDevice:(YPDeviceManager *)device;
- (void)disConnectDevice:(YPDeviceManager *)device;

+ (instancetype)share;
+ (void)destroy;

- (void)updateState;

@end

@protocol YPBlueManagerDelegate <NSObject>
@optional
- (void)didUpdateState:(YPBlueManager *)blueManager;

- (void)didDiscoverBTDevice:(YPDeviceManager *)device;

- (void)didConnectedBTDevice:(YPDeviceManager *)device;

@end
