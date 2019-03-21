//
//  YPBlueViewController.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YPBlueManager.h"
#import "YPDeviceManager.h"

@interface YPBlueViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YPBlueManager * blueManager;

@end