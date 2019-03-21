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
@implementation UIColor (randomColor)

+ (UIColor *)randomColor {
    NSInteger aRedValue = arc4random() % 255;
    NSInteger aGreenValue = arc4random() % 255;
    NSInteger aBlueValue = arc4random() % 255;
    UIColor *randColor = [UIColor colorWithRed:aRedValue / 255.0f green:aGreenValue / 255.0f blue:aBlueValue / 255.0f alpha:1.0f];
    return randColor;
}
@end
