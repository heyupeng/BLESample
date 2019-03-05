//
//  YPUpgradeViewController.h
//  YPDemo
//
//  Created by Peng on 2017/11/10.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPBlueManager.h"
#import "YPDeviceManager.h"

@interface YPUpgradeViewController : UIViewController

@property (nonatomic, strong) YPBlueManager * blueManager;

@property (nonatomic, strong) UILabel * fileLabel;
@end
