//
//  Enumability.h
//  YPDemo
//
//  Created by Peng on 2020/10/19.
//  Copyright © 2020 heyupeng. All rights reserved.
//

#ifndef Enumability_h
#define Enumability_h

/**
 * Enum To String.
 * 使用方法：
 * *.h
 * DECLARE_ENUM_VALUE_STRING_TRANSFORMATION(EnumType);
 * *.m
 * DEFINE_ENUM_VALUE_STRING_TRANSFORMATION_IMPL(EnumType, EnumRaw0, EnumRaw1);
 *
 * 示例：
 *  .h
 *  DECLARE_ENUM_VALUE_STRING_TRANSFORMATION(CBManagerAuthorization);
 *  .m
 *  DEFINE_ENUM_VALUE_STRING_TRANSFORMATION_IMPL(CBManagerAuthorization,CBManagerAuthorizationNotDetermined,
 *  CBManagerAuthorizationRestricted,CBManagerAuthorizationDenied,CBManagerAuthorizationAllowedAlways);
 *
 * @参考自  https://github.com/Yannmm/OC-Enum-String-Convertible-Example
 *
 */

#ifdef __cplusplus
#define ENUM_EXTERN        extern "C" __attribute__((visibility ("default")))
#else
#define ENUM_EXTERN            extern __attribute__((visibility ("default")))
#endif

#ifndef ENUM_VALUE_NAME_STRING
#define VAR_NAME_STRING(VALUE) (@#VALUE)
#define ENUM_VALUE_NAME_STRING(VALUE) VAR_NAME_STRING(VALUE)
#endif

#define __ENUM_CASE_RETURN_STRING(value) case value: return ENUM_VALUE_NAME_STRING(value);

#define __ENUM_STRCMP_NAME(name,value) \
if ([name isEqualToString:ENUM_VALUE_NAME_STRING(value)]) return value;
#define __ENUM_STRCMP(value) __ENUM_STRCMP_NAME(string, value)


#ifndef DECLARE_ENUM_VALUE_STRING_TRANSFORMATION
/// 枚举转化函数声明。
#define DECLARE_ENUM_VALUE_STRING_TRANSFORMATION(EnumType) \
ENUM_EXTERN NSString *NSStringFrom##EnumType(EnumType value); \
ENUM_EXTERN EnumType EnumType##FromNSString(NSString *string); \

#endif

#ifndef DEFINE_ENUM_VALUE_STRING_TRANSFORMATION_IMPL
/// 枚举转化函数实现。ENUM RAW COUNTS LESS TRAN OR EQUAL TO 20.
#define DEFINE_ENUM_VALUE_STRING_TRANSFORMATION_IMPL(EnumType, ...) \
NSString *NSStringFrom##EnumType(EnumType value) \
{\
switch (value) { \
__API_FUNC_PARAMS(__ENUM_CASE_RETURN_STRING, __VA_ARGS__); \
    default: \
        break; \
}\
return @"Unknown"; \
}\
\
EnumType EnumType##FromNSString(NSString *string) \
{ \
__API_FUNC_PARAMS(__ENUM_STRCMP, __VA_ARGS__); \
return (EnumType)0;\
}\
\
NSString *NSStringFrom##EnumType##WithoutPrefix(EnumType value) \
{\
NSString * str = NSStringFrom##EnumType(value); \
NSString * type = ENUM_VALUE_NAME_STRING(EnumType); \
if ([str hasPrefix:type]) { \
str = [str substringFromIndex:type.length]; \
}\
return str; \
}\

#endif


#define __API_FUNC_PARAMS(FUNC, ...) __API_FUNC_PARAMS_GET_MARCRO(__VA_ARGS__, 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)(FUNC, __VA_ARGS__)

/// __API_FUNC_PARAMS
#define __API_FUNC_(func, param) func(param)
#define __API_FUNC_PARAMS0(...)
#define __API_FUNC_PARAMS1(a,b) __API_FUNC_(a, b)
#define __API_FUNC_PARAMS2(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS1(a, __VA_ARGS__)
#define __API_FUNC_PARAMS3(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS2(a, __VA_ARGS__)
#define __API_FUNC_PARAMS4(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS3(a, __VA_ARGS__)
#define __API_FUNC_PARAMS5(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS4(a, __VA_ARGS__)
#define __API_FUNC_PARAMS6(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS5(a, __VA_ARGS__)
#define __API_FUNC_PARAMS7(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS6(a, __VA_ARGS__)
#define __API_FUNC_PARAMS8(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS7(a, __VA_ARGS__)
#define __API_FUNC_PARAMS9(a,b,...)  __API_FUNC_(a, b) __API_FUNC_PARAMS8(a, __VA_ARGS__)
#define __API_FUNC_PARAMS10(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS9(a, __VA_ARGS__)
#define __API_FUNC_PARAMS11(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS10(a, __VA_ARGS__)
#define __API_FUNC_PARAMS12(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS11(a, __VA_ARGS__)
#define __API_FUNC_PARAMS13(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS12(a, __VA_ARGS__)
#define __API_FUNC_PARAMS14(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS13(a, __VA_ARGS__)
#define __API_FUNC_PARAMS15(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS14(a, __VA_ARGS__)
#define __API_FUNC_PARAMS16(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS15(a, __VA_ARGS__)
#define __API_FUNC_PARAMS17(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS16(a, __VA_ARGS__)
#define __API_FUNC_PARAMS18(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS17(a, __VA_ARGS__)
#define __API_FUNC_PARAMS19(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS18(a, __VA_ARGS__)
#define __API_FUNC_PARAMS20(a,b,...) __API_FUNC_(a, b) __API_FUNC_PARAMS19(a, __VA_ARGS__)
#define __API_FUNC_PARAMS_GET_MARCRO(_1,_2,_3,_4,_5,_6,_7,_8,_9,_10,_11,_12,_13,_14,_15,_16,_17,_18,_19,_20, NAME,...) __API_FUNC_PARAMS##NAME


/// COUNT OF ARGS
#define __API_PARAMS_COUNT_GET_MARCRO(_1,_2,_3,_4,_5,_6,_7,_8,_9,_10,_11,_12,_13,_14,_15,_16,_17,_18,_19,_20, COUNT, ...) COUNT
#define __API_PARAMS_COUNT(...) __API_PARAMS_COUNT_GET_MARCRO(__VA_ARGS__, 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)

#endif /* Enumability_h */
