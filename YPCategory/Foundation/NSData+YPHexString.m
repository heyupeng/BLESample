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
    // strtol() or 取字符ascii值计算
    for (int i = 0; i < hexString.length; i += 2) {
        NSRange range = NSMakeRange(i, 2);
        NSString * str1 = [hexString substringWithRange:range];
        const char * cstr = [str1 cStringUsingEncoding:NSUTF8StringEncoding];
        char ch = strtol(cstr, nil, 16);
        [mdata appendBytes:&ch length:1];
    }
    
    return mdata;
}


/**
 way 1:
     NSString * string = data.description;
     // 去除 <>
     // string = [[string substringToIndex:string.length -1 ] substringFromIndex:1];
     string = [string stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
     // 去除 space
     string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
     return string;
 
 */
- (NSString *)hexString {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    
    NSMutableString * hexString = [[NSMutableString alloc] initWithCapacity:length * 2];
    
    for (int i = 0; i < length; i ++) {
        UInt8 byte = bytes[i];
        [hexString appendFormat:@"%02x", byte];
    }
    
    return hexString;
}

- (NSString *)ASCIIString {
//    return [[NSString alloc] initWithData:self encoding:NSASCIIStringEncoding];
    
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    
    NSMutableString * hexString = [[NSMutableString alloc] initWithCapacity:length];
    
    for (int i = 0; i < length; i ++) {
        UInt8 byte = bytes[i];
        [hexString appendFormat:@"%c", byte];
    }
    
    return hexString;
}

- (NSArray<NSNumber *> *)hexArray {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    
    if (length < 1) {return @[];}
    
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:length];
    for (int i = 0; i < length; i ++) {
        UInt8 byte = bytes[i];
        [array addObject:[NSNumber numberWithUnsignedChar:byte]];
    }
    
    return array;
}

- (NSInteger)hexIntegerValue {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    
    NSInteger value = 0;
    for (int i = 0; i < length; i ++) {
        Byte byte = bytes[i];
        value = (value << 8) + byte;
        
        if ((value << 8) > NSIntegerMax) {
            break;
        }
    }
    
    return value;
}

- (long long)hexLongLongValue {
    Byte * bytes = (Byte *)[self bytes];
    NSInteger length = [self length];
    long long  value = 0;
    
    for (int i = 0; i < length; i ++) {
        Byte byte = bytes[i];
        value = (value << 8) + byte;
        
        if ((value << 8) > LONG_LONG_MAX) {
            break;
        }
    }
    
    return value;
}

@end
