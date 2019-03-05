//
//  UIWebView+YPJS2OC.h
//  YPDemo
//
//  Created by Peng on 2018/10/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


UIKIT_EXTERN NSString *const kUIWebViewJSContext;

NS_ASSUME_NONNULL_BEGIN

@interface UIWebView (YPJS2OC)
//获取JS的运行环境
- (JSContext *)jsContext;

@end

NS_ASSUME_NONNULL_END
