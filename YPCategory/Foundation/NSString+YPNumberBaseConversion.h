//
//  NSString+YPNumberBaseConversion.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (YPNumberBaseConversion)

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
+ (NSString *)hexStringByDecimalString:(NSString *)decimalString;

/**
 Convert decimal string to hex string 十进制字符串转二进制字符串
 */
+ (NSString *)decimalToBinary:(NSString *)decimalString;

- (NSString *)hexToDecimal;

- (NSString *)hexToBinary;

- (NSString *)decimalToHex;

- (NSString *)decimalToBinary;

- (NSString *)binaryToHex;

- (NSString *)binaryToDecimal;

@end

NS_ASSUME_NONNULL_END
