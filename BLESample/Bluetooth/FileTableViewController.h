//
//  FileTableViewController.h
//  YPDemo
//
//  Created by Peng on 2017/11/10.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileTableViewController : UIViewController

@property (strong) NSMutableArray *fileArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString * filePath;

@property (nonatomic, strong) NSArray<NSString *> * visiablePathExtension;
@end
