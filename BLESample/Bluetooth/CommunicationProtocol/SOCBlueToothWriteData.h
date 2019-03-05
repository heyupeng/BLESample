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
+ (NSString *)getSendingStringWithType:(NSString *)typeString AppendData:(NSString *)appendDataString;

//绑定指令
+ (NSString *)getSendStringOfBind;
//获取数据
+ (NSString *)getSendStringOfGetRequestRecords;
//获取DFU请求指令
+ (NSString *)getSendStringOfDFURequest;
//获取电池指令
+ (NSString *)getSendStringOfGetBattery;
//设备信息指令
+ (NSString *)getSendStringOfGetDeviceInfo;
//设置时间指令
+ (NSString *)getSendStringOfSetLocalTime;
+ (NSString *)sendOrderToSetLocalTimeWith:(NSInteger)timeStamp geoCode:(NSInteger)geoCode;
//设置刷牙时间 Function set
+ (NSString *)getSendStringOfSetFuncionWith:(int)tag;
//设置渐强模式指令: 1：使能渐强模式;0：禁止渐强模式
+ (NSString *)getSendStringOfSetfadeInWith:(int)tag;
//设置附加模式指令: 0x00:禁止功能模式;0x01:抛光模式;0x02:护理模式;0x03:舌苔模式
+ (NSString *)getSendStringOfSetAddOnsWith:(int)index;

// 电机参数
+ (NSString *)getCmdOfMotorParameters:(NSString *)MotorParameters;

// 定制模式
+ (NSString *)getCmdOfSetPersonalMode:(BOOL)on mode:(NSString *)mode;

// 获取soocare设备ID
+ (NSString *)getCmdOfGetDid;

// 写入soocare设备ID
+ (NSString *)getCmdOfSetDid:(NSString *)did;

// 获取NTAG中的刷牙次数
+ (NSString *)getCmdOfGetCountInNTAG;

// 设置拿起唤醒状态 00/01
+ (NSString *)getCmdOfSetFlashState:(NSString *)state;

@end
