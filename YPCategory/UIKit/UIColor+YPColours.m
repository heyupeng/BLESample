//
//  UIColor+YPColours.m
//  YPDemo
//
//  Created by Peng on 2018/1/4.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "UIColor+YPColours.h"

@implementation UIColor (YPColours)

@end


/**
 randomColor
 */
@implementation UIColor (yp_randomColor)

+ (UIColor *)yp_randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}
@end


@implementation UIColor (yp_additional)

- (UIColor *)yp_reverseColor {
    CGFloat f[4];
    [self getRed:f green:f+1 blue:f+2 alpha:f+3];
    return [UIColor colorWithRed:1-f[0] green:1-f[1] blue:1-f[2] alpha:f[3]];
}

@end
