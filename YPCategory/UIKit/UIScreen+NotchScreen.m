//
//  UIScreen+NotchScreen.h
//  YPDemo
//
//  Created by Mac on 2020/09/30.
//  Copyright © 2020 heyupeng. All rights reserved.
//

#import "UIScreen+NotchScreen.h"

@implementation UIScreen (yp_NotchScreen)

- (CGFloat)yp_screenRatio {
    CGSize screenSize = self.bounds.size;// [UIScreen mainScreen].bounds.size;
    return MIN(screenSize.width, screenSize.height) / MAX(screenSize.width, screenSize.height);
}

/**
 * 缺口屏、全面屏、刘海屏。
 * @discussion 通过设备尺寸比例判断状态了是否为刘海屏。screenRatio < 0.56 为 ture。
 * iPhone   |   Size    |   AspectRatio
 * iPhone4      320x480      0.667      3.5
 * iPhone5      320x568      0.562      4.0
 * iPhone6      375x667      0.563      4.7
 * iPhone6S    414x736      0.562      5.5
 * iPhoneX      375x812      0.462      5.8
 * iPhoneXR   414x896      0.462       6.5
 */
- (BOOL)yp_isNotchScreen {
    if (TARGET_OS_IPHONE) {
        float screenRatio = [self yp_screenRatio];
        if (screenRatio < 0.56) {
            return YES;
        }
    }
    return NO;
}

@end

@implementation UIApplication (yp_StatusBarManager)

- (BOOL)yp_isStatusBarHidden {
    BOOL hidden = YES;
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 13.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
//        UIWindowScene * scene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.allObjects.firstObject
        UIWindowScene * scene = [UIApplication sharedApplication].delegate.window.windowScene;
        // StatusBarManager
        UIStatusBarManager * statusManager = [scene statusBarManager];
        hidden = [statusManager isStatusBarHidden];
#pragma clang diagnostic push
    } else {
        hidden = [self isStatusBarHidden];
    }
    return hidden;
}

-(UIInterfaceOrientation)yp_statusBarOrientation  {
    UIInterfaceOrientation orientation;
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 13.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        orientation = [UIApplication sharedApplication].delegate.window.windowScene.interfaceOrientation;
#pragma clang diagnostic push
    } else {
        orientation = [self statusBarOrientation];
    }
    return orientation;
}

- (CGRect)yp_statusBarFrame {
    CGRect frame = CGRectZero;
    NSString * systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion floatValue] >= 13.0) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
        UIWindowScene * scene = [UIApplication sharedApplication].delegate.window.windowScene;
        // StatusBarManager
        UIStatusBarManager * statusManager = [scene statusBarManager];
        frame = [statusManager statusBarFrame];
#pragma clang diagnostic push
    } else {
        frame = [self statusBarFrame];
    }
    return frame;
}

@end

@implementation UIApplication (yp_safeAreaInsets)

- (UIEdgeInsets)yp_safeAreaInsets {
//    return self.delegate.window.safeAreaInsets;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if (TARGET_OS_TV) {return insets;}
    
    BOOL hidden = [[UIApplication sharedApplication] yp_isStatusBarHidden];
    if (!hidden) {
        insets.top = CGRectGetHeight([[UIApplication sharedApplication] yp_statusBarFrame]);
    }
    
    if (![[UIScreen mainScreen] yp_isNotchScreen]) {
        return insets;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] yp_statusBarOrientation];
    // 横屏
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    if (landscape) {
        insets.left = insets.right = 44;
        insets.bottom = 21;
    } else {
        insets.top = 44;
        insets.bottom = 34;
    }
    
    return insets;
}

@end
