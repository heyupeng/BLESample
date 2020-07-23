//
//  YPBlueViewController.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YPBleManager.h"
#import "YPBleMacro.h"

@interface YPBlueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YPBleManager * blueManager;

@end
