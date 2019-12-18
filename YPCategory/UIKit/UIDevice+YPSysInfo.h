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

- (NSString *)machine;

- (NSString *)deviceType;

- (NSString *)platformString;

- (BOOL)isSimulator;

@end

@interface UIDevice (yp_iPhoneX)

- (BOOL)isIPhoneX;

- (BOOL)isIPhoneXLine;

@end

NS_ASSUME_NONNULL_END
