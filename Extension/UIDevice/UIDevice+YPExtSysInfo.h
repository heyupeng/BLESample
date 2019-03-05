//
//  UIDevice+YPExtSysInfo.h
//  YPDemo
//
//  Created by Peng on 2018/1/23.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (YPPlatform)

- (NSString *)machine;

- (NSString *)deviceType;

- (NSString *)platformString;

- (BOOL)isIPhoneX;
@end

NS_ASSUME_NONNULL_END
