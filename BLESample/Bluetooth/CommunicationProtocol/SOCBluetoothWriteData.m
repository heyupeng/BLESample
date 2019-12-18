//
//  SOCBluetoothWriteData.m
//  SoocareInternational
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 soocare. All rights reserved.
//

#import "SOCBluetoothWriteData.h"

@implementation SOCBluetoothWriteData

int frameNumber_ = 0;
int frameNumber() {
    frameNumber_ ++;
    if (frameNumber_ > 255) { frameNumber_ = 0;}
    return frameNumber_;
}

#pragma mark - /******** 发送指令 *********/
+ (int)frameNumber {
    return frameNumber();
}

+ (NSString *)commandWithType:(NSString *)typeString appendData:(NSString *)appendString {
    NSString * str;
    if (typeString.length == 8) {
        NSString * frameString = [NSString stringWithFormat:@"%.4x", frameNumber()];
        str = [NSString stringWithFormat:@"%@%@",typeString,frameString];
        str = [self hexStringExchangeHighAndLow:str];
        
        str = [self getCheckStringWith:str];
        if (str) {
            str = [NSString stringWithFormat:@"%@%@",str,appendString];
        }
    }
    return [str lowercaseString];
}

+ (NSString *)commandWithType:(NSString *)typeString length:(NSString *)lengthHexString appendData:(NSString *)appendString {
    NSString * str;
    if (typeString.length == 4 && lengthHexString.length == 4) {
        NSString * frameString = [NSString stringWithFormat:@"%.4x", frameNumber()];
        str = [NSString stringWithFormat:@"%@%@%@",[typeString hexStringReverse], [lengthHexString hexStringReverse], [frameString hexStringReverse]];
        
        str = [self getCheckStringWith:str];
        if (str) {
            str = [NSString stringWithFormat:@"%@%@",str,appendString];
        }
    }
    return [str lowercaseString];
}


#pragma mark - 安全性校验
/*
 1.检查指令长度
 2.检查奇偶数
 3.检查非法字符
 4.生成校验码并返回
 5.返回yes或者no
 */
+ (NSString *)getCRCHexCodeWith:(NSString *)hexString {
    NSString * string;
    if (hexString.length %4 == 0 && hexString.length >= 12){
        // NSLog(@"校验数据正常,开始获得校验码\n");
        string = [self getCheckSum:hexString];
        if (string) {
//            NSLog(@"校验码获得成功\n");
        }else{
//            NSLog(@"获得校验码失败\n");
        }
    }else {
        
    }
    return string;
}

+ (NSString *)getCheckStringWith:(NSString *)sendString{
    NSString * string;
    if (sendString.length < 12 || sendString.length %2 != 0){
//        NSLog(@"非法字符串");
    }else {
//        NSLog(@"安全检查成功,开始获得校验码\n");
        string = [self getCheckSum:sendString];
        string = [sendString stringByAppendingString:string];
        if (string) {
//            NSLog(@"校验码获得成功\n");
        }else{
//            NSLog(@"获得校验码失败,请重新输入\n");
        }
    }
    return string;
}

+ (NSString *)hexStringExchangeHighAndLow:(NSString *)hexString {
    //根据坐标截取6字节字符串
    NSRange typeHigh = NSMakeRange(0, 4);
    NSRange lengthHigh = NSMakeRange(4, 4);
    NSRange frameHigh = NSMakeRange(8, 4);
    NSString * typeString = [hexString substringWithRange:typeHigh];
    NSString * lengthString = [hexString substringWithRange:lengthHigh];
    NSString * frameString = [hexString substringWithRange:frameHigh];
    
    //重新排列高低位
    NSArray * stringArray = @[[typeString hexStringReverse], [lengthString hexStringReverse], [frameString hexStringReverse]];
    NSString * sequenceString = @"";
    for (NSString * string in stringArray) {
        sequenceString = [sequenceString stringByAppendingString:string];
    }
    return sequenceString;
}
 
+ (NSString *)getCheckSum:(NSString *)hexString {
    
    //把16进制字符串转换成data
    NSMutableData * myData = [[NSMutableData alloc]init];
    [myData appendData:[NSData dataWithHexString:hexString]];

    //把data转换成byte
    Byte * checkSumByte = (Byte *)[myData bytes];
    
    //获取校验值
    uint16_t crcPoly = 0xffff ;//0x1021;
    uint32_t checkCode = crc16_compute(checkSumByte, 0x06, &crcPoly);
    
    NSString * checkSumString = [NSString stringWithFormat:@"%.4x",checkCode];
    checkSumString = [checkSumString hexStringReverse];
    return checkSumString;
}

#pragma mark - crc校验(Cyclic Redundancy Check 循环冗余检查) 如固件有采用此算法校验可以采用 否则可以不用
//校验程式
uint16_t crc16_compute(const uint8_t * p_data, uint32_t size, const uint16_t * p_crc)
{
    uint32_t i;
    uint16_t crc = (p_crc == NULL) ? 0xffff : *p_crc;
    
    for (i = 0; i < size; i++)
    {
        crc  = (unsigned char)(crc >> 8) | (crc << 8);
        crc ^= p_data[i];
        crc ^= (unsigned char)(crc & 0xff) >> 4;
        crc ^= (crc << 8) << 4;
        crc ^= ((crc & 0xff) << 4) << 1;
    }
    return crc;
}

