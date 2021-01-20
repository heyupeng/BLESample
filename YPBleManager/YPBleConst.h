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
UIKIT_EXTERN NSNotificationName const YPBLEManager_ReceiveDevices;
UIKIT_EXTERN NSNotificationName const YPBLEManager_DidDiscoverDevice;
UIKIT_EXTERN NSNotificationName const YPBLEManager_DidConnectedDevice;
UIKIT_EXTERN NSNotificationName const YPBLEManager_DidDisconnectedDevice;

UIKIT_EXTERN NSNotificationName const YPBLEManager_BleOperationStateDidChange;
UIKIT_EXTERN NSNotificationName const YPBLEManager_BleOperationError;

UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverServices;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidUpdateValue;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidWriteValue;

typedef enum {
    BLEOperationNone = 0,
    BLEOperationScanning,
    BLEOperationStopScan,
    BLEOperationConnecting,
    BLEOperationConnected,
    BLEOperationDisConnecting,
    BLEOperationDisConnected,
} BLEOperationState; // Ble Operation State

/**
BLE Operation Error Code.
*/
typedef enum {
    BLEOperationErrorNone = 0,
    BLEOperationErrorUnsupported = 1,
    BLEOperationErrorUnauthorized,
    BLEOperationErrorNotFound,
    BLEOperationErrorScanInterrupted, // Scan Interrupted. Ble is scanning, before it's state become off;
    BLEOperationErrorFailToConnect, // Ble fail to connect;
    BLEOperationErrorDisconnected, // Ble is connecting or has did connect, before it's state become off;
} BLEOperationErrorCode; // Ble Operation Error code

UIKIT_EXTERN NSString * BLEOperationErrorGetDescription(BLEOperationErrorCode error);
UIKIT_EXTERN NSString * BLEOperationErrorGetDetailDescription(BLEOperationErrorCode error);

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
// The same UUID
UIKIT_EXTERN NSString * const ButtonlessDFUCharacteristicUUIDString;
UIKIT_EXTERN NSString * const ButtonlessDFUWithoutBondsUUIDString;
UIKIT_EXTERN NSString * const ButtonlessDFUWithBondsUUIDString;
