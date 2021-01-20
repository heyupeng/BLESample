//
//  YPUpgradeViewController.h
//  YPDemo
//
//  Created by Peng on 2017/11/10.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPBleManager.h"
#import "YPBleDevice.h"

@interface YPUpgradeViewController : UIViewController

@property (nonatomic, strong) YPBleManager * bleManager;

@property (nonatomic, strong) UILabel * fileLabel;
@end
