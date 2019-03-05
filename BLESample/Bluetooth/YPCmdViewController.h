//
//  YPCmdViewController.h
//  YPDemo
//
//  Created by Peng on 2019/3/4.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YPBlueManager.h"
#import "YPDeviceManager.h"

NS_ASSUME_NONNULL_BEGIN

//@class YPBlueManager, YPDeviceManager;

@interface YPCmdViewController : UIViewController

@property (nonatomic, strong) YPBlueManager * blueManager;
@property (nonatomic, strong) YPDeviceManager * deviceManager;

@end

NS_ASSUME_NONNULL_END
