//
//  YPBlueConst.m
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "YPBlueConst.h"

NSString * const YPBLE_DidUpdateState           = @"YPBlueManagerDidUpdateState";
NSString * const YPBLE_ReceiveDevices           = @"YPBlueManagerReceiveDevices";
NSString * const YPBLE_DidDiscoverDevice        = @"YPBlueManagerDiscoverDevice";
NSString * const YPBLE_DidConnectedDevice       = @"YPBlueManagerConnectedDevice";
NSString * const YPBLE_DidDisconnectedDevice    = @"YPBlueManagerDisconnectedDevice";

NSString * const YPDevice_DidDiscoverServices         = @"YPDeviceDidDiscoverServices";
NSString * const YPDevice_DidDiscoverCharacteristics  = @"YPDeviceDidDiscoverCharacteristics";
NSString * const YPDevice_DidUpdateValue              = @"YPDeviceDidUpdateValue";
NSString * const YPDevice_DidWriteValue               = @"YPDeviceDidWriteValue";

/*
 Nordic UART Service
 */
NSString * const NordicUARTServiceUUID = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400001B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTServiceTxCharacteristicUUID = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400002B5A3F393E0A9E50E24DCCA9E
NSString * const NordicUARTServiceRxCharacteristicUUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"; // 0x6E400003B5A3F393E0A9E50E24DCCA9E

