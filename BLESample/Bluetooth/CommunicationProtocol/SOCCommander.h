//
//  SOCCommander.h
//  SoocareInternational
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 soocare. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CMDType.h"

typedef NS_ENUM(NSUInteger, SOCDeviceType) {
    SOCDeviceUnknown = 0,
    SOCDeviceX3 = 1,
    SOCDeviceX5 = 2,
    SOCDeviceM1 = 3,
    SOCDeviceMC1,
};

NS_INLINE SOCDeviceType SOCDeivceTypeCreateWithLocalName(NSString * localName) {
    SOCDeviceType type = 0;
    if ([localName hasSuffix:@"X3"]) {
        type = SOCDeviceX3;
    }
    else if ([localName hasSuffix:@"X5"]) {
        type = SOCDeviceX5;
    }
    else if ([localName containsString:@"M1"]) {
        type = SOCDeviceM1;
    }
    else if ([localName hasSuffix:@"MC1"]) {
        type = SOCDeviceMC1;
    }
    return type;
}

@class SOCCommander;

@interface SOCCommander : NSObject

//050000000000
+ (NSString *)getCheckStringWith:(NSString *)hexString;

/**
 @param typeString hex string of command type. eg: 0001
 @param lengthHexString hex string of data bytes length. eg:0004
 @param appendString eg:78001e00
 @return a bluetooth command, eg: type + length + frame + crc + data
                                  0100   0400     0100    70b2  78001e00
 */
+ (NSString *)commandWithType:(NSString *)typeString length:(NSString *)lengthHexString appendData:(NSString *)appendString;

+ (__kindof SOCCommander *)commanderWithType:(SOCDeviceType)type;

+ (__kindof SOCCommander *)commanderWithName:(NSString *)localName;

@property (nonatomic, readonly) SOCDeviceType deviceType;

- (NSArray *)supportCommands;

@end

@interface SOCCommander (Command)

//绑定指令
+ (NSString *)commandForBind;

//获取数据
+ (NSString *)commandForGetRequestRecords;

//获取DFU请求指令
+ (NSString *)commandForDFURequest;

//获取电池指令
+ (NSString *)commandForGetBattery;

//设备信息指令
+ (NSString *)commandForGetDeviceInfo;

//设置时间指令
+ (NSString *)commandForSetLocalTime;
+ (NSString *)commandForSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode;

//设置刷牙时间 Function set
+ (NSString *)commandForSetFuncionWith:(int)tag;

//设置渐强模式指令: 1：使能渐强模式;0：禁止渐强模式
+ (NSString *)commandForSetfadeInWith:(int)tag;

//设置附加模式指令: 0x00:禁止功能模式;0x01:抛光模式;0x02:护理模式;0x03:舌苔模式
+ (NSString *)commandForSetAddOnsWith:(int)index;

// 电机参数
+ (NSString *)commandForMotorParameters:(NSString *)MotorParameters;

// 定制模式
+ (NSString *)commandForSetPersonalMode:(BOOL)on mode:(NSString *)mode;

// 获取soocare设备ID
+ (NSString *)commandForGetDid;

// 写入soocare设备ID
+ (NSString *)commandForSetDid:(NSString *)did;

// 获取NTAG中的刷牙次数
+ (NSString *)commandForGetCountInNTAG;

// 设置拿起唤醒状态 00/01
+ (NSString *)commandForSetFlashState:(NSString *)state;

+ (NSString *)commandForDFURequestCRC:(NSString *)crcString;


//绑定指令
- (NSString *)commandForBind;

//获取数据
- (NSString *)commandForGetRequestRecords;

//获取DFU请求指令
- (NSString *)commandForDFURequest;

//获取电池指令
- (NSString *)commandForGetBattery;

//设备信息指令
- (NSString *)commandForGetDeviceInfo;

//设置时间指令
- (NSString *)commandForSetLocalTime;
- (NSString *)commandForSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode;

//设置刷牙时间 Function set
- (NSString *)commandForSetFuncionWith:(int)tag;

//设置渐强模式指令: 1：使能渐强模式;0：禁止渐强模式
- (NSString *)commandForSetfadeInWith:(int)tag;

//设置附加模式指令: 0x00:禁止功能模式;0x01:抛光模式;0x02:护理模式;0x03:舌苔模式
- (NSString *)commandForSetAddOnsWith:(int)index;

// 电机参数
- (NSString *)commandForMotorParameters:(NSString *)MotorParameters;

// 定制模式
- (NSString *)commandForSetPersonalMode:(BOOL)on mode:(NSString *)mode;

// 获取soocare设备ID
- (NSString *)commandForGetDid;

// 写入soocare设备ID
- (NSString *)commandForSetDid:(NSString *)did;

// 获取NTAG中的刷牙次数
- (NSString *)commandForGetCountInNTAG;

// 设置拿起唤醒状态 00/01
- (NSString *)commandForSetFlashState:(NSString *)state;

- (NSString *)commandForDFURequestCRC:(NSString *)crcString;


@end


@interface SOCCommander_X3 : SOCCommander

@end

@interface SOCCommander_X5 : SOCCommander

@end

@interface SOCCommander_M1 : SOCCommander

@end

@interface SOCCommander_MC1 : SOCCommander

@end
