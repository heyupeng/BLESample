//
//  UIWebView+YPJS2OC.m
//  YPDemo
//
//  Created by Peng on 2018/10/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "UIWebView+YPJS2OC.h"

NSString * const kUIWebViewJSContext = @"documentView.webView.mainFrame.javaScriptContext";

@implementation UIWebView (YPJS2OC)

- (JSContext *)jsContext {
    JSContext * jscontext = [self valueForKeyPath:kUIWebViewJSContext];
    return jscontext;
}

@end
