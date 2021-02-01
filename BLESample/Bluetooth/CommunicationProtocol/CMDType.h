//
//  CMDType.h
//  BLESample
//
//  Created by Pro on 2019/6/4.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CMDType) {
    // Default (X3)
    CMD_Empty = 0x00,
    CMD_FunctionSet = 0x01, //工作时间设置
    CMD_RequestRecords = 0x02, // 请求数据
    CMD_LocaltimeSet = 0x03, // 本地时间设置
    CMD_RequestDFU = 0x04, // 请求DFU
    CMD_Battery = 0x05, // 电量获取
    CMD_DeviceInfo = 0x06, // 设备信息获取
    CMD_ModeSetFadeIn = 0x07, // 渐强模式设置
    CMD_ModeSetAddOn = 0x08, // 附加模式设置
    CMD_MotorParametersSet = 0x09, // 电机参数设置
    CMD_RequestResponse = 0x0a, // 请求设备绑定（按键响应）
    CMD_ModeSet = 0x0b, // 定制模式
    CMD_DeviceIDGet = 0x0c, // 设备ID获取
    CMD_DeviceIDSet = 0x0d, // 设备ID设置
    
    // X5
    CMD_X5_NTAGGet = 0x0e,
    CMD_X5_FlashSet = 0x0f,
    CMD_X5_RequestDFUCRC = 0x10,
    
    // M1
    CMD_M1_RequestDFUCRC = 0x0f,
    
    // MC1
    CMD_MC1_FileTransferStart = 0x0e, // 启动文件传输
    CMD_MC1_FileTransferEnd = 0x0f, // 结束文件传输
    CMD_MC1_MusicControl = 0x10, // 音乐开关控制
    CMD_MC1_FileTransferControl = 0x18, // 文件传输控制
    
    CMD_MC1_RequestDFUCRC = 0x11, // DFU校验
};

// MC1
extern const int PRIVATE_FILE_TYPE_Length1;
extern const int PRIVATE_FILE_TYPE_Length2;
extern const NSString * Private_Service_UUID;
extern const NSString * Private_Service_Tx_Characteristic_UUID;

NS_ASSUME_NONNULL_END
