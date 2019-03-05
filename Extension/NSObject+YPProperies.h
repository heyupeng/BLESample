//
//  NSObject+YPProperies.h
//  YPDemo
//
//  Created by Peng on 2018/10/24.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YPProperies)

- (NSArray *)allProperties;
- (NSArray *)allIvars;
@end

NS_ASSUME_NONNULL_END
