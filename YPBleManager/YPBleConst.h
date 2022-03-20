//
//  YPBleConst.h
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSNotificationName const YPBLEManager_DidUpdateState;
FOUNDATION_EXTERN NSNotificationName const YPBLEManager_DidDiscoverDevice;
FOUNDATION_EXTERN NSNotificationName const YPBLEManager_DidConnectDevice;
FOUNDATION_EXTERN NSNotificationName const YPBLEManager_DidDisconnectDevice;

FOUNDATION_EXTERN NSNotificationName const YPBLEManager_BleOperationStateDidChange;
FOUNDATION_EXTERN NSNotificationName const YPBLEManager_BleOperationError;

FOUNDATION_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverServices;
FOUNDATION_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics;
FOUNDATION_EXTERN NSNotificationName const YPBLEDevice_DidUpdateValue;
FOUNDATION_EXTERN NSNotificationName const YPBLEDevice_DidWriteValue;

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
    BLEOpErrorPoweredOff,
    BLEOpErrorNotFound,
    BLEOpErrorScanInterrupted, /* 检索中断。扫描时关闭蓝牙 */
    BLEOpErrorConnectionTimeout, /* 连接超时 */
    BLEOpErrorConnectionFailed, /* 连接失败 */
    BLEOpErrorDisconnected, /* 连接意外中断。已连接时关闭蓝牙、关机或距离多远导致的断开连接 */
};

FOUNDATION_EXTERN NSString * BLEOpErrorGetDescription(BLEOpErrorCode error);
FOUNDATION_EXTERN NSString * BLEOpErrorGetDetailDescription(BLEOpErrorCode error);
FOUNDATION_EXTERN NSString * CBManagerStateGetDescription(CBManagerState state);

/* Nordic UART Service */
FOUNDATION_EXTERN NSString * const NordicUARTServiceUUIDString;
FOUNDATION_EXTERN NSString * const NordicUARTTxCharacteristicUUIDString;
FOUNDATION_EXTERN NSString * const NordicUARTRxCharacteristicUUIDString;

/* Legacy DFU Service */
FOUNDATION_EXTERN NSString * const LegacyDFUServiceUUIDString;
FOUNDATION_EXTERN NSString * const LegacyDFUControlPointUUIDString;
FOUNDATION_EXTERN NSString * const LegacyDFUPacketUUIDString;
FOUNDATION_EXTERN NSString * const LegacyDFUVersionUUIDString;

/* Secure DFU */
FOUNDATION_EXTERN NSString * const SecureDFUServiceUUIDString;
FOUNDATION_EXTERN NSString * const SecureDFUControlPointUUIDString;
FOUNDATION_EXTERN NSString * const SecureDFUPacketUUIDString;

/* Buttonless DFU */
FOUNDATION_EXTERN NSString * const ButtonlessDFUServiceUUIDString;
FOUNDATION_EXTERN NSString * const ButtonlessDFUCharacteristicUUIDString; // The same UUID

FOUNDATION_EXTERN NSString * const ButtonlessDFUWithoutBondsUUIDString;
FOUNDATION_EXTERN NSString * const ButtonlessDFUWithBondsUUIDString;
