//
//  YPBlueConst.m
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "YPBlueConst.h"

NSNotificationName const YPBLEManager_DidUpdateState           = @"YPBlueManagerDidUpdateState";
NSNotificationName const YPBLEManager_ReceiveDevices           = @"YPBlueManagerReceiveDevices";
NSNotificationName const YPBLEManager_DidDiscoverDevice        = @"YPBlueManagerDiscoverDevice";
NSNotificationName const YPBLEManager_DidConnectedDevice       = @"YPBlueManagerConnectedDevice";
NSNotificationName const YPBLEManager_DidDisconnectedDevice    = @"YPBlueManagerDisconnectedDevice";
NSNotificationName const YPBLEManager_BluetoothOperationError  = @"YPBluetoothOperationError";

NSNotificationName const YPBLEDevice_DidDiscoverServices         = @"YPDeviceDidDiscoverServices";
NSNotificationName const YPBLEDevice_DidDiscoverCharacteristics  = @"YPDeviceDidDiscoverCharacteristics";
NSNotificationName const YPBLEDevice_DidUpdateValue              = @"YPDeviceDidUpdateValue";
NSNotificationName const YPBLEDevice_DidWriteValue               = @"YPDeviceDidWriteValue";

/*
 Nordic UART Service
 */
NSString * const NordicUARTServiceUUIDString = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400001B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTTxCharacteristicUUIDString = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400002B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTRxCharacteristicUUIDString = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400003B5A3F393E0A9E50E24DCCA9E

