//
//  UIDevice+YPSysInfo.h
//  YPDemo
//
//  Created by Peng on 2018/1/23.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (yp_Platform)

/// 设备硬件号，如"iPhone10,3"
- (NSString *)machine;

/// 设备型号
- (NSString *)deviceType;

- (NSString *)platformString;

- (BOOL)isSimulator;

@end

NS_ASSUME_NONNULL_END
