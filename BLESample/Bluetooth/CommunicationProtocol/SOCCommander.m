//
//  SOCCommander.m
//  SoocareInternational
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 soocare. All rights reserved.
//

#import "SOCCommander.h"

@interface SOCCommander ()

@property (nonatomic) SOCDeviceType deviceType;

@end

@implementation SOCCommander

int __frameNumber__ = 0;
int getFrameNumber() {
    __frameNumber__ ++;
    if (__frameNumber__ > 255) { __frameNumber__ = 0;}
    return __frameNumber__;
}

void cleanFrameNumber() {
    __frameNumber__ = 0;
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

uint32_t getCheckSum(NSString * hexString) {
    //把16进制字符串转换成data
    NSMutableData * myData = [[NSMutableData alloc]init];
    [myData appendData:[NSData dataWithHexString:hexString]];

    //把data转换成byte
    Byte * checkSumByte = (Byte *)[myData bytes];
    
    //获取校验值
    uint16_t crcPoly = 0xffff ;//0x1021;
    uint32_t checkCode = crc16_compute(checkSumByte, 0x06, &crcPoly);
    return checkCode;
}

NSString * getCheckSumHexString(NSString * hexString) {
    uint32_t checkCode = getCheckSum(hexString);
    NSString * checkSumString = [NSString stringWithFormat:@"%.4x",checkCode];
    return checkSumString;
}

NSInteger getSecondsFromGMT(int geoCode) {
    NSInteger seconds = 0;
    if (geoCode >= -12 && geoCode <= 12) {
        seconds = geoCode * 3600;
        return seconds;
    }
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    seconds = [zone secondsFromGMTForDate:date];
    return seconds;
}

//获得 当前时间 date + 时区 timezone + 夏令时 拼接的16字符串，12个字节
NSString * getCurrentTimeHexString(void) {
    NSInteger timestamp = [[NSDate date] timeIntervalSince1970];
    return getTimeHexString(timestamp, 99);
}

NSString * getTimeHexString(NSInteger timestamp, NSInteger geoCode) {
    NSString * timestampHex = [NSString stringWithFormat:@"%.8x", (int)timestamp];
    
    NSInteger timezoneSecond = getSecondsFromGMT((int)geoCode);
    NSString * timezoneHex = [NSString stringWithFormat:@"%.8x", (int)timezoneSecond];
    
    NSString * timestampExchanged = [timestampHex hexStringReverse];
    NSString * timezoneExchanged = [timezoneHex hexStringReverse];
    NSString * timeHexString = [NSString stringWithFormat:@"%@%@00000000",timestampExchanged,timezoneExchanged];
    return timeHexString;
}
#pragma mark - /******** 发送指令 *********/

+ (NSString *)commandWithType:(NSString *)typeString length:(NSString *)lengthHexString appendData:(NSString *)appendString {
    NSString * str;
    if (typeString.length == 4 && lengthHexString.length == 4) {
        NSString * frameString = [NSString stringWithFormat:@"%.4x", getFrameNumber()];
        str = [NSString stringWithFormat:@"%@%@%@",[typeString hexStringReverse], [lengthHexString hexStringReverse], [frameString hexStringReverse]];
        
        str = [self getCheckStringWith:str];
        if (str) {
            str = [NSString stringWithFormat:@"%@%@",str,appendString];
        }
    }
    return [str lowercaseString];
}

- (NSString *)commandWithType:(NSString *)typeString length:(NSString *)lengthHexString appendData:(NSString *)appendString {
    NSString * str;
    if (typeString.length == 4 && lengthHexString.length == 4) {
        NSString * frameString = [NSString stringWithFormat:@"%.4x", getFrameNumber()];
        str = [NSString stringWithFormat:@"%@%@%@",[typeString hexStringReverse], [lengthHexString hexStringReverse], [frameString hexStringReverse]];
        
        NSString * sumHex = getCheckSumHexString(str);
        str = [str stringByAppendingString:[sumHex hexStringReverse]];
        
        if (str) {
            str = [NSString stringWithFormat:@"%@%@",str,appendString];
        }
    }
    return [str lowercaseString];
}


#pragma mark - 安全性校验
+ (NSString *)getCheckStringWith:(NSString *)hexString{
    NSString * string;
    if (hexString.length < 12) {
//        NSLog(@"非法字符串:长度不符合！");
        return string;
    }
    
    string = [getCheckSumHexString(hexString) hexStringReverse];
    if (!string) {
//        NSLog(@"非法字符串:获得校验码失败");
        return string;
    }
    
    string = [hexString stringByAppendingString:string];
    return string;
}

+ (instancetype)commanderWithType:(SOCDeviceType)type {
    SOCCommander * cmder;
    switch (type) {
        case SOCDeviceX3:
            cmder = [[SOCCommander_X3 alloc] init];
            break;
        case SOCDeviceX5:
            cmder = [[SOCCommander_X5 alloc] init];
            break;
        case SOCDeviceM1:
            cmder = [[SOCCommander_M1 alloc] init];
            break;
        case SOCDeviceMC1:
            cmder = [[SOCCommander_MC1 alloc] init];
            break;
        default:
            cmder = [[SOCCommander alloc] init];
            break;
    }
    
    cmder.deviceType = type;
    return cmder;
}

+ (__kindof SOCCommander *)commanderWithName:(NSString *)localName {
    SOCDeviceType type = SOCDeivceTypeCreateWithLocalName(localName);
    return [self commanderWithType:type];
}

- (NSArray *)supportCommands {
    NSArray * support = @[
        @{ @"value": @(CMD_FunctionSet),        @"cmd": @"时长设置" },
        @{ @"value": @(CMD_RequestRecords),     @"cmd": @"记录读取" },
        @{ @"value": @(CMD_LocaltimeSet),       @"cmd": @"时间设置" },
        @{ @"value": @(CMD_RequestDFU),         @"cmd": @"RequestDFU" },
        @{ @"value": @(CMD_Battery),            @"cmd": @"电量" },
        @{ @"value": @(CMD_DeviceInfo),         @"cmd": @"设备信息" },
        @{ @"value": @(CMD_ModeSetFadeIn),      @"cmd": @"渐强模式设置" },
        @{ @"value": @(CMD_ModeSetAddOn),       @"cmd": @"附加模式设置" },
        @{ @"value": @(CMD_MotorParametersSet), @"cmd": @"电机参数设置" },
        @{ @"value": @(CMD_RequestResponse),    @"cmd": @"请求响应" },
    ];
    return support;
}

@end

@implementation SOCCommander (Command)

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
    NSString * hexString = getCurrentTimeHexString();
    return [self commandWithType:@"0003" length:@"000c" appendData:hexString];
}

