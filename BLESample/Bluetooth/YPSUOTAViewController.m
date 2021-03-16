//
//  YPDFUViewController.m
//  BLESample
//
//  Created by Mac on 2021/3/12.
//  Copyright © 2021 heyupeng. All rights reserved.
//

#import "YPSUOTAViewController.h"

#import "FileTableViewController.h"

@interface YPSUOTAViewController ()

@property (nonatomic) FileTableViewController *  fileVC;

@property (nonatomic) YPSUOTA * dfuManager_xiaosu;

// UI
@property (nonatomic, strong) UIProgressView * progressView;

@property (nonatomic, strong) UITextView * tv;

@end

@implementation YPSUOTAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialData];
    
    [self initUI];
    
    [self addNotificationObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_fileVC && _fileVC.filePath) {
        _fileLabel.text = [_fileVC.filePath lastPathComponent];
    }
}
- (void)dealloc {
    [self removeNotificationObserver];
}

/** ============== **/

- (void)initialData {

}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"固件升级";
    
    CGFloat y = 10;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, SCREENWIDTH - 20 * 2, 35)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"请先选择文件";
    _fileLabel = label;
    [self.view addSubview:label];
    
    y += CGRectGetHeight(label.frame) + 10;
    
    UIProgressView * progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, y, SCREENWIDTH - 20 * 2, 5)];
    progressView.progress = 0;
    _progressView = progressView;
    [self.view addSubview:_progressView];
    
    y += CGRectGetHeight(progressView.frame) + 10;
        
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(20, 230, SCREENWIDTH - 20 * 2, 44);
    [button setTitle:@"升级" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorWithRed:0x3d/255.0 green:0xB9/255.0 blue:0xBF/255.0 alpha:1]];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UITextView * tv = [[UITextView alloc] init];
    tv.backgroundColor = [UIColor whiteColor];
    tv.editable = NO;
    tv.frame = CGRectMake(0, 280 + 10, SCREENWIDTH, CGRectGetHeight(self.view.bounds) - 300 - 20 - 64 - 44);
    [self.view addSubview:tv];
    _tv = tv;
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"File" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonClick:)];
    [self.navigationItem setRightBarButtonItem:rightButton];
}

- (void)rightButtonClick:(UIButton *)button {
    if (!_fileVC) {
        FileTableViewController * fileVC = [[FileTableViewController alloc] init];
        _fileVC = fileVC;
    }
    if ([self.navigationController.visibleViewController isEqual:_fileVC]) {
        return;
    }
    [self.navigationController pushViewController:_fileVC animated:YES];
}

- (void)click:(UIButton *)button {
    NSString *filePath = _fileVC.filePath;
    if (!filePath) {
        return;
    }
    
    NSString * ext = [filePath pathExtension];
    if ([ext isEqualToString:@"img"]) {
        _dfuManager_xiaosu = [[YPSUOTA alloc] initWithDevice:_bleManager.currentDevice];
        [_dfuManager_xiaosu setUrl: [filePath UTF8String]];
        [_dfuManager_xiaosu startUpgrade];
        return;
    }
}



- (void)autoScroll {
    CGSize contentSize = self.tv.contentSize;
    
    float dy = contentSize.height - CGRectGetHeight(self.tv.frame);
    if (dy < 0) {
        return;
    }
    [UIView animateWithDuration:0.02 animations:^{
        self.tv.contentOffset = CGPointMake(0, dy);
    }];
}

- (void)textforTextViewByAppending:(NSString *)append {
    if (self.tv.text.length > 1) {
        self.tv.text = [self.tv.text stringByAppendingFormat:@"\n%@",append];
    } else {
        self.tv.text = append;
    }
}

/** ============== **/
- (void)addNotificationObserver {
    
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** ============== **/

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)bluetoothStateChanged:(NSNotification *) noti
{
    if ([noti.object boolValue]) {
        NSLog(@"蓝牙已打开");
    }else{
        NSLog(@"蓝牙已关闭");
    }
}

#pragma mark -tf
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
