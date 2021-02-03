//
//  YPBleConst.h
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN NSNotificationName const YPBLEManager_DidUpdateState;
UIKIT_EXTERN NSNotificationName const YPBLEManager_DidDiscoverDevice;
UIKIT_EXTERN NSNotificationName const YPBLEManager_DidConnectDevice;
UIKIT_EXTERN NSNotificationName const YPBLEManager_DidDisconnectDevice;

UIKIT_EXTERN NSNotificationName const YPBLEManager_BleOperationStateDidChange;
UIKIT_EXTERN NSNotificationName const YPBLEManager_BleOperationError;

UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverServices;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidUpdateValue;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidWriteValue;

/** BLE Operation State. */
typedef NS_ENUM(NSInteger, BLEOpState) {
    BLEOpNone = 0,
    BLEOpScanning,
    BLEOpStopScan,
    BLEOpConnecting,
    BLEOpConnected,
    BLEOpDisConnecting,
    BLEOpDisConnected,
};


/** BLE Operation Error Code. */
typedef NS_ENUM(NSInteger, BLEOpErrorCode) {
    BLEOpErrorNone = 0,
    BLEOpErrorUnsupported = 1,
    BLEOpErrorUnauthorized,
    BLEOpErrorNotFound,
    BLEOpErrorScanInterrupted, /* 检索中断。扫描时关闭蓝牙 */
    BLEOpErrorConnectionTimeout, /* 连接超时 */
    BLEOpErrorConnectionFailed, /* 连接失败 */
    BLEOpErrorDisconnected, /* 连接意外中断。已连接时关闭蓝牙、关机或距离多远导致的断开连接 */
};

UIKIT_EXTERN NSString * BLEOpErrorGetDescription(BLEOpErrorCode error);
UIKIT_EXTERN NSString * BLEOpErrorGetDetailDescription(BLEOpErrorCode error);

/* Nordic UART Service */
UIKIT_EXTERN NSString * const NordicUARTServiceUUIDString;
UIKIT_EXTERN NSString * const NordicUARTTxCharacteristicUUIDString;
UIKIT_EXTERN NSString * const NordicUARTRxCharacteristicUUIDString;

/* Legacy DFU Service */
UIKIT_EXTERN NSString * const LegacyDFUServiceUUIDString;
UIKIT_EXTERN NSString * const LegacyDFUControlPointUUIDString;
UIKIT_EXTERN NSString * const LegacyDFUPacketUUIDString;
UIKIT_EXTERN NSString * const LegacyDFUVersionUUIDString;

/* Secure DFU */
UIKIT_EXTERN NSString * const SecureDFUServiceUUIDString;
UIKIT_EXTERN NSString * const SecureDFUControlPointUUIDString;
UIKIT_EXTERN NSString * const SecureDFUPacketUUIDString;

/* Buttonless DFU */
UIKIT_EXTERN NSString * const ButtonlessDFUServiceUUIDString;
UIKIT_EXTERN NSString * const ButtonlessDFUCharacteristicUUIDString; // The same UUID

UIKIT_EXTERN NSString * const ButtonlessDFUWithoutBondsUUIDString;
UIKIT_EXTERN NSString * const ButtonlessDFUWithBondsUUIDString;
