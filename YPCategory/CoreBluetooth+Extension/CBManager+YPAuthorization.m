//
//  CBManager+YPAuthorization.m
//  BLESample
//
//  Created by Mac on 2020/10/20.
//  Copyright © 2020 heyupeng. All rights reserved.
//

#import "CBManager+YPAuthorization.h"

#define __VAR_NAME(value) (@#value)

#define __ENUM_VALUE_NAME(value) __VAR_NAME(value)

#define __ENUM_CASE(value) case value: __str = __ENUM_VALUE_NAME(value);
#define __ENUM_CASE_RETURN_STRING(value) case value: return __ENUM_VALUE_NAME(value);


#define __ENUM_STRCMP_NAME(name,value) \
if ([name isEqualToString:__ENUM_VALUE_NAME(value)]) return value;
#define __ENUM_STRCMP(value) __ENUM_STRCMP_NAME(string, value)

/*
#define __FUNC(func, param) func(param)
#define __FUNC_PARAMS1(a,b) __FUNC(a, b)
#define __FUNC_PARAMS2(a,b,...) __FUNC(a, b) __FUNC_PARAMS1(a, __VA_ARGS__)
#define __FUNC_PARAMS3(a,b,...) __FUNC(a, b) __FUNC_PARAMS2(a, __VA_ARGS__)
#define __FUNC_PARAMS4(a,b,...) __FUNC(a, b) __FUNC_PARAMS3(a, __VA_ARGS__)
#define __FUNC_PARAMS5(a,b,...) __FUNC(a, b) __FUNC_PARAMS4(a, __VA_ARGS__)
#define __FUNC_PARAMS6(a,b,...) __FUNC(a, b) __FUNC_PARAMS5(a, __VA_ARGS__)
#define __FUNC_PARAMS7(a,b,...) __FUNC(a, b) __FUNC_PARAMS6(a, __VA_ARGS__)
#define __FUNC_PARAMS_GET_MACRO(_1,_2,_3,_4,_5,_6,_7,NAME,...) NAME

#define __FUNC_PARAMS(func, ...) \
    __FUNC_PARAMS_GET_MACRO(__VA_ARGS__, __FUNC_PARAMS7, __FUNC_PARAMS6,__FUNC_PARAMS5,__FUNC_PARAMS4,__FUNC_PARAMS3,__FUNC_PARAMS2,__FUNC_PARAMS1, 0) \
    (func, __VA_ARGS__)

#define __ENUM_STRING_IMPL__(value, EnumValue, ...) ({\
    NSString * __str = @"Unknown"; \
    switch (value) { \
    __FUNC_PARAMS(__ENUM_CASE, EnumValue, __VA_ARGS__) ;\
        default: \
            break;\
    }\
    __str;\
})
#define __NSStringFromEnumValue(value, EnumValue, ...) __ENUM_STRING_IMPL__(value, EnumValue,__VA_ARGS__)
*/

#define DEFINE_ENUM_STRING_TRANSFROMATION_IPMPL(EnumType, DECLARE_ENUM) \
NSString *NSStringFrom##EnumType(EnumType value) \
{\
switch (value) { \
DECLARE_ENUM(__ENUM_CASE_RETURN_STRING); \
    default: \
        break; \
}\
return @"Unknown"; \
}\
\
EnumType EnumType##FromNSString(NSString *string) \
{ \
DECLARE_ENUM(__ENUM_STRCMP); \
return (EnumType)0;\
}

@implementation CBManager (YPAuthorization)


#define DECLARE_ENUM_CBManagerAuthorization(FUNC) \
FUNC(CBManagerAuthorizationNotDetermined)\
FUNC(CBManagerAuthorizationRestricted)\
FUNC(CBManagerAuthorizationDenied)\
FUNC(CBManagerAuthorizationAllowedAlways)\

DEFINE_ENUM_STRING_TRANSFROMATION_IPMPL(CBManagerAuthorization, DECLARE_ENUM_CBManagerAuthorization);

//NSString *NSStringFromCBManagerAuthorization(CBManagerAuthorization value) {
//    NSString * __str = @"Unknown";
//    switch (value) {
//            __ENUM_CASE(CBManagerAuthorizationNotDetermined);
//            __ENUM_CASE(CBManagerAuthorizationRestricted);
//            __ENUM_CASE(CBManagerAuthorizationDenied);
//            __ENUM_CASE(CBManagerAuthorizationAllowedAlways);
//        default:
//            break;
//    }
//    return __str;
//}
//
//CBManagerAuthorization CBManagerAuthorizationFromNSString(NSString * string) {
//    __ENUM_STRCMP(CBManagerAuthorizationNotDetermined);
//    __ENUM_STRCMP(CBManagerAuthorizationRestricted);
//    __ENUM_STRCMP(CBManagerAuthorizationDenied);
//    __ENUM_STRCMP(CBManagerAuthorizationAllowedAlways);
//    return -999;
//}

+ (CBManagerAuthorization)yp_authorization {
#ifdef __IPHONE_13_0
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
//    if ([systemVersion floatValue] >= 13.0) {
        CBManagerAuthorization authorization;
#ifdef __IPHONE_13_1
        NSLog(@"iPhone OS Version: >= 13.1");
        authorization = [CBManager authorization];
#else
        NSLog(@"iPhone OS Version: = 13.0");
        authorization = [[CBCentralManager alloc] init].authorization;
#endif
        NSString * str = NSStringFromCBManagerAuthorization(authorization);
        NSLog(@"%@ = %zi", str, authorization);
        return authorization;
//    } else
#else
    {
        NSLog(@"iPhone OS Version: < 13.0");
        CBPeripheralManagerAuthorizationStatus authorization = [CBPeripheralManager authorizationStatus];
        NSString * str = NSStringFromCBManagerAuthorization(authorization);
        NSLog(@"%@ = %zi", str, authorization);
        return authorization;
    }
#endif
    return 0;
}

@end
