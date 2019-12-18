//
//  UIColor+YPColours.h
//  YPDemo
//
//  Created by Peng on 2018/1/4.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (YPColours)

@end


@interface UIColor (yp_randomColor)

+ (UIColor *)yp_randomColor;

@end

@interface UIColor (yp_additional)
- (UIColor *)yp_reverseColor;
@end
