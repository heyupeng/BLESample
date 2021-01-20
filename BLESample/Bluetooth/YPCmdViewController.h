//
//  YPCmdViewController.h
//  YPDemo
//
//  Created by Peng on 2019/3/4.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPBleManager.h"
#import "YPBleDevice.h"

NS_ASSUME_NONNULL_BEGIN

//@class YPBleManager, YPBleDevice;

@interface YPCmdViewController : UIViewController

@property (nonatomic, strong) YPBleManager * bleManager;
@property (nonatomic, strong) YPBleDevice * device;

@end

NS_ASSUME_NONNULL_END
