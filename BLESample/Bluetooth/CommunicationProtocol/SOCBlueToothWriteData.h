//
//  SOCBlueToothWriteData.h
//  SoocareInternational
//
//  Created by mac on 16/11/17.
//  Copyright © 2016年 soocare. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOCBlueToothWriteData : NSObject
//050000000000
+ (NSString *)getCheckStringWith:(NSString *)sendString;
//000a0000
+ (NSString *)commandWithType:(NSString *)typeString appendData:(NSString *)appendString;
+ (NSString *)commandWithType:(NSString *)typeString length:(NSString *)lengthHexString appendData:(NSString *)appendString;

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
+ (NSString *)sendOrderToSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode;
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

@end
