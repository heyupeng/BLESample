//
//  NSDate+YPExtension.m
//  YPDemo
//
//  Created by MAC on 2019/12/4.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import "NSDate+YPExtension.h"

@implementation NSDate (YPExtension)

@end

@implementation NSDate (YPDescription)

- (NSString *)yp_format:(NSString *)format {
    if (!format) {return nil;}
    
    static NSDateFormatter * dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    dateFormatter.dateFormat = format;

    return [dateFormatter stringFromDate:self];
}

- (NSString *)yp_description {
    return [self yp_format:@"yyyy-MM-dd HH:mm:ss.SSS Z"];
}

- (NSString *)yp_short_description {
    return [self yp_format:@"HH:mm:ss.SSS"];
}

@end
