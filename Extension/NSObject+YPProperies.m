//
//  NSObject+YPProperies.m
//  YPDemo
//
//  Created by Peng on 2018/10/24.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "NSObject+YPProperies.h"
#import <objc/runtime.h>

@implementation NSObject (YPProperies)

- (NSArray *)allProperties {
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        
        unsigned int count1;
        objc_property_attribute_t * attributeList = property_copyAttributeList(property, &count1);
        
    }
    return nil;
}

- (NSArray *)allIvars {
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar v = ivars[i];
        const char *name = ivar_getName(v);
        const char *type = ivar_getTypeEncoding(v);
        printf("%s %s\n", name, type);
    }
    return nil;
}

@end
