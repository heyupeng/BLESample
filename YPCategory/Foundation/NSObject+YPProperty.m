//
//  NSObject+YPProperty.m
//  YPDemo
//
//  Created by Peng on 2018/10/24.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "NSObject+YPProperty.h"
#import <objc/runtime.h>
#import "NSObject+YPClass.h"

static NSMutableDictionary * cacheClassPropertiesDict_;

@implementation YPProperty

- (NSString *)name {
    // 成员属性名
    const char * name = property_getName(_property);
    return @(name);
}

- (NSString *)attributes {
    // 成员属性类型
    const char * attributes = property_getAttributes(_property);
    return @(attributes);
}

@end

@implementation NSObject (YPProperty)

+ (NSMutableDictionary *)cacheClassPropertiesDict {
    @synchronized (self) {
        if (!cacheClassPropertiesDict_) {cacheClassPropertiesDict_ = [NSMutableDictionary new];}
        return cacheClassPropertiesDict_;
    }
}

+ (NSArray *)yp_properties {
    NSMutableArray * array ;//= [self cacheClassPropertiesDict][NSStringFromClass(self)];
    if (array) {
        return array;
    }
    
    array = [[NSMutableArray alloc] init];
    
    // 1.
    Class cls = self;
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    
    // 2.
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        
        YPProperty * pro = objc_getAssociatedObject([YPProperty class], property);
        if (!pro) {
            pro = [[YPProperty alloc] init];
            pro.property = property;
            objc_setAssociatedObject([YPProperty class], property, pro, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        pro.srcClass = cls;
        [array addObject:pro];        
    }
    
    // 3.
    free(properties);
    
//    [[self cacheClassPropertiesDict] setObject:array forKey:NSStringFromClass(self)];
    
    return array;
}


+ (NSArray *)yp_allProperties {
    NSMutableArray * array = [self cacheClassPropertiesDict][NSStringFromClass(self)];
    if (array) {
        return array;
    }
    
    array = [[NSMutableArray alloc] init];
    
    [self yp_enumrateClassesBlock:^(Class  _Nonnull __unsafe_unretained cls, BOOL * _Nonnull stop) {
        [cls yp_enumerateProperties:^(objc_property_t property) {
            YPProperty * pro = objc_getAssociatedObject([YPProperty class], property);
            if (!pro) {
                pro = [[YPProperty alloc] init];
                pro.property = property;
                objc_setAssociatedObject([YPProperty class], property, pro, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            pro.srcClass = cls;
            [array addObject:pro];
        }];
    }];
    
    [[self cacheClassPropertiesDict] setObject:array forKey:NSStringFromClass(self)];
    
    return array;
}

/**
 遍历所有成员(不含父类)
 */
+ (void)yp_enumerateProperties:(void(^)(objc_property_t property))block {
    if (!block) {return;}
    
    // 1.
    Class cls = self;
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    
    // 2.
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        // 成员属性名
        const char * name = property_getName(property);
        // 成员属性类型
        const char * attributes = property_getAttributes(property);
        
//        printf(" name: %s \t attribrute: %s \n", name, attributes);
        
        block(property);
    }
    
    // 3.
    free(properties);
}

+ (NSArray *)allIvars {
    Class class = self;
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList(class, &outCount);
    
    for (int i = 0; i < outCount; i ++) {
        Ivar v = ivars[i];
        const char *name = ivar_getName(v);
        const char *type = ivar_getTypeEncoding(v);
        printf("%s %s\n", name, type);
    }
    return nil;
}

@end
