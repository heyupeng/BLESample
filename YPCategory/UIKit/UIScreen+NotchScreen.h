//
//  UIScreen+NotchScreen.h
//  YPDemo
//
//  Created by Mac on 2020/09/30.
//  Copyright © 2020 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 屏幕是否缺口屏（全面屏、刘海屏，iOS11）。
@interface UIScreen (yp_NotchScreen)
/// 屏幕宽高比（短长比)。
- (CGFloat)yp_screenRatio;

/// 缺口屏 、全面屏、刘海屏
- (BOOL)yp_isNotchScreen;
@end

/// 状态栏API变更兼容 (iOS 13，状态栏相关属性转移到 UIStatusBarManager 下)
@interface UIApplication (yp_StatusBarManager)

/// 状态栏是否隐藏。
- (BOOL)yp_isStatusBarHidden;

/// 状态栏方向。
-(UIInterfaceOrientation)yp_statusBarOrientation;

/// 状态栏区域。
- (CGRect)yp_statusBarFrame;

@end

@interface UIApplication (yp_safeAreaInsets)
/// 当前屏幕安全区域嵌入位。
- (UIEdgeInsets)yp_safeAreaInsets;

@end

NS_ASSUME_NONNULL_END
