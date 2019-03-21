//
//  NSString+YPMessageDigest.m
//  YPDemo
//
//  Created by Peng on 2018/5/17.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "NSString+YPMessageDigest.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MD5)

+ (NSString *)md5: (NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return [output lowercaseString];
}

- (NSString *)md5 {
    return [NSString md5:self];
}

@end
