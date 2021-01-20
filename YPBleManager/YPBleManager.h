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

@interface YPBleConfiguration : NSObject

/* 设备拦截过滤设置 */

/// 要扫描的服务的CBUUID对象的列表。
@property (nonatomic, strong) NSArray<CBUUID *> * services;

/// 信号值。默认 MAX_RSSI_VALUE 。超过信号值的将被拦截。
@property (nonatomic) NSInteger RSSIValue;

/// 未命名拦截。默认 NO 。当 YES 时，未命名的设备将被拦截。
@property (nonatomic) BOOL unnamedIntercept;

/// 无厂商信息拦截。默认 NO 。当YES 时，广播信息未携带 ManufacturerData 的设备将被拦截
@property (nonatomic) BOOL withoutDataIntercept;

/// 设备名。默认 nil 。广播信息中 localName 未包含 localName 的设备将被拦截。
@property (nonatomic, copy) NSString * localName;

/// 忽略设备名。默认 nil 。广播信息中 localName 包含 ignoreLocalName 的设备将被拦截。
@property (nonatomic, copy) NSArray * ignoreLocalNames;

/// 地址。默认 nil 。当 mac 不为 nil ， 检索目标设备，其他设备将被拦截
@property (nonatomic, copy) NSString * mac;

@end

@interface YPBleManager : NSObject <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager * manager;
@property (nonatomic, strong) NSMutableArray * discoverDevices;
@property (nonatomic, strong) NSMutableArray * discoverperipheral;
@property (nonatomic, strong) YPBleDevice * currentDevice;

@property (nonatomic, weak) id<YPBleManagerDelegate> bleDelegate;

/// 蓝牙是否可用。默认NO。{manager.state == CBManagerStatePoweredOn}时为YES。
@property (nonatomic, readonly) BOOL bleEnabled;
/// 是否正在检索状态。
@property (nonatomic, readonly) BOOL isScaning;
/// 管理器状态。
@property (nonatomic, readonly) BLEOperationState bleOpState;
/// 管理器操作错误码
@property (nonatomic, readonly) BLEOperationErrorCode bleOpError;

@property (nonatomic, strong) YPBleConfiguration * bleConfiguration;

/* 管理器操作设置 */
/// 默认 NO。当autoScanWhilePoweredOn 为YES，打开蓝牙时自动检索。
@property (nonatomic) BOOL autoScanWhilePoweredOn;
/// 检索时间。默认 30 sec。
@property (nonatomic) NSInteger scanTimeout;
/// 开启连接计时。配合 connectionTime 使用
@property (nonatomic) BOOL openConnectionTimekeeper;
/// 连接时间。默认 10 sec。
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
- (void)didUpdateState:(YPBleManager *)bleManager;

- (void)didDiscoverBleDevice:(YPBleDevice *)device;

- (void)didConnectedBleDevice:(YPBleDevice *)device;

@end
