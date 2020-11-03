//
//  YPBleConst.m
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "YPBleConst.h"

NSNotificationName const YPBLEManager_DidUpdateState           = @"YPBleManagerDidUpdateState";
NSNotificationName const YPBLEManager_ReceiveDevices           = @"YPBleManagerReceiveDevices";
NSNotificationName const YPBLEManager_DidDiscoverDevice        = @"YPBleManagerDiscoverDevice";
NSNotificationName const YPBLEManager_DidConnectedDevice       = @"YPBleManagerConnectedDevice";
NSNotificationName const YPBLEManager_DidDisconnectedDevice    = @"YPBleManagerDisconnectedDevice";

NSNotificationName const YPBLEManager_BleOperationStateDidChange  = @"YPBLEManagerBleOperationStateDidChange";
NSNotificationName const YPBLEManager_BleOperationError  = @"YPBLEManagerBleOperationError";

NSNotificationName const YPBLEDevice_DidDiscoverServices         = @"YPDeviceDidDiscoverServices";
NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics  = @"YPDeviceDidDiscoverCharacteristics";
NSNotificationName const YPBLEDevice_DidUpdateValue              = @"YPDeviceDidUpdateValue";
NSNotificationName const YPBLEDevice_DidWriteValue               = @"YPDeviceDidWriteValue";

/* BLEOperationError Description
 */
NSString * BLEOperationErrorGetDescription(BLEOperationErrorCode error) {
    switch (error) {
        case BLEOperationErrorUnsupported:
            return @"Unsupported";
        case BLEOperationErrorUnauthorized:
            return @"Unauthorized";
        case BLEOperationErrorNotFound:
            return @"NotFound";
            break;
        case BLEOperationErrorScanInterrupted:
            return @"StopScan";
            break;
        case BLEOperationErrorFailToConnect:
            return @"FailToConnect";
            break;
        case BLEOperationErrorDisconnected:
            return @"Disconnected";
            break;
        default:
            break;
    }
    return nil;
}

NSString * BLEOperationErrorGetDetailDescription(BLEOperationErrorCode error) {
    switch (error) {
        case BLEOperationErrorUnsupported:
            return @"Bluetooth Unsupported";
        case BLEOperationErrorUnauthorized:
            return @"Bluetooth Authorization Denied";
        case BLEOperationErrorNotFound:
            return @"Bluetooth can't find any peripheral";
            break;
        case BLEOperationErrorScanInterrupted:
            return @"Scan interrupted. (Bluetooth become off when it is scanning.)";
            break;
        case BLEOperationErrorFailToConnect:
            return @"Bluetooth fail to connection";
            break;
        case BLEOperationErrorDisconnected:
            return @"Connection interrupted. (Bluetooth become off when it is connecting or has been connected.)";
            break;
        default:
            break;
    }
    return nil;
}

/*
 Nordic UART Service
 */
NSString * const NordicUARTServiceUUIDString = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400001B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTTxCharacteristicUUIDString = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400002B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTRxCharacteristicUUIDString = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400003B5A3F393E0A9E50E24DCCA9E