+ (NSString *)commandForSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode {
    NSString * hexString = getTimeHexString(timeStamp, geoCode);
    return [self commandWithType:@"0003" length:@"000c" appendData:hexString];
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
    NSString * s1 = [workTimeStr hexStringReverse];
    NSString * s2 = [tipsTimeStr hexStringReverse];
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


//绑定指令
- (NSString *)commandForBind {
    return [SOCCommander commandWithType:@"000a" length:@"0000" appendData:@""];
}
//获取数据
- (NSString *)commandForGetRequestRecords {
    return [self commandWithType:@"0002" length:@"0000" appendData:@""];
}
//设置时间指令
- (NSString *)commandForSetLocalTime {
    NSString * hexString = getCurrentTimeHexString();
    return [self commandWithType:@"0003" length:@"000c" appendData:hexString];
}

- (NSString *)commandForSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode {
    NSString * hexString = getTimeHexString(timeStamp, geoCode);
    return [self commandWithType:@"0003" length:@"000c" appendData:hexString];
}
//获取DFU请求指令
- (NSString *)commandForDFURequest {
    return [self commandWithType:@"0004" length:@"0000" appendData:@""];
}

//获取电池指令
- (NSString *)commandForGetBattery {
    return [self commandWithType:@"0005" length:@"0000" appendData:@""];
}
//设备信息指令
- (NSString *)commandForGetDeviceInfo {
    return [self commandWithType:@"0006" length:@"0000" appendData:@""];
}
//设置刷牙时间 Function set
- (NSString *)commandForSetFuncionWith:(int)tag {
    int workTime = (tag ? 150: 120) ;
    int tipsTime = (tag ? 38: 30);
    NSString * workTimeStr = [NSString stringWithFormat:@"%.4X",workTime];
    NSString * tipsTimeStr = [NSString stringWithFormat:@"%.4X",tipsTime];
    NSString * s1 = [workTimeStr hexStringReverse];
    NSString * s2 = [tipsTimeStr hexStringReverse];
    NSString * s = [NSString stringWithFormat:@"%@%@",s1,s2];
    return [self commandWithType:@"0001" length:@"0004" appendData:s];
}

//设置渐强模式指令: 1：使能渐强模式;0：禁止渐强模式
- (NSString *)commandForSetfadeInWith:(int)tag {
    NSString * model = [NSString stringWithFormat:@"%.2x",tag];
    return [self commandWithType:@"0007" length:@"0001" appendData:model];
}

//设置附加模式指令: 0x00:禁止功能模式;0x01:抛光模式;0x02:护理模式;0x03:舌苔模式
- (NSString *)commandForSetAddOnsWith:(int)index {
    NSString * model = [NSString stringWithFormat:@"%.2x",index];
    return [self commandWithType:@"0008" length:@"0001" appendData:model];
}

// 电机参数
- (NSString *)commandForMotorParameters:(NSString *)MotorParameters {
    return [self commandWithType:@"0009" length:@"0004" appendData:MotorParameters];
}

// 定制模式
- (NSString *)commandForSetPersonalMode:(BOOL)on mode:(NSString *)mode {
    if (!on) {
        return [self commandWithType:@"000b" length:@"0000" appendData:@""];
    }
    return [self commandWithType:@"000b" length:@"0003" appendData:mode];
}

// 获取soocare设备ID
- (NSString *)commandForGetDid {
    return [self commandWithType:@"000c" length:@"0000" appendData:@""];
}

// 写入soocare设备ID
- (NSString *)commandForSetDid:(NSString *)did {
    return [self commandWithType:@"000d" length:@"000c" appendData:did];
}

// 获取NTAG中的刷牙次数
- (NSString *)commandForGetCountInNTAG {
    return [self commandWithType:@"000e" length:@"0000" appendData:@""];
}

// 设置拿起唤醒状态 00/01
- (NSString *)commandForSetFlashState:(NSString *)state {
    return [self commandWithType:@"000f" length:@"0001" appendData:state];
}

- (NSString *)commandForDFURequestCRC:(NSString *)crcString {
    return [self commandWithType:@"000e" length:@"0004" appendData:crcString];
}

@end

@implementation SOCCommander_X3

- (NSArray *)supportCommands {
    NSArray * support = @[
        @{ @"value": @(CMD_ModeSet),        @"cmd": @"定制模式设置" },
        @{ @"value": @(CMD_DeviceIDGet),    @"cmd": @"DID读取" },
        @{ @"value": @(CMD_DeviceIDSet),    @"cmd": @"DID写入" },
    ];
    return [[super supportCommands] arrayByAddingObjectsFromArray:support];
}

@end

@implementation SOCCommander_X5

- (NSArray *)supportCommands {
    NSArray * support = @[
        @{ @"value": @(CMD_DeviceIDGet),    @"cmd": @"DID读取" },
        @{ @"value": @(CMD_DeviceIDSet),    @"cmd": @"DID写入" },
        
        @{ @"value":@(CMD_X5_NTAGGet),          @"cmd": @"NTAG中使用次数" },
        @{ @"value":@(CMD_X5_FlashSet),         @"cmd": @"Flash Setting" },
        @{ @"value":@(CMD_X5_RequestDFUCRC),    @"cmd": @"RequestDFUCRC" },
    ];
    return [[super supportCommands] arrayByAddingObjectsFromArray:support];
}

// 获取NTAG中的刷牙次数
- (NSString *)commandForGetCountInNTAG {
    return [self commandWithType:@"000e" length:@"0000" appendData:@""];
}

// 设置拿起唤醒状态 00/01
- (NSString *)commandForSetFlashState:(NSString *)state {
    return [self commandWithType:@"000f" length:@"0001" appendData:state];
}

- (NSString *)commandForDFURequestCRC:(NSString *)crcString {
    return [self commandWithType:@"0010" length:@"0004" appendData:crcString];
}

@end

@implementation SOCCommander_M1

- (NSArray *)supportCommands {
    NSArray * support = @[
        @{ @"value": @(CMD_DeviceIDGet),    @"cmd": @"DID读取" },
        @{ @"value": @(CMD_DeviceIDSet),    @"cmd": @"DID写入" },
        
        @{ @"value":@(CMD_M1_RequestDFUCRC),    @"cmd": @"RequestDFUCRC" },
    ];
    return [[super supportCommands] arrayByAddingObjectsFromArray:support];
}

- (NSString *)commandForDFURequestCRC:(NSString *)CRC {
    return [self commandWithType:@"000e" length:@"0004" appendData:CRC];
}

@end

@implementation SOCCommander_MC1

- (NSArray *)supportCommands {
    NSArray * support = @[
        @{ @"value": @(CMD_DeviceIDGet),    @"cmd": @"DID读取" },
        @{ @"value": @(CMD_DeviceIDSet),    @"cmd": @"DID写入" },
        
        @{ @"value":@(CMD_MC1_RequestDFUCRC),   @"cmd": @"RequestDFUCRC" },
    ];
    return [[super supportCommands] arrayByAddingObjectsFromArray:support];
}

- (NSString *)commandForDFURequestCRC:(NSString *)CRC {
    return [self commandWithType:@"0011" length:@"0004" appendData:CRC];
}

@end


