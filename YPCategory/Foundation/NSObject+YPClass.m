//
//  NSObject+YPClass.m
//  YPDemo
//
//  Created by Peng on 2018/10/24.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "NSObject+YPClass.h"
#import <objc/runtime.h>

@implementation NSObject (YPClass)

+ (BOOL)isFromFoundation:(Class)cls {
    if (cls == [NSObject class]) {
        // 几乎所有类都继承自NSObject, 不能用(isKindOfClass:). 
        return YES;
    }
    return NO;
}

+ (void)yp_enumrateAllClassesBlock:(void (^)(Class cls, BOOL * stop))block {
    if (!block) {return;}
    
    Class class = self;
    BOOL stop = NO;
    
    while (class && !stop) {
        // .1
        block(class, &stop);
        // .2
        class = class_getSuperclass(class);
    }
}

// 过滤来自Foundation框架类簇的父类
+ (void)yp_enumrateClassesBlock:(void (^)(Class cls, BOOL * stop))block {
    if (!block) {return;}
    
    Class class = self;
    BOOL stop = NO;
    
    while (class && !stop) {
        // .1
        block(class, &stop);
        // .2
        class = class_getSuperclass(class);
        // .3
        if ([self isFromFoundation:class]) {
            break;
        }
    }
}

+ (void)yp_enumrateSuperclassesBlock:(void (^)(Class cls, BOOL * stop))block {
    if (!block) {return;}

    Class class = self;
    BOOL stop = NO;
    
    class = class_getSuperclass(class);
    while (class && !stop) {
        // .1
        block(class, &stop);
        // .2
        class = class_getSuperclass(class);
    }
}

@end
