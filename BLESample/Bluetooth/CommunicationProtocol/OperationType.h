//
//  OpType.h
//  SOOCASBLE
//
//  Created by Pro on 2019/6/4.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OpType) {
    OpTypeEmpty = 0,
    OpTypeFunctionSet = 0x01, //工作时间s设置
    OpTypeRequestRecords = 0x02, // 请求数据
    OpTypeLocalTimeSet = 0x03, // 本地时间设置
    OpTypeRequestDFU = 0x04, // 请求DFU
    OpTypeElectricity = 0x05, // 电量获取
    OpTypeDeviceInfo = 0x06, // 设备信息获取
    OpTypeFadeInSet = 0x07, // 渐强模式设置
    OpTypeAddonSet = 0x08, // 附加模式设置
    OpTypeMotorParamsSet = 0x09, // 电机参数设置
    OpTypeRequestBind = 0x0a, // 请求b设备绑定（按键响应）
    OpTypeCustomMode = 0x0b, // 定制模式
    OpTypeDeviceID = 0x0c, // 设备ID获取
    OpTypeDeviceIDSet = 0x0d, // 设备ID设置
    
    OpTypeFileTransferStart = 0x0e, // 启动文件传输
    OpTypeFileTransferEnd = 0x0f, // 结束文件传输
    OpTypeMusicControl = 0x10, // 音乐开关控制
    OpTypeFileTransferControl = 0x18, // 文件传输控制
    
    OpTypeRequestDFUCRC = 0x11, // DFU校验
};

// MC1
extern const int PRIVATE_FILE_TYPE_Length1;
extern const int PRIVATE_FILE_TYPE_Length2;
extern const NSString * Private_Service_UUID;
extern const NSString * Private_Service_Tx_Characteristic_UUID;


NS_ASSUME_NONNULL_BEGIN

//@interface OpType : NSObject
//
//@end

NS_ASSUME_NONNULL_END
