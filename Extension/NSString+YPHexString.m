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


+ (NSData *)dataFromHexString:(NSString *)hexString {
    hexString=[hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (hexString.length % 2 == 1) {
        return nil;
    }
    
    NSMutableData * mdata = [NSMutableData new];

    for (int i = 0; i < hexString.length; i += 2) {
        NSRange range = NSMakeRange(i, 2);
        NSString * str1 = [hexString substringWithRange:range];
        char ch = strtol([str1 cStringUsingEncoding:NSUTF8StringEncoding], nil, 16);
        [mdata appendBytes:&ch length:1];
    }
    return mdata;
}

// 二进制数据流转16进制字符串
+ (NSString *)hexStringFromData:(NSData *)data {
    Byte *bytes = (Byte *)[data bytes];
    
    NSString * hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%.2x",bytes[i]&0xff];//16进制数
        hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

// 16进制字符串的倒序 ade2 => e2ad | ade23faa55d3 => d355aa3fe2ad
+ (NSString *)hexStringReverse:(NSString *)originString {
    if (originString.length % 2 == 1) {
        return @"";
    }
    
    NSString * string = @"";
    for (int i = 0; i < originString.length; i += 2) {
        NSString * str1 = [originString substringWithRange:NSMakeRange(originString.length - 1 - 1 -i, 2)];
        string = [string stringByAppendingString: str1];
    }
    return string;
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

/********************/
#pragma mark - - 方法
- (NSString *)hexStringReverse {
    return  [NSString hexStringReverse:self];
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

#pragma mark - 循环冗余码校验
- (NSString *)checkCRC16 {
    NSData * Bytes = [NSString hexStringToByte:self];
    Byte * bytes = (unsigned char*)[Bytes bytes];
    
    uint16_t crcPoly = 0x1021;
    uint32_t crcSize = 0x06;
    int code ;//= crc16_compute((unsigned char*)bytes, crcSize, &crcPoly);
    
    return [NSString stringWithFormat:@"%.4x", code];
}

//// 校验程式 - 循环冗余码校验
//uint16_t crc16_compute(const uint8_t * p_data, uint32_t size, const uint16_t * p_crc)
//{
//    uint32_t i;
//    uint16_t crc = (p_crc == NULL) ? 0xffff : *p_crc;
//    
//    for (i = 0; i < size; i++)
//    {
//        crc  = (unsigned char)(crc >> 8) | (crc << 8);
//        crc ^= p_data[i];
//        crc ^= (unsigned char)(crc & 0xff) >> 4;
//        crc ^= (crc << 8) << 4;
//        crc ^= ((crc & 0xff) << 4) << 1;
//    }
//    return crc;
//}

@end


@implementation NSString(YPHexConverter)

///**
// Convert hex to decimal 16进制字符串转long型数字
// */
//+ (long)hexStringToLongValue: (NSString *)hexString {
//    const char * cstr = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
//    return strtol(cstr, nil, 16);
//}

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
+ (NSString *)decimalToHex:(NSString *)decimalString {
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

- (NSString *)hexStringToDecimalString {
    return [NSString decimalStringByHexString:self];
}

- (NSString *)hexStringToBinaryString {
    return [NSString binaryStringByHexString:self];
}

- (NSString *)decimalStringToHexString {
    return [NSString decimalToHex:self];
}

- (NSString *)decimalStringToBinaryString {
    return [NSString decimalToBinary:self];
}

- (NSString *)binaryToHex {
    return [NSString hexStringByBinaryString:self];
}

- (NSString *)binaryToDecimal {
    return [NSString decimalStringByBinaryString:self];
}
@end

