//
//  YPLoggerViewController.h
//  SOOCASBLE
//
//  Created by Peng on 2019/7/22.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YPLoggerViewController;

@interface YPLogger : NSObject

@property (nonatomic, strong) YPLoggerViewController * logVC;
@property (nonatomic, copy) NSMutableString * log;

+ (instancetype)share;

- (void)showOrHide;

- (void)appendLog:(NSString *)log;

- (void)clean;

@end

@interface YPLoggerViewController : UIViewController

- (void)appendLog:(NSString *)log;

- (void)clean;

@end

NS_ASSUME_NONNULL_END
