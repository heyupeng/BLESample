//
//  ObjdectModel.h
//  YPDemo
//
//  Created by Peng on 2019/3/29.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjdectModel : NSObject

@property (nonatomic, strong, readonly) NSArray * array;

@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, copy) NSString * uuid;

@property (nonatomic, strong) NSURL * url;

@property (nonatomic, strong) id obj;

@property (nonatomic) NSInteger integerValue;

@property (nonatomic) int intValue;

@property (nonatomic) float floatValue;

@property (nonatomic) char charValue;

@property (nonatomic) short shortValue;

@property (nonatomic) long longValue;

@property (nonatomic) BOOL boolValue;

@property (nonatomic) bool bool2Value;

@end


NS_ASSUME_NONNULL_END
