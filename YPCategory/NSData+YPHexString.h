//
//  NSData+YPHexString.h
//  YPDemo
//
//  Created by Peng on 2019/3/11.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (YPHexString)

/*
 16进制字符串转数据流 @"03000c0004000643" => <03000c00 04000643>
 0.57 sec / 100,000
 */
+ (NSData *)dataWithHexString:(NSString *)hexString;

/*
 数据流转16进制字符串 <03000c00 04000643> => @"03000c0004000643"
 */
- (NSString *)hexString;

/*
 数据流转数字 <0643> => 163
 */
- (NSInteger)hexIntergerValue;

- (NSInteger)hexLongLongValue;

@end

NS_ASSUME_NONNULL_END
