//
//  UIWebView+YPJSContext.m
//  YPDemo
//
//  Created by Peng on 2018/10/29.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "UIWebView+YPJSContext.h"

NSString * const kUIWebViewJSContext = @"documentView.webView.mainFrame.javaScriptContext";

@implementation UIWebView (YPJSContext)

- (JSContext *)yp_jsContext {
    JSContext * jscontext = [self valueForKeyPath:kUIWebViewJSContext];
    return jscontext;
}

@end
