//
//  NSString+YPNumberBaseConversion.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "NSString+YPNumberBaseConversion.h"

@implementation NSString (YPNumberBaseConversion)

/**
 Convert hex string to decimal string 16进制字符串转十进制字符串
 */
+ (NSString *)decimalStringByHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    const char * cstr = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    long value = strtol(cstr, nil, 16);
    return [NSString stringWithFormat:@"%ld",value];
}

/**
 Convert hex string to binary string 16进制字符串转二进制字符串
 */
+ (NSString *)binaryStringByHexString:(NSString *)hexString {
    hexString = [hexString lowercaseString];
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([hexString hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    
    NSMutableDictionary  *hexDict = [[NSMutableDictionary alloc] init];
    [hexDict setObject:@"0000" forKey:@"0"];
    [hexDict setObject:@"0001" forKey:@"1"];
    [hexDict setObject:@"0010" forKey:@"2"];
    [hexDict setObject:@"0011" forKey:@"3"];
    [hexDict setObject:@"0100" forKey:@"4"];
    [hexDict setObject:@"0101" forKey:@"5"];
    [hexDict setObject:@"0110" forKey:@"6"];
    [hexDict setObject:@"0111" forKey:@"7"];
    [hexDict setObject:@"1000" forKey:@"8"];
    [hexDict setObject:@"1001" forKey:@"9"];
    [hexDict setObject:@"1010" forKey:@"a"];
    [hexDict setObject:@"1011" forKey:@"b"];
    [hexDict setObject:@"1100" forKey:@"c"];
    [hexDict setObject:@"1101" forKey:@"d"];
    [hexDict setObject:@"1110" forKey:@"e"];
    [hexDict setObject:@"1111" forKey:@"f"];
    
    NSMutableString *binaryString=[[NSMutableString alloc] init];
    
    for (int i=0; i<[hexString length]; i++) {
        
        NSRange rage;
        rage.length = 1;
        rage.location = i;

        NSString *key = [hexString substringWithRange:rage];
        
        [binaryString appendString:[hexDict objectForKey:key]];
    }
    
    // 去除前缀的0
    NSRange range = [binaryString rangeOfString:@"1" options:NSNumericSearch];
    if (range.location != NSNotFound) {
        [binaryString deleteCharactersInRange:NSMakeRange(0, range.location)];
    }
    //NSLog(@"转化后的二进制为:%@",binaryString);
    return binaryString;
}

/**
 Convert binary string to decimal string 二进制字符串转十进制字符串
 */
+ (NSString *)decimalStringByBinaryString:(NSString *)binaryString {
    binaryString = [binaryString stringByReplacingOccurrencesOfString:@" " withString:@""];
    binaryString = [binaryString lowercaseString];

    const char * cstr = [binaryString cStringUsingEncoding:NSUTF8StringEncoding];
    long value = strtol(cstr, nil, 2);
    return [NSString stringWithFormat:@"%ld",value];
}

/**
 Convert binary string to hex string 二进制字符串转十六进制字符串
 */
+ (NSString *)hexStringByBinaryString:(NSString *)binaryString {
    binaryString = [binaryString stringByReplacingOccurrencesOfString:@" " withString:@""];
    binaryString = [binaryString lowercaseString];

//    if (binaryString.length % 4 != 0) {
//        NSMutableString *b = [[NSMutableString alloc]init];;
//        for (int i = 0; i < 4 - binaryString.length % 4; i++) {
//            [b appendString:@"0"];
//        }
//
//        binaryString = [b stringByAppendingString:binaryString];
//    }
    
    const char * cstr = [binaryString cStringUsingEncoding:NSUTF8StringEncoding];
    long value = strtol(cstr, nil, 2);
    return [NSString stringWithFormat:@"%lx",value];
}

/**
 Convert decimal string to binary string 十进制字符串转二进制字符串
 */
+ (NSString *)decimalToBinary:(NSString *)decimalString {
    long long decimal = [decimalString longLongValue];
    NSString *bin = @"";

    while (decimal) {
        bin = [[NSString stringWithFormat:@"%lld",decimal%2] stringByAppendingString:bin];
        if (decimal/2 < 1) {
            break;
        }
        decimal = decimal/2 ;
    }
    
    // 不足四位补足
//    if (bin.length % 4 != 0) {
//        NSMutableString *b = [[NSMutableString alloc]init];;
//        for (int i = 0; i < 4 - bin.length % 4; i++) {
//            [b appendString:@"0"];
//        }
//
//        bin = [b stringByAppendingString:bin];
//    }
    return bin;
}

/**
 Convert decimal string to hex string 十进制字符串转十六进制字符串
 */
+ (NSString *)hexStringByDecimalString:(NSString *)decimalString {
    long long decimal = [decimalString longLongValue];
    NSString * hex =@"";

    // way 1
    hex = [NSString stringWithFormat:@"%llx", [decimalString longLongValue]];
    return hex;
    
    // way 2
    uint16_t quotient;
    NSString *qLetterValue;
    
    for (int i = 0; i<9; i++) {
        quotient = decimal % 16;
        decimal = decimal / 16;
        switch (quotient) {
            case 10:
                qLetterValue =@"a";break;
            case 11:
                qLetterValue =@"b";break;
            case 12:
                qLetterValue =@"c";break;
            case 13:
                qLetterValue =@"d";break;
            case 14:
                qLetterValue =@"e";break;
            case 15:
                qLetterValue =@"f";break;
            default:
                qLetterValue = [NSString stringWithFormat:@"%u",quotient];
                
        }
        hex = [qLetterValue stringByAppendingString:hex];
        if (decimal == 0) {
            break;
        }
        
    }
    return hex;
}

- (NSString *)hexToDecimal {
    return [NSString decimalStringByHexString:self];
}

- (NSString *)hexToBinary {
    return [NSString binaryStringByHexString:self];
}

- (NSString *)decimalToHex {
    return [NSString hexStringByDecimalString:self];
}

- (NSString *)decimalToBinary {
    return [NSString decimalToBinary:self];
}

- (NSString *)binaryToHex {
    return [NSString hexStringByBinaryString:self];
}

- (NSString *)binaryToDecimal {
    return [NSString decimalStringByBinaryString:self];
}

@end
