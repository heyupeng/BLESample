//
//  FileTableViewController.m
//  YPDemo
//
//  Created by Peng on 2017/11/10.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "FileTableViewController.h"

@interface FileTableViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation FileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setTitle:@"选择一个文件"];
    [self.navigationItem.backBarButtonItem setTitle:@"Cancel"];
    
    self.fileArray = [self getFileListing];
    
    UITableView * tablezView = [self createTableView];
    tablezView.delegate = self;
    tablezView.dataSource = self;
    self.tableView = tablezView;
    [self.view addSubview:tablezView];
    [self.tableView reloadData];
}

- (void) didDisconnectFromDevice:(NSNotification*)notification {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/** ============== **/
- (UITableView *)createTableView {
    CGRect rect = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    UITableView * tableView = [[UITableView alloc] initWithFrame:rect style: UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self setTableViewDefaultPropertys:tableView];
    
//    tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    //    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellDefaultIdentifier];
    return tableView;
}

- (UITableView *)setTableViewDefaultPropertys: (UITableView *)tableView {
    tableView.clipsToBounds = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tableView estimatedHeightZero];
    
    if (@available(iOS 11.0, *)) {
//        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return tableView;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.fileArray) {
        return 0;
    }
    return [self.fileArray count];
}

-(NSString *)sizeConversionForByte:(NSNumber *)size {
    long value = [size integerValue];
    int i = 0;
    NSArray * units = @[@"B", @"KB", @"MB", @"GB", @"TB"];
    while (value > 1024) {
        value = value / 1024;
        i ++;
        if (i == [units count]) {
            break;
        }
    }
    return [NSString stringWithFormat:@"%ld %@", value, [units objectAtIndex:i]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fileCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"fileCell"];
    }
    
    NSString *fileName = [self.fileArray objectAtIndex:indexPath.row];
    NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", fileName]];
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [fileURL getResourceValue:&fileSizeValue
                       forKey:NSURLFileSizeKey
                        error:&fileSizeError];
    
    NSArray *parts = [fileName componentsSeparatedByString:@"/"];
    NSString *baseName = [parts objectAtIndex:[parts count]-1];
    [cell.textLabel setText:baseName];
    cell.detailTextLabel.text = [self sizeConversionForByte:fileSizeValue];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];

    NSString *fileName = [self.fileArray objectAtIndex:indexPath.row];
    NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", fileName]];
    
    _filePath = [NSString stringWithFormat:@"%@", fileName];
//    ParamaterStorage *storage = [ParamaterStorage getInstance];
//    storage.file_url = fileURL;
    
    if ([fileName.pathExtension isEqualToString:@"mov"] || [fileName.pathExtension isEqualToString:@"mp4"]) {
        
    }
}

- (NSMutableArray *)getFileListing {
    
    NSMutableArray *retval = [NSMutableArray array];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *publicDocumentsDir = [paths objectAtIndex:0];
    
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:publicDocumentsDir error:&error];
    if (files == nil) {
        NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
        return retval;
    }
    
    for (NSString *file in files) {
        if ([file.pathExtension compare:@"zip" options:NSCaseInsensitiveSearch] == NSOrderedSame || [file.pathExtension compare:@"bin" options:NSCaseInsensitiveSearch] == NSOrderedSame || [file.pathExtension compare:@"img" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            NSString *fullPath = [publicDocumentsDir stringByAppendingPathComponent:file];
            [retval addObject:fullPath];
        }
    }
    
//    for (NSString *file in files) {
//        if ([file.pathExtension compare:@"mp4" options:NSCaseInsensitiveSearch] == NSOrderedSame || [file.pathExtension compare:@"mov" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//            NSString *fullPath = [publicDocumentsDir stringByAppendingPathComponent:file];
//            [retval addObject:fullPath];
//        }
//    }
    
//    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    NSArray * p2 =[[NSBundle mainBundle] pathsForResourcesOfType:@"zip" inDirectory:nil];
    if (p2) {
        [retval addObjectsFromArray:p2];
    }
    
    NSArray * p3 =[[NSBundle mainBundle] pathsForResourcesOfType:@"img" inDirectory:nil];
    if (p3) {
        [retval addObjectsFromArray:p3];
    }
    
    return retval;
}

@end
