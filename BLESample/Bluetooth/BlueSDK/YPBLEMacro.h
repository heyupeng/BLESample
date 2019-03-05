//
//  YPBLEMacro.h
//  YPDemo
//
//  Created by Peng on 2018/4/19.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

UIKIT_EXTERN  NSNotificationName const YPBLE_DidUpdateState;
UIKIT_EXTERN  NSNotificationName const YPBLE_ReceiveDevices;
UIKIT_EXTERN  NSNotificationName const YPBLE_DidDiscoverDevice;
UIKIT_EXTERN  NSNotificationName const YPBLE_DidConnectedDevice;
UIKIT_EXTERN  NSNotificationName const YPBLE_DidDisconnectedDevice;

UIKIT_EXTERN NSNotificationName const YPDevice_DidDiscoverServices;
UIKIT_EXTERN NSNotificationName const YPDevice_DidDiscoverCharacteristics;
UIKIT_EXTERN NSNotificationName const YPDevice_DidUpdateValue;
UIKIT_EXTERN NSNotificationName const YPDevice_DidWriteValue;
