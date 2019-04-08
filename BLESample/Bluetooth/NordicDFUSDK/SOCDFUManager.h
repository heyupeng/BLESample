//
//  SOCDFUManager.h
//  Test1
//
//  Created by xiehaiyan on 2017/3/21.
//  Copyright © 2017年 soocare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define NotificationWithBluetoothStateChanged @"notification_bluetoothStateChanged"
#define NotificationWithDfuStateChanged @"notification_dfuStateChanged"
#define NotificationWithDfuProgressChanged @"notification_dfuProgressChanged"

typedef NS_ENUM(NSInteger, SOCDFUState) {
    SOCDFUStateDefault = 0,
    SOCDFUStateSearching,
    SOCDFUStateConnecting,
    SOCDFUStateStartUpload,
    SOCDFUStateUploading,
    SOCDFUStateComplete,
    SOCDFUStateError
};

@interface SOCDFUManager : NSObject

@property (nonatomic, copy) NSString *deviceNamePrefix;
@property (nonatomic, copy) NSString *deviceMac;
@property (nonatomic, copy) NSString *firmwareFilePath;

- (void)startDfu;
- (void)stopScanDevice;
- (void)stopConnectDevice;

- (void)setCentralManager:(CBCentralManager *)centralManager;
- (void)connectDevice:(CBPeripheral *)peripheral;

@end
