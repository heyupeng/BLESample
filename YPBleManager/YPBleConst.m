//
//  YPBleConst.m
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "YPBleConst.h"

NSNotificationName const YPBLEManager_DidUpdateState           = @"YPBleManagerDidUpdateState";
NSNotificationName const YPBLEManager_DidDiscoverDevice        = @"YPBleManagerDiscoverDevice";
NSNotificationName const YPBLEManager_DidConnectDevice       = @"YPBleManagerConnectedDevice";
NSNotificationName const YPBLEManager_DidDisconnectDevice    = @"YPBleManagerDisconnectedDevice";

NSNotificationName const YPBLEManager_BleOperationStateDidChange  = @"YPBLEManagerBleOperationStateDidChange";
NSNotificationName const YPBLEManager_BleOperationError  = @"YPBLEManagerBleOperationError";

NSNotificationName const YPBLEDevice_DidDiscoverServices         = @"YPDeviceDidDiscoverServices";
NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics  = @"YPDeviceDidDiscoverCharacteristics";
NSNotificationName const YPBLEDevice_DidUpdateValue              = @"YPDeviceDidUpdateValue";
NSNotificationName const YPBLEDevice_DidWriteValue               = @"YPDeviceDidWriteValue";

/* BLEOpError Description
 */
NSString * BLEOpErrorGetDescription(BLEOpErrorCode error) {
    switch (error) {
        case BLEOpErrorUnsupported:
            return @"Unsupported";
        case BLEOpErrorUnauthorized:
            return @"Unauthorized";
        case BLEOpErrorNotFound:
            return @"NotFound";
            break;
        case BLEOpErrorScanInterrupted:
            return @"ScanInterrupted";
            break;
        case BLEOpErrorConnectionFailed:
            return @"FailToConnect";
            break;
        case BLEOpErrorDisconnected:
            return @"Disconnected";
            break;
        default:
            break;
    }
    return nil;
}

NSString * BLEOpErrorGetDetailDescription(BLEOpErrorCode error) {
    switch (error) {
        case BLEOpErrorUnsupported:
            return @"Bluetooth Unsupported";
        case BLEOpErrorUnauthorized:
            return @"Bluetooth Authorization Denied";
        case BLEOpErrorNotFound:
            return @"Bluetooth can't find any peripheral";
            break;
        case BLEOpErrorScanInterrupted:
            return @"Scan interrupted. (Bluetooth become off when it is scanning.)";
            break;
        case BLEOpErrorConnectionTimeout:
            return @"Connection has timeout";
            break;
        case BLEOpErrorConnectionFailed:
            return @"Bluetooth fail to connection";
            break;
        case BLEOpErrorDisconnected:
            return @"Connection interrupted. (Bluetooth become off when it is connecting or has been connected.)";
            break;
        default:
            break;
    }
    return nil;
}

NSString * CBManagerStateGetDescription(CBManagerState state) {
    NSString * desc;
    switch (state) {
        case CBManagerStatePoweredOff:
            desc = @"Bluetooth is powered off";
            break;
        case CBManagerStatePoweredOn:
            desc = @"Bluetooth is powered on and ready";
            break;
        case CBManagerStateResetting:
            desc = @"Bluetooth is resetting";
            break;
        case CBManagerStateUnsupported:
            desc = @"Bluetooth is unsupported";
            break;
        case CBManagerStateUnauthorized:
            desc = @"Bluetooth is unauthorized";
            break;
        case CBManagerStateUnknown:
            desc = @"Bluetooth is unknown";
            break;
        default:
            desc = @"Unknown state";
            break;
    }
    return desc;
}

/* Nordic UART Service */
NSString * const NordicUARTServiceUUIDString = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400001B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTTxCharacteristicUUIDString = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400002B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTRxCharacteristicUUIDString = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400003B5A3F393E0A9E50E24DCCA9E

/* Legacy DFU */
NSString * const LegacyDFUServiceUUIDString      = @"00001530-1212-EFDE-1523-785FEABCD123";
NSString * const LegacyDFUControlPointUUIDString = @"00001531-1212-EFDE-1523-785FEABCD123";
NSString * const LegacyDFUPacketUUIDString       = @"00001532-1212-EFDE-1523-785FEABCD123";
NSString * const LegacyDFUVersionUUIDString      = @"00001534-1212-EFDE-1523-785FEABCD123";

/* Secure DFU */
NSString * const SecureDFUServiceUUIDString      = @"FE59";
NSString * const SecureDFUControlPointUUIDString = @"8EC90001-F315-4F60-9FB8-838830DAEA50";
NSString * const SecureDFUPacketUUIDString       = @"8EC90002-F315-4F60-9FB8-838830DAEA50";

/* Buttonless DFU */
NSString * const ButtonlessDFUServiceUUIDString        = @"8E400001-F315-4F60-9FB8-838830DAEA50";
// The same UUID as the service
NSString * const ButtonlessDFUCharacteristicUUIDString = @"8E400001-F315-4F60-9FB8-838830DAEA50";

NSString * const ButtonlessDFUWithoutBondsUUIDString = @"8EC90003-F315-4F60-9FB8-838830DAEA50";
NSString * const ButtonlessDFUWithBondsUUIDString    = @"8EC90004-F315-4F60-9FB8-838830DAEA50";
