//
//  YPSUOTAViewController.h
//  BLESample
//
//  Created by Mac on 2021/3/12.
//  Copyright © 2021 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPBleManager.h"
#import "YPBleDevice.h"
#import "YPSUOTA.h"

NS_ASSUME_NONNULL_BEGIN

@interface YPSUOTAViewController : UIViewController

@property (nonatomic, strong) YPBleManager * bleManager;

@property (nonatomic, strong) UILabel * fileLabel;

@end

NS_ASSUME_NONNULL_END
