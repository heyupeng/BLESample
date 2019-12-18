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

static NSDateFormatter * dateFormatter_;

@implementation NSDate (YPDescription)

- (NSString *)yp_description {
    if (!dateFormatter_) {
        dateFormatter_ = [[NSDateFormatter alloc] init];
        [dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"];
    }
    return [dateFormatter_ stringFromDate:self];
}

@end
