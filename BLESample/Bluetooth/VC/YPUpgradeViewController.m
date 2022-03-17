//
//  YPUpgradeViewController.m
//  YPDemo
//
//  Created by Peng on 2017/11/10.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPUpgradeViewController.h"
#import "FileTableViewController.h"

//#import "SOCDFUManager.h"

#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

#import "YPSUOTA.h"
#import "YPNordicDFU.h"

@interface YPUpgradeViewController ()<NordicDFUDelegate>
//@property (nonatomic) SOCDFUManager * dfuManager;
//@property (nonatomic) SOCDFUState currentDfuState;

@property (nonatomic) FileTableViewController *  fileVC;

@property (nonatomic) YPSUOTA * dfuManager_xiaosu;

// UI
@property (nonatomic, strong) UIProgressView * progressView;

@property (nonatomic, strong) UITextView * tv;

// Nordic DFU
@property (nonatomic, strong) DFUServiceInitiator * dfuInitiator;
@property (nonatomic, strong) DFUServiceController * dfuController;

// NordicDFU
@property (nonatomic, strong) YPNordicDFU * nordicDFU;
@property (nonatomic) BOOL rename;
@property (nonatomic) BOOL encrypt;
@property (nonatomic, strong) NSString * encryptString;

@end

@implementation YPUpgradeViewController

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
//    _dfuManager = [[SOCDFUManager alloc] init];
    
    _rename = YES;
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
    NSString * message = @"Note: \
        \n1. X5: v1.02以下广播信息 localName 不允许被重置，DFU mode 需携带加密信息0x15f1。v1.02及以上，升级前发送升级许可指令。";
    UILabel * label_note = [[UILabel alloc] initWithFrame:CGRectMake(20, y, SCREENWIDTH - 20 * 2, 35 * 3)];
    label_note.numberOfLines = -1;
    label_note.textAlignment = NSTextAlignmentLeft;
    label_note.text = message;
    [self.view addSubview:label_note];
    
    y += CGRectGetHeight(label_note.frame) + 10;
    
    UIButton * renameBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, y, 120, 30)];
    [renameBtn setTitle:@"Rename" forState:UIControlStateNormal];
    [renameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    renameBtn.backgroundColor = [UIColor greenColor];
    renameBtn.selected = _rename;
    renameBtn.layer.borderWidth = 1;
    [self.view addSubview:renameBtn];
    [renameBtn addTarget:self action:@selector(rename:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * encryptBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(renameBtn.frame) + 20, y, 120, 30)];
    [encryptBtn setTitle:@"Encrypt" forState:UIControlStateNormal];
    [encryptBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    encryptBtn.backgroundColor = [UIColor whiteColor];
    encryptBtn.selected = _encrypt;
    encryptBtn.layer.borderWidth = 1;
    [self.view addSubview:encryptBtn];
    [encryptBtn addTarget:self action:@selector(encrypt:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)rename:(UIButton *)sender {
    _rename = !_rename;
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.backgroundColor = [UIColor greenColor];
    } else {
        sender.backgroundColor = [UIColor whiteColor];
    }
}

- (void)encrypt:(UIButton *)sender {
    void(^encrypt)(BOOL) = ^(BOOL encrypt) {
        sender.selected = encrypt;
        if (sender.selected) {
            sender.backgroundColor = [UIColor greenColor];
        } else {
            sender.backgroundColor = [UIColor whiteColor];
        }
    };
    
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"Encrypt" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"85150616";
        textField.placeholder = @"0x85150616";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"0x15f1" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * text = action.title;
        if ([text hasPrefix:@"0x"]) {
            text = [text substringFromIndex:2];
        }
        self.encryptString = text;
        self.encrypt = YES;
        
        encrypt(self.encrypt);
    }]];
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"0x85150616" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * text = action.title;
        if ([text hasPrefix:@"0x"]) {
            text = [text substringFromIndex:2];
        }
        self.encryptString = text;
        self.encrypt = YES;
        
        encrypt(self.encrypt);
    }]];
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString * text = [[alertC.textFields objectAtIndex:0] text];
        if ([text hasPrefix:@"0x"]) {
            text = [text substringFromIndex:2];
        }
        
        self.encryptString = text;
        self.encrypt = YES;
        
        encrypt(self.encrypt);
    }]];
    
    [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.encryptString = @"";
        self.encrypt = NO;
        sender.selected = self.encrypt;
        if (sender.selected) {
            sender.backgroundColor = [UIColor redColor];
        } else {
            sender.backgroundColor = [UIColor whiteColor];
        }
    }]];
    [self presentViewController:alertC animated:YES completion:nil];
    
    //    _encrypt = !_encrypt;
    //    sender.selected = !sender.selected;
    //    if (sender.selected) {
    //        sender.backgroundColor = [UIColor redColor];
    //    } else {
    //        sender.backgroundColor = [UIColor whiteColor];
    //    }
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
    //    _dfuManager.firmwareFilePath = filePath;
    //    [_dfuManager setCentralManager:_bleManager.manager];
    //    [_dfuManager connectDevice:_bleManager.currentDevice.peripheral];
    
    [self startDFU];
}

