//
//  NSDate+YPExtension.h
//  YPDemo
//
//  Created by MAC on 2019/12/4.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (YPExtension)

@end

@interface NSDate (YPDescription)
- (NSString *)yp_description;
@end

NS_ASSUME_NONNULL_END
