//
//  NSString+YPHexString.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "NSString+YPHexString.h"

@implementation NSString (YPHexString)

void decToBin(int num, char *buffer) {
    if(num>0) {
        decToBin(num/2,buffer+1);
        *buffer = (char)(num%2+48);
    }
}

// 16进制字符串转二进制数据流
+(NSData*)hexStringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}


/**
 Convert hex to decimal 16进制字符串转long型数字
 */
+ (long)hexStringToLongValue: (NSString *)hexString {
    const char * cstr = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    return strtol(cstr, nil, 16);
}

// 16进制字符串转char字符串
+ (NSString *)hexStringToCharString:(NSString *)hexString {
    if (hexString.length % 2 == 1) {
        return @"";
    }
    
    NSString * string = @"";
    for (int i = 0; i < hexString.length; i += 2) {
        NSRange range = NSMakeRange(i, 2);
        NSString * s = [hexString substringWithRange:range];
        unichar ch = [NSString hexStringToLongValue:s];
        
        string = [string stringByAppendingString: [NSString stringWithFormat:@"%c", ch]];
    }
    return string;
}

+ (NSString *)charStringFromHexString:(NSString *)hexString {
    NSString * str = @"";
    NSMutableData * mdata = [NSMutableData new];

    for (int i = 0; i < hexString.length; i+=2) {
        NSString * s = [hexString substringWithRange:NSMakeRange(i, 2)];
        const char * cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];
        unichar  ch = strtoll(cstr, nil, 16);
        
        [mdata appendBytes:&ch length:1];
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%c",ch & 0xff]];
    }
    return str;
}

// unichar字符串转16进制字符串
+ (NSString *)hexStringFromCharString:(NSString *)string {
    NSString * str = @"";
    for (int i = 0; i < string.length; i++) {
        unichar ch = [string characterAtIndex:i];
        NSString * cs = [NSString stringWithFormat:@"%.2x",ch & 0xff];
        str = [str stringByAppendingString:cs];
    }
    return str;
}

- (long)hexStringToLongValue {
    const char * cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    return strtol(cstr, nil, 16);
}

- (NSString *)hexStringToCharString {
    return [NSString charStringFromHexString:self];
}

- (NSString *)charStringToHexString {
    return [NSString hexStringFromCharString:self];
}

@end


@implementation NSString(YPHexReverse)
// 16进制字符串的倒序 @"ade2" => @"e2ad" | @"ade23faa" => @"aa3fe2ad" | @"ade23faa55d3" => @"d355aa3fe2ad"
+ (NSString *)hexStringReverse:(NSString *)hexString {
    if (hexString.length % 2 == 1) {
        return @"";
    }
    
    NSString * string = @"";
    for (int i = 0; i < hexString.length; i += 2) {
        NSString * str1 = [hexString substringWithRange:NSMakeRange(hexString.length - 1 - 1 -i, 2)];
        string = [string stringByAppendingString: str1];
    }
    return string;
}

- (NSString *)hexStringReverse {
    return  [NSString hexStringReverse:self];
}

@end


