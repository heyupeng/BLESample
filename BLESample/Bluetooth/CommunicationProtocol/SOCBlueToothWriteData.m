//
//  SOCBlueToothWriteData.m
//  SoocareInternational
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 soocare. All rights reserved.
//

#import "SOCBlueToothWriteData.h"

@implementation SOCBlueToothWriteData

int frameNumber = 0;
#pragma mark - /******** 发送指令 *********/

+ (NSString *)getSendingStringWithType:(NSString *)typeString AppendData:(NSString *)appendDataString {
    NSString * str;
    if (typeString.length == 8) {
    freeAgain:
        if (frameNumber < 16) {
            str = [NSString stringWithFormat:@"%@000%x",typeString,frameNumber++];
        }else if(frameNumber < 255){
            str = [NSString stringWithFormat:@"%@00%x",typeString,frameNumber++];
        }else{
            frameNumber = 0;
            goto freeAgain;
        }//合法
        str = [self getCheckStringWith:str];
        if (str) {
            str = [NSString stringWithFormat:@"%@%@",str,appendDataString];
        }
    }
    return [str lowercaseString];
}

//绑定指令
+ (NSString *)getSendStringOfBind {
    return [self getSendingStringWithType:@"000a0000" AppendData:@""];
}
//获取数据
+ (NSString *)getSendStringOfGetRequestRecords {
    return [self getSendingStringWithType:@"00020000" AppendData:@""];
}
//设置时间指令
+ (NSString *)getSendStringOfSetLocalTime {
    NSString * timeIsNowString = [self getTimeIsNowString];
    return [self getSendingStringWithType:@"0003000c" AppendData:timeIsNowString];
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

+ (NSString *)sendOrderToSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode {
    NSString * timeIsNowString = [self getTimeIsNowStringWith:timeStamp geoCode:geoCode];//[NSString getTimeIsNowString];
    return [self getSendingStringWithType:@"0003000c" AppendData:timeIsNowString];
}
//获取DFU请求指令
+ (NSString *)getSendStringOfDFURequest {
    return [self getSendingStringWithType:@"00040000" AppendData:@""];
}

//获取电池指令
+ (NSString *)getSendStringOfGetBattery {
    return [self getSendingStringWithType:@"00050000" AppendData:@""];
}
//设备信息指令
+ (NSString *)getSendStringOfGetDeviceInfo {
    return [self getSendingStringWithType:@"00060000" AppendData:@""];
}
//设置刷牙时间 Function set
+ (NSString *)getSendStringOfSetFuncionWith:(int)tag {
    int workTime = (tag ? 150: 120) ;
    int tipsTime = (tag ? 38: 30);
    NSString * workTimeStr = [NSString stringWithFormat:@"%.4X",workTime];
    NSString * tipsTimeStr = [NSString stringWithFormat:@"%.4X",tipsTime];
    NSString * s1 = [NSString hexStringReverse:workTimeStr];
    NSString * s2 = [NSString hexStringReverse:tipsTimeStr];
    NSString * s = [NSString stringWithFormat:@"%@%@",s1,s2];
    return [self getSendingStringWithType:@"00010004" AppendData:s];
}

//设置渐强模式指令: 1：使能渐强模式;0：禁止渐强模式
+ (NSString *)getSendStringOfSetfadeInWith:(int)tag {
    NSString * model = [NSString stringWithFormat:@"%.2x",tag];
    return [self getSendingStringWithType:@"00070001" AppendData:model];
}

//设置附加模式指令: 0x00:禁止功能模式;0x01:抛光模式;0x02:护理模式;0x03:舌苔模式
+ (NSString *)getSendStringOfSetAddOnsWith:(int)index {
    NSString * model = [NSString stringWithFormat:@"%.2x",index];
    return [self getSendingStringWithType:@"00080001" AppendData:model];
}

// 电机参数
+ (NSString *)getCmdOfMotorParameters:(NSString *)MotorParameters {
    return [self getSendingStringWithType:@"00090004" AppendData:MotorParameters];
}

// 定制模式
+ (NSString *)getCmdOfSetPersonalMode:(BOOL)on mode:(NSString *)mode {
    if (!on) {
        return [self getSendingStringWithType:@"000b0000" AppendData:@""];
    }
    return [self getSendingStringWithType:@"000b0003" AppendData:mode];
}

// 获取soocare设备ID
+ (NSString *)getCmdOfGetDid {
    return [self getSendingStringWithType:@"000c0000" AppendData:@""];
}

// 写入soocare设备ID
+ (NSString *)getCmdOfSetDid:(NSString *)did {
    return [self getSendingStringWithType:@"000d000c" AppendData:did];
}

// 获取NTAG中的刷牙次数
+ (NSString *)getCmdOfGetCountInNTAG {
    return [self getSendingStringWithType:@"000e0000" AppendData:@""];
}

// 设置拿起唤醒状态 00/01
+ (NSString *)getCmdOfSetFlashState:(NSString *)state {
    return [self getSendingStringWithType:@"000f0001" AppendData:state];
}
#pragma mark - 安全性校验
/*
 1.检查指令长度
 2.检查奇偶数
 3.检查非法字符
 4.生成校验码并返回
 5.返回yes或者no
 */

+ (NSString *)getCheckStringWith:(NSString *)sendString{
    NSString * string;
    if (sendString.length < 12) {
        // NSLog(@"指令长度不足");
    }else if (sendString.length %2 != 0){
        // NSLog(@"不可以输入半个字节\n");
    }else {
        // NSLog(@"安全检查成功,开始获得校验码\n");
        string = [self getCheckSum:sendString];
        if (string) {
//            NSLog(@"校验码获得成功\n");
        }else{
            // NSLog(@"获得校验码失败,请重新输入\n");
        }
    }
    return string;
}

//截取string之后重新排列然后添加到byte里面
+ (NSString *)getCheckSum:(NSString *)myString
{
    NSString * sendString;
    //根据坐标截取6字节字符串
    NSRange typeHigh = NSMakeRange(0, 2);
    NSRange typeLow = NSMakeRange(2, 2);
    NSRange lengthHigh = NSMakeRange(4, 2);
    NSRange lengthLow = NSMakeRange(6, 2);
    NSRange frameHigh = NSMakeRange(8, 2);
    NSRange frameLow = NSMakeRange(10, 2);
    NSString * typeHighString = [myString substringWithRange:typeHigh];
    NSString * typeLowString = [myString substringWithRange:typeLow];
    NSString * lengthHighString = [myString substringWithRange:lengthHigh];
    NSString * lengthLowString = [myString substringWithRange:lengthLow];
    NSString * frameHighString = [myString substringWithRange:frameHigh];
    NSString * frameLowString = [myString substringWithRange:frameLow];
    //重新排列高低位
    NSArray * stringArray = @[typeLowString,typeHighString,lengthLowString,lengthHighString,frameLowString,frameHighString];
    NSString * sequenceString = @"";
    for (int i = 0 ; i < stringArray.count; i++) {
        sequenceString = [sequenceString stringByAppendingString:stringArray[i]];
    }
    
    NSMutableData * myData = [[NSMutableData alloc]init];
    //把字符串转换成data
    for (NSString * string in stringArray) {
        [myData appendData:[NSString hexStringToByte:string]];
    }
    //把data转换成byte
    Byte * checkSumByte = (Byte *)[myData bytes];
    //获取校验值
    NSString * checkSumString = [NSString stringWithFormat:@"%x",crc16_compute(checkSumByte, 0x06, NULL)];
    
    switch (checkSumString.length) {
        case 0: {
        }
            break;
        case 1: {
            NSString * newInputString = [NSString stringWithFormat:@"000%@",checkSumString];
            newInputString = [NSString hexStringReverse:newInputString];
            sendString = [sequenceString stringByAppendingString:newInputString];
        }
            break;
        case 2: {
            NSString * newInputString = [NSString stringWithFormat:@"00%@",checkSumString];
            newInputString = [NSString hexStringReverse:newInputString];
            sendString = [sequenceString stringByAppendingString:newInputString];
        }
            break;
        case 3: {
            NSString * newInputString = [NSString stringWithFormat:@"0%@",checkSumString];
            newInputString = [NSString hexStringReverse:newInputString];
            sendString = [sequenceString stringByAppendingString:newInputString];
        }
            break;
        case 4: {
            NSString * newInputString = checkSumString;
            newInputString = [NSString hexStringReverse:newInputString];
            sendString = [sequenceString stringByAppendingString:newInputString];
        }
            break;
        default: {
        }
            break;
    }
    return sendString;
}
#pragma mark - crc校验 如固件有采用此算法校验可以采用 否则可以不用
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
+ (NSString *)getTimeIsNowStringWith: (NSInteger)timeStamp geoCode:(NSInteger)geoCode{
    //    NSInteger timeStamp = [NSDate getTimeStamp];
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
