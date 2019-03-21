//
//  NSData+YPHexString.m
//  YPDemo
//
//  Created by Peng on 2019/3/11.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import "NSData+YPHexString.h"

@implementation NSData (YPHexString)

+ (NSData *)dataWithHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    
    if (hexString.length % 2 == 1) {
        return nil;
    }
    
    NSMutableData * mdata = [NSMutableData new];
    
    for (int i = 0; i < hexString.length; i += 2) {
        NSRange range = NSMakeRange(i, 2);
        NSString * str1 = [hexString substringWithRange:range];
        const char * cstr = [str1 cStringUsingEncoding:NSUTF8StringEncoding];
        char ch = strtol(cstr, nil, 16);
        [mdata appendBytes:&ch length:1];
    }
    
    return mdata;
}

- (NSString *)hexString {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    
//    NSString * hexString = @"";
//    for(int i = 0; i < length; i++) {
//        NSString *sample = [NSString stringWithFormat:@"%.2x",bytes[i]&0xff]; //16进制数
//        hexString = [NSString stringWithFormat:@"%@%@",hexString,sample];
//    }
    
    NSMutableString * hexString = [[NSMutableString alloc] initWithCapacity:length * 2];
    
    for (int i = 0; i < length; i ++) {
        UInt8 byte = bytes[i];
        [hexString appendFormat:@"%02x", byte&0xff];
    }
    
    return hexString;
}

- (NSInteger)hexIntergerValue {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    
    NSInteger value = 0;
    for (int i = 0; i < length; i ++) {
        Byte byte = bytes[i];
        value = value * 16 + byte;
        
        if (value * 16 > NSIntegerMax) {
            break;
        }
    }
    
    return value;
}

- (NSInteger)hexLongLongValue {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    NSInteger value = 0;
    
    for (int i = 0; i < length; i ++) {
        Byte byte = bytes[i];
        value = value * 16 + byte;
        
        if (value * 16 > LONG_LONG_MAX) {
            break;
        }
    }
    
    return value;
}

@end
