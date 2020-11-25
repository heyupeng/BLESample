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
- (NSData *)yp_hexStringToBytes;

/// 16进制字符串转long型数字
- (long)yp_hexStringToLongValue;

// 16进制字符串转char字符串
+ (NSString *)charStringFromHexString:(NSString *)hexString;

// char字符串转16进制字符串
+ (NSString *)hexStringFromCharString:(NSString *)string;

- (NSString *)hexStringToCharString;

- (NSString *)charStringToHexString;

@end


/*
 16进制字符串高低位互换
 */
@interface NSString (YPHexReverse)

// 16进制字符串的倒序 @"ade2" => @"e2ad" | @"ade23faa" => @"aa3fe2ad" | @"ade23faa55d3" => @"d355aa3fe2ad"
+ (NSString *)hexStringReverse:(NSString *)hexString;

- (NSString *)hexStringReverse;

@end
