//
//  NSString+YPHexString.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YPHexString)

// 16进制字符串转二进制数据流 @"03000c0004000643" => <03000c00 04000643>
+ (NSData*)hexStringToByte:(NSString*)string;
+ (NSData *)dataFromHexString:(NSString *)hexString;

// 二进制数据流转16进制字符串 <03000c00 04000643> => @"03000c0004000643"
+ (NSString *)hexStringFromData:(NSData *)data;

// 16进制字符串的倒序 @"ade2" => @"e2ad"  | @"ade23faa55d3" => @"d355aa3fe2ad"
+ (NSString *)hexStringReverse:(NSString *)originString;

/**
 16进制字符串转long型数字
 */
+ (long)hexStringToLongValue: (NSString *)hexString;

// 16进制字符串转char字符串
+ (NSString *)hexStringToCharString:(NSString *)hexString;
+ (NSString *)charStringFromHexString:(NSString *)hexString;

// char字符串转16进制字符串
+ (NSString *)hexStringFromCharString:(NSString *)string;


- (NSString *)hexStringReverse;

- (long)hexStringToLongValue;

- (NSString *)hexStringToCharString;

- (NSString *)charStringToHexString;

#pragma mark - 循环冗余码校验
- (NSString *)checkCRC16;
@end


@interface NSString (YPHexConverter)

/**
 Convert hex to decimal 16进制字符串转十进制字符串
 */
+ (NSString *)decimalStringByHexString:(NSString *)hexString;

/**
 Convert hex to binary 16进制字符串转二进制字符串
 */
+ (NSString *)binaryStringByHexString:(NSString *)hexString;

/**
 Convert binary string to decimal string 二进制字符串转十进制字符串
 */
+ (NSString *)decimalStringByBinaryString:(NSString *)binaryString;

/**
 Convert binary string to hex string 二进制字符串转十六进制字符串
 */
+ (NSString *)hexStringByBinaryString:(NSString *)binaryString;

/**
 Convert decimal string to hex string 十进制字符串转十六进制字符串
 */
+ (NSString *)decimalToHex:(NSString *)decimalString;

/**
 Convert decimal string to hex string 十进制字符串转二进制字符串
 */
+ (NSString *)decimalToBinary:(NSString *)decimalString;

- (NSString *)hexStringToDecimalString;

- (NSString *)hexStringToBinaryString;

- (NSString *)decimalStringToHexString;

- (NSString *)decimalStringToBinaryString;

- (NSString *)binaryToHex;

- (NSString *)binaryToDecimal;
@end
