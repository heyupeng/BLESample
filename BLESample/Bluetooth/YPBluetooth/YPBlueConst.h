//
//  YPBlueConst.h
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
UIKIT_EXTERN NSNotificationName const YPBLEManager_BluetoothOperationError;

UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverServices;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidUpdateValue;
UIKIT_EXTERN NSNotificationName const YPBLEDevice_DidWriteValue;


/**
 BluetoothOperationError
 */
typedef NS_ENUM(NSInteger, BluetoothOperationError) {
    BluetoothOpErrorScanningTimeout = 1,
    BluetoothOpErrorFailToConnect = 2,
    BluetoothOpErrorDisconnected ,
};

/*
 Nordic UART Service
 */
UIKIT_EXTERN NSString * const NordicUARTServiceUUIDString;
UIKIT_EXTERN NSString * const NordicUARTTxCharacteristicUUIDString;
UIKIT_EXTERN NSString * const NordicUARTRxCharacteristicUUIDString;
