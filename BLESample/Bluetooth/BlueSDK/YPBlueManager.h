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
#import "YPBLEMacro.h"

#define MAX_RSSI_VALUE 60
#define SCAN_TIME 30

@class YPDeviceManager;

@interface YPBlueManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager * manager;
@property (nonatomic, strong) NSMutableArray * discoverDevices;
@property (nonatomic, strong) NSMutableArray * discoverperipheral;
@property (nonatomic, strong) YPDeviceManager * currentDevice;

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
