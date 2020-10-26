//
//  CBManager+YPAuthorization.h
//  BLESample
//
//  Created by Mac on 2020/10/20.
//  Copyright © 2020 heyupeng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBManager (yp_Authorization)

#define DECLARE_ENUM_STRING_TRANSFORMATION(EnumType) \
NSString *NSStringFrom##EnumType(EnumType value); \
EnumType EnumType##FromNSString(NSString *string); \

#ifndef __IPHONE_13_0
typedef NS_ENUM(NSInteger, CBManagerAuthorization) {
    CBManagerAuthorizationNotDetermined = 0,
    CBManagerAuthorizationRestricted,
    CBManagerAuthorizationDenied,
    CBManagerAuthorizationAllowedAlways
}
#endif


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"

DECLARE_ENUM_STRING_TRANSFORMATION(CBManagerAuthorization)

/// 对 CBManager.authorization 的低版本兼容
+ (CBManagerAuthorization)yp_authorization;

#pragma clang diagnostic push

@end

NS_ASSUME_NONNULL_END