- (void)startDFU {
    NSString *filePath = _fileVC.filePath;
    
    NSArray * encrptBuffers_X5 = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0x15], [NSNumber numberWithInteger:0xf1], nil];
    NSArray * encrptBuffers_M1S = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0x85], [NSNumber numberWithInteger:0x15], [NSNumber numberWithInteger:0x06], [NSNumber numberWithInteger:0x16], nil];
    
    _nordicDFU = [[YPNordicDFU alloc] initWithCentralManager:_bleManager.manager peripheral:_bleManager.currentDevice.peripheral];
    _nordicDFU.delegate = self;
    
    DFUFirmware * firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL URLWithString:filePath]];
    [_nordicDFU setFirmware:firmware];
    
    // rename
    _nordicDFU.dfuInitiator.alternativeAdvertisingNameEnabled = _rename;
    
    // encrypt
    if (self.encrypt) {
        NSArray * encrptBuffers = [[NSData dataWithHexString:self.encryptString] hexArray];
        [_nordicDFU startDFUWithEncrypt:self.encrypt encryptData:encrptBuffers filePath:filePath];
    } else {
        [_nordicDFU startDFU];
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
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothStateChanged:) name:NotificationWithBluetoothStateChanged object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dfuStateChanged:) name:NotificationWithDfuStateChanged object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dfuProgressChanged:) name:NotificationWithDfuProgressChanged object:nil];
//
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

//- (void)dfuStateChanged:(NSNotification *) noti
//{
//    NSString * text = @"";
//    switch ([noti.object integerValue]) {
//        case SOCDFUStateSearching:{
//            text = @"查找设备中...";
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (self.currentDfuState == SOCDFUStateSearching) {
//                    NSLog(@"查找设备超时！");
//                    [self.dfuManager stopScanDevice];
//                }
//            });
//            break;
//        }
//        case SOCDFUStateConnecting:{
//            text = @"连接设备中...";
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                if (self.currentDfuState == SOCDFUStateConnecting) {
//                    NSLog(@"设备连接超时！");
//                    [self.dfuManager stopConnectDevice];
//                }
//            });
//            break;
//        }
//        case SOCDFUStateStartUpload:
//            text = @"开始升级固件";
//            break;
//        case SOCDFUStateUploading:
//            text = @"升级固件中...";
//            break;
//        case SOCDFUStateComplete:
//            text = @"固件升级完成";
//            break;
//        case SOCDFUStateError:
//            text = @"固件升级失败！";
//            break;
//        default:
//            break;
//    }
//    [self textforTextViewByAppending: text];
//    
//}
//
//- (void)dfuProgressChanged:(NSNotification *) noti
//{
//    NSString * text = [NSString stringWithFormat:@"升级进度：%i", [noti.object intValue]];
//    NSLog(@"%@", text);
//    [self textforTextViewByAppending: text];
//}


#pragma mark - DFUInitiator Delegate
- (void)dfuStateDidChangeTo:(enum DFUState)state {
    NSString * text = [NSString stringWithFormat:@"dfuState: %@", [_nordicDFU descriptionForDFUState:state]];
    NSLog(@"%@", text);
    [self textforTextViewByAppending: text];
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message {
    NSString * text = [NSString stringWithFormat:@"error:%d - %@",error, message];
    NSLog(@"%@",text);
    [self textforTextViewByAppending: text];
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    NSString * text = [NSString stringWithFormat:@"propress: %ld", progress];
    NSLog(@"%@",text);
    dispatch_async(dispatch_get_main_queue(), ^{
        //        self.progressLabel.text = [NSString stringWithFormat:@"%ld%%", progress];
        self.progressView.progress = progress / 100.0;
        [self textforTextViewByAppending: text];
    });
}

- (void)logWith:(enum LogLevel)level message:(NSString *)message {
    NSString * text = [NSString stringWithFormat:@"log: %ld - %@", level, message];
    NSLog(@"%@",text);
    [self textforTextViewByAppending: text];
}

#pragma mark -tf
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
