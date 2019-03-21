//
//  YPUpgradeViewController.m
//  YPDemo
//
//  Created by Peng on 2017/11/10.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPUpgradeViewController.h"
#import "FileTableViewController.h"
#import "DFUManager.h"
#import "YPDFUManager.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface YPUpgradeViewController ()<DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>
@property (nonatomic) DFUManager * dfuManager;
@property (nonatomic) DfuState currentDfuState;

@property (nonatomic) FileTableViewController *  fileVC;

@property (nonatomic) YPDFUManager * dfuManager_xiaosu;

@property (nonatomic, strong) UITextView * tv;

// Nordic DFU
@property (nonatomic, strong) DFUServiceInitiator * dfuInitiator;
@property (nonatomic, strong) DFUServiceController * dfuController;

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
        _fileLabel.text = _fileVC.filePath;
    }
}
- (void)dealloc {
    [self removeNotificationObserver];
}

/** ============== **/

- (void)initialData {
    _dfuManager = [[DFUManager alloc] init];
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"固件升级";
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, SCREENWIDTH, 40 * 2)];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"请选择文件";
    _fileLabel = label;
    [self.view addSubview:label];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake((SCREENWIDTH - 100) * 0.5, 200, 100, 60);
    [button setTitle:@"升级" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor yellowColor]];
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UITextView * tv = [[UITextView alloc] init];
    tv.backgroundColor = [UIColor whiteColor];
    tv.editable = NO;
    tv.frame = CGRectMake(0, 300 + 10, SCREENWIDTH, CGRectGetHeight(self.view.bounds) - 300 - 20 - 64);
    [self.view addSubview:tv];
    _tv = tv;
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithTitle:@"file" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonClick:)];
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
    
    NSString * ext = [filePath pathExtension];
    if ([ext isEqualToString:@"img"]) {
        _dfuManager_xiaosu = [[YPDFUManager alloc] initWithDeviceManager:_blueManager.currentDevice];
        [_dfuManager_xiaosu setUrl: [filePath UTF8String]];
        [_dfuManager_xiaosu startUpgrade];
        return;
    }
//    _dfuManager.firmwareFilePath = filePath;
//    [_dfuManager setCentralManager:_blueManager.manager];
//    [_dfuManager connectDevice:_blueManager.currentDevice.peripheral];
    
    DFUServiceInitiator * dfuInitiator = [self dfuServiceInitiator];
    dfuInitiator.jumpToBootloaderEncryption = YES; // 自定义属性
    
    NSString * zipFile = filePath; // [[NSBundle mainBundle] pathForResource:@"X5_2019031101" ofType:@"zip"];
    DFUFirmware * firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL URLWithString:zipFile] type:DFUFirmwareTypeApplication];
    
    _dfuInitiator = [dfuInitiator withFirmware:firmware];
    [dfuInitiator start];
}

- (DFUServiceInitiator *)dfuServiceInitiator {
    DFUServiceInitiator * dfuInitiator = [[DFUServiceInitiator alloc] initWithCentralManager:_blueManager.manager target: _blueManager.currentDevice.peripheral];
    dfuInitiator.delegate = self;
    dfuInitiator.progressDelegate = self;
    dfuInitiator.logger = self;
    
//    dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = YES; // 允许secureDFU下buttonless模式(SMI-X5、SMI-M1S) x
    dfuInitiator.alternativeAdvertisingNameEnabled = NO; // 不可重命名
    return dfuInitiator;
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
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.tv.text.length > 1) {
            _tv.text = [_tv.text stringByAppendingFormat:@"\n%@",append];
        } else {
            self.tv.text = append;
        }
        [self autoScroll];
    });
}

/** ============== **/
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothStateChanged:) name:NotificationWithBluetoothStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dfuStateChanged:) name:NotificationWithDfuStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dfuProgressChanged:) name:NotificationWithDfuProgressChanged object:nil];
    
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

- (void)dfuStateChanged:(NSNotification *) noti
{
    NSString * text = @"";
    switch ([noti.object integerValue]) {
        case DfuStateSearching:{
            text = @"查找设备中...";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_currentDfuState == DfuStateSearching) {
                    NSLog(@"查找设备超时！");
                    [_dfuManager stopScanDevice];
                }
            });
            break;
        }
        case DfuStateConnecting:{
            text = @"连接设备中...";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_currentDfuState == DfuStateConnecting) {
                    NSLog(@"设备连接超时！");
                    [_dfuManager stopConnectDevice];
                }
            });
            break;
        }
        case DfuStateStartUpload:
            text = @"开始升级固件";
            break;
        case DfuStateUploading:
            text = @"升级固件中...";
            break;
        case DfuStateComplete:
            text = @"固件升级完成";
            break;
        case DfuStateError:
            text = @"固件升级失败！";
            break;
        default:
            break;
    }
    [self textforTextViewByAppending: text];

}

- (void)dfuProgressChanged:(NSNotification *) noti
{
    NSString * text = [NSString stringWithFormat:@"升级进度：%zi", [noti.object integerValue]];
    NSLog(@"%@", text);
    [self textforTextViewByAppending: text];
}


#pragma mark - DFUInitiator Delegate
- (void)dfuStateDidChangeTo:(enum DFUState)state {
    NSLog(@"dfuState: %@", [self DFUStateDescription:state]);
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.dfuStatusLabel.text = [self DFUStateDescription:state];
    });
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message {
    NSLog(@"error:%ld - %@",error, message);
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    NSLog(@"propress: %ld", progress);
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.progressLabel.text = [NSString stringWithFormat:@"%ld%%", progress];
    });
}

- (void)logWith:(enum LogLevel)level message:(NSString *)message {
    NSLog(@"log: %ld - %@", level, message);
}

- (NSString *)DFUStateDescription:(DFUState)state {
    switch (state) {
        case DFUStateConnecting:      return @"Connecting";
        case DFUStateStarting:        return @"Starting";
        case DFUStateEnablingDfuMode: return @"Enabling DFU Mode";
        case DFUStateUploading:       return @"Uploading";
        case DFUStateValidating:      return @"Validating"  ;// this state occurs only in Legacy DFU
        case DFUStateDisconnecting:   return @"Disconnecting";
        case DFUStateCompleted:       return @"Completed";
        case DFUStateAborted:         return @"Aborted";
    }
}
@end