//获得当前的时间data 为12个字节
+(NSString *)getTimeIsNowString{
    NSInteger timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString * timeStampString = [NSString stringWithFormat:@"%zi",timeStamp];
    NSString * timeStampHex = [NSString stringWithFormat:@"%x",[timeStampString intValue]];
    NSString * timeStampExchanged = [NSString hexStringReverse:timeStampHex];
    
    //时区
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    
    NSInteger systemArea = interval;
    NSString * systemAreaString = [NSString stringWithFormat:@"%zi",systemArea];
    NSString * systemAreaHex = [NSString stringWithFormat:@"%.8x",[systemAreaString intValue]];
    NSString * systemAreaExchanged = [NSString hexStringReverse:systemAreaHex];
    
    NSString * timeIsNowString = [NSString stringWithFormat:@"%@%@00000000",timeStampExchanged,systemAreaExchanged];
    
    return timeIsNowString;
}

//获得当前的时间data 为12个字节
+ (NSString *)getTimeIsNowStringWith: (NSInteger)timeStamp geoCode:(NSInteger)geoCode{
    NSString * timeStampString = [NSString stringWithFormat:@"%zi",timeStamp];
    NSString * timeStampHex = [NSString stringWithFormat:@"%x",[timeStampString intValue]];
    NSString * timeStampExchanged = [NSString hexStringReverse:timeStampHex];
    
    NSInteger systemArea;
    if (geoCode) {
        systemArea = geoCode * 3600;
    } else {
        NSDate *date = [NSDate date];
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:date];
        systemArea = interval;
    }
    NSString * systemAreaString = [NSString stringWithFormat:@"%zi",systemArea];
    NSString * systemAreaHex = [NSString stringWithFormat:@"0000%x",[systemAreaString intValue]];
    NSString * systemAreaExchanged = [NSString hexStringReverse:systemAreaHex];
    
    NSString * timeIsNowString = [NSString stringWithFormat:@"%@%@00000000",timeStampExchanged,systemAreaExchanged];
    return timeIsNowString;
}

@end


@implementation SOCBluetoothWriteData (Command)

//绑定指令
+ (NSString *)commandForBind {
    return [self commandWithType:@"000a" length:@"0000" appendData:@""];
}
//获取数据
+ (NSString *)commandForGetRequestRecords {
    return [self commandWithType:@"0002" length:@"0000" appendData:@""];
}
//设置时间指令
+ (NSString *)commandForSetLocalTime {
    NSString * timeIsNowString = [self getTimeIsNowString];
    return [self commandWithType:@"0003" length:@"000c" appendData:timeIsNowString];
}

+ (NSString *)commandForSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode {
    NSString * timeIsNowString = [self getTimeIsNowStringWith:timeStamp geoCode:geoCode];//[NSString getTimeIsNowString];
    return [self commandWithType:@"0003" length:@"000c" appendData:timeIsNowString];
}
//获取DFU请求指令
+ (NSString *)commandForDFURequest {
    return [self commandWithType:@"0004" length:@"0000" appendData:@""];
}

//获取电池指令
+ (NSString *)commandForGetBattery {
    return [self commandWithType:@"0005" length:@"0000" appendData:@""];
}
//设备信息指令
+ (NSString *)commandForGetDeviceInfo {
    return [self commandWithType:@"0006" length:@"0000" appendData:@""];
}
//设置刷牙时间 Function set
+ (NSString *)commandForSetFuncionWith:(int)tag {
    int workTime = (tag ? 150: 120) ;
    int tipsTime = (tag ? 38: 30);
    NSString * workTimeStr = [NSString stringWithFormat:@"%.4X",workTime];
    NSString * tipsTimeStr = [NSString stringWithFormat:@"%.4X",tipsTime];
    NSString * s1 = [NSString hexStringReverse:workTimeStr];
    NSString * s2 = [NSString hexStringReverse:tipsTimeStr];
    NSString * s = [NSString stringWithFormat:@"%@%@",s1,s2];
    return [self commandWithType:@"0001" length:@"0004" appendData:s];
}

//设置渐强模式指令: 1：使能渐强模式;0：禁止渐强模式
+ (NSString *)commandForSetfadeInWith:(int)tag {
    NSString * model = [NSString stringWithFormat:@"%.2x",tag];
    return [self commandWithType:@"0007" length:@"0001" appendData:model];
}

//设置附加模式指令: 0x00:禁止功能模式;0x01:抛光模式;0x02:护理模式;0x03:舌苔模式
+ (NSString *)commandForSetAddOnsWith:(int)index {
    NSString * model = [NSString stringWithFormat:@"%.2x",index];
    return [self commandWithType:@"0008" length:@"0001" appendData:model];
}

// 电机参数
+ (NSString *)commandForMotorParameters:(NSString *)MotorParameters {
    return [self commandWithType:@"0009" length:@"0004" appendData:MotorParameters];
}

// 定制模式
+ (NSString *)commandForSetPersonalMode:(BOOL)on mode:(NSString *)mode {
    if (!on) {
        return [self commandWithType:@"000b" length:@"0000" appendData:@""];
    }
    return [self commandWithType:@"000b" length:@"0003" appendData:mode];
}

// 获取soocare设备ID
+ (NSString *)commandForGetDid {
    return [self commandWithType:@"000c" length:@"0000" appendData:@""];
}

// 写入soocare设备ID
+ (NSString *)commandForSetDid:(NSString *)did {
    return [self commandWithType:@"000d" length:@"000c" appendData:did];
}

// 获取NTAG中的刷牙次数
+ (NSString *)commandForGetCountInNTAG {
    return [self commandWithType:@"000e" length:@"0000" appendData:@""];
}

// 设置拿起唤醒状态 00/01
+ (NSString *)commandForSetFlashState:(NSString *)state {
    return [self commandWithType:@"000f" length:@"0001" appendData:state];
}

+ (NSString *)commandForDFURequestCRC:(NSString *)crcString {
    return [self commandWithType:@"000e" length:@"0004" appendData:crcString];
}

@end