//
//  NSObject+YPClass.h
//  YPDemo
//
//  Created by Peng on 2018/10/24.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YPClass)

+ (void)yp_enumrateAllClassesBlock:(void (^)(Class cls, BOOL * stop))block;

// 过滤来自Foundation框架类簇的父类
+ (void)yp_enumrateClassesBlock:(void (^)(Class cls, BOOL * stop))block;

@end

NS_ASSUME_NONNULL_END
