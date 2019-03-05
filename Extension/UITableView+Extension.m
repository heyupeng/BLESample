//
//  UITableView+Extension.m
//  YPDemo
//
//  Created by Peng on 2018/5/28.
//  Copyright © 2018年 heyupeng. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView (Extension)

- (void)estimatedHeightZero {
    // ios11下 self-size 默认开启.
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
}

@end
