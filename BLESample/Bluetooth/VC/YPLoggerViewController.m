//
//  YPLoggerViewController.m
//  SOOCASBLE
//
//  Created by Peng on 2019/7/22.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import "YPLoggerViewController.h"

static YPLogger * share_logger ;

@interface YPLoggerViewController ()

@property (nonatomic, strong) UITextView * tv;

@property (nonatomic, copy) NSMutableString * log;
@end

@implementation YPLoggerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initUI];
}

- (void)initUI {
    _log = [[NSMutableString alloc] initWithCapacity:500];

    _tv = [[UITextView alloc] init];
    _tv.editable = NO;
    self.view.layer.zPosition = 9;
    
    _tv.text = _log;
    [self.view addSubview: _tv];
    
    _tv.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 20);
}

- (void)appendLog:(NSString *)log {
    if (!_tv) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        UITextView * tv = self.tv;
        tv.text = self.log;
        
        if (tv.dragging || tv.decelerating || tv.tracking) {
            return;
        }
        CGSize size = tv.contentSize;
        size.height = size.height - CGRectGetHeight(tv.bounds);
        if (size.height < 0) {
            return;
        }
        CGPoint offset = CGPointMake(0, size.height);
        [tv setContentOffset:offset animated:YES];
    });
}

- (void)clean {
    _tv.text = @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

@implementation YPLogger
+ (instancetype)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share_logger = [[YPLogger alloc] init];
    });
    return share_logger;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _log = [[NSMutableString alloc] initWithCapacity:500];
    }
    return self;
}

- (YPLoggerViewController *)logVC {
    if (!_logVC) {
        _logVC = [[YPLoggerViewController alloc] init];
        _logVC.tv.text = _log;
    }
    return _logVC;
}

- (void)showOrHide {
    if (![YPLogger share].logVC.view.superview) {
        [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview: [YPLogger share].logVC.view];
    } else {
        [YPLogger share].logVC.view.hidden = ![YPLogger share].logVC.view.hidden;
    }
}

- (void)appendLog:(NSString *)log {
    if (_log.length < 1) {
        NSString * timeStr = [[NSDate date] yp_format:@"MM-dd hh:mm:ss.SSS"];
        [_log appendFormat:@"%@ \n  ", timeStr];
        [_log appendString: log];
    } else {
        [_log appendString:@"\n"];
        NSString * timeStr = [[NSDate date] yp_format:@"MM-dd hh:mm:ss.SSS"];
        [_log appendFormat:@"%@ \n  ", timeStr];
        [_log appendString:log];
    }
    
    _logVC.log = _log;
    [_logVC appendLog:_log];
}

- (void)clean {
    _log = [[NSMutableString alloc] initWithCapacity:500];
    
    [_logVC clean];
}
@end
