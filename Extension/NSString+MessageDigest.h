//
//  NSString+MessageDigest.h
//  YPDemo
//
//  Created by Peng on 2018/5/17.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)

+ (NSString *)md5:(NSString *)string;
- (NSString *)md5;

@end
