//
//  NSObject+YPProperty.h
//  YPDemo
//
//  Created by Peng on 2018/10/24.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface YPProperty : NSObject

@property (nonatomic, assign) objc_property_t property;

@property (nonatomic, readonly) NSString * name;

@property (nonatomic, readonly) NSString * attributes;

@property (nonatomic, assign) Class srcClass;

@end

@interface NSObject (YPProperty)

+ (NSArray *)yp_properties;

+ (NSArray *)yp_allProperties;

+ (NSArray *)allIvars;

@end

NS_ASSUME_NONNULL_END
