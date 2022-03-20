//
//  YPBlueViewController.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPBlueViewController.h"

#import "YPDeviceViewController.h"
#import "YPCmdViewController.h"
#import "ObjdectModel.h"

#import "YPLoggerViewController.h"

@implementation UINavigationBar (BackgroundView_BuiltIn)

- (void)setBuiltInBackgroundColor:(UIColor *)backgroundColor {
    /**
     UINavigationBar UI 层级结构
     UINavigationBar ; 高度 height = 44；大标题风格高度 height = 96；
        -- _UIBarBackground ; // 背景层。高度 height = 44 + safe.top (20 or 44)
        -- _UINavigationBarLargeTitleView ; // 大标题层。origin.x = 44;
        -- _UINavigationBarContentView ; // 导航栏层 (0 0; 375, 44)
        -- UIView ;
     
     */
    for (UIView * view in self.subviews) {
        NSString * cls = @"_UIBarBackground";
        if ([NSStringFromClass(view.class) hasPrefix:cls]) {
            view.backgroundColor = backgroundColor;
        }
        cls = @"_UINavigationBarLargeTitleView";
        if ([NSStringFromClass(view.class) hasPrefix:cls]) {
            view.backgroundColor = backgroundColor;
        }
    }
}
@end

@interface BTOptionsView : UIView

@property (weak, nonatomic) IBOutlet UISlider *rssiSlider;

@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *switchs;

@end

@implementation BTOptionsView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    NSDictionary * bleConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"bleConfig"];
    if (bleConfig) {
        NSNumber * RSSI = [bleConfig objectForKey:@"Max.RSSI"];
        if (RSSI) {
            self.rssiSlider.value = RSSI.intValue;
            self.rssiLabel.text = [NSString stringWithFormat:@"-%.0d dbm", RSSI.intValue];
        }
        
        NSString * localName = [bleConfig objectForKey:@"localName"];
        if (localName) {
            [self.textFields[0] setText:localName];
        }
        
        NSString * mac = [bleConfig objectForKey:@"mac"];
        if (mac) {
            [self.textFields[1] setText:localName];
        }
        
        BOOL isOn = [[bleConfig objectForKey:@"unnamedIntercept"] boolValue];;
        if (mac) {
            [self.switchs[0] setOn:isOn];
        }
        
        isOn = [[bleConfig objectForKey:@"withoutDataIntercept"] boolValue];;
        if (mac) {
            [self.switchs[1] setOn:isOn];
        }
    }
}

- (void)updateCacheWith:(NSDictionary *)ele {
    NSDictionary * old = [[NSUserDefaults standardUserDefaults] objectForKey:@"bleConfig"];
    NSMutableDictionary * new = [NSMutableDictionary new];
    [new addEntriesFromDictionary:old];
    [new addEntriesFromDictionary:ele];
    
    [NSUserDefaults.standardUserDefaults setObject:new forKey:@"bleConfig"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    for (UITextField * tf in self.textFields) {
        [tf resignFirstResponder];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * view = [super hitTest:point withEvent:event];
    if (![view isKindOfClass:[UITextField class]]) {
        for (UITextField * tf in self.textFields) {
            [tf resignFirstResponder];
        }
    }
    return view;
}
- (IBAction)sliderValueChanged:(UISlider *)sender {
    NSString * text = [NSString stringWithFormat:@"-%.0f dbm", sender.value];
    self.rssiLabel.text = text;
    
    YPBleManager.share.settings.RSSIValue = sender.value;
    
    [self updateCacheWith:@{@"Max.RSSI": @(sender.value)}];
}

- (IBAction)EditingDidEnd:(UITextField *)sender {
    NSString * text = sender.text? : @"";
    NSUInteger index = [_textFields indexOfObject:sender];
    
    switch (index) {
        case 0:
            YPBleManager.share.settings.localName = text;
            [self updateCacheWith:@{@"localName": text}];
            break;
        case 1:
            YPBleManager.share.settings.mac = text;
            [self updateCacheWith:@{@"mac": text}];
        default:
            break;
    }
    
}

- (IBAction)switchAction:(UISwitch *)sender {
    switch (sender.tag) {
        case 0:
            YPBleManager.share.settings.unnamedIntercept = sender.on;
            [self updateCacheWith:@{@"unnamedIntercept": @(sender.on)}];
            break;
        case 1:
            YPBleManager.share.settings.withoutDataIntercept = sender.on;
            [self updateCacheWith:@{@"withoutDataIntercept": @(sender.on)}];
        default:
            break;
    }
}

@end

@interface TableCellItem : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * subtitle;

+ (instancetype)itemWithDevice:(YPBleDevice *)device;
- (instancetype)initWithDevice:(YPBleDevice *)device;

@end

@implementation TableCellItem

+ (instancetype)itemWithDevice:(YPBleDevice *)device {
    return [[self alloc] initWithDevice:device];
}

- (instancetype)initWithDevice:(YPBleDevice *)device {
    self = [super init];
    
    AdvertisementDataHelper * advHelper = [AdvertisementDataHelper advertisementDataWith:device.advertisementData];
    
    _title = [NSString stringWithFormat:@"%@ (%.0f dBm)", device.deviceName, device.RSSI.doubleValue];

    NSString * localName = advHelper.localName;
//    NSData * specificData = advHelper.specificData;
        
    // subtitle
    NSMutableString * detailText = [[NSMutableString alloc] init];
    [detailText appendFormat:@"UUID: %@ \
                                 \nLocalName: %@ \
                                 ",device.identifier, localName];
    
    if (advHelper.manufacturerData) {
        NSString * companyID = advHelper.companysData.hexString.hexStringReverse;
        NSString * spcific = advHelper.specificData.hexString;
        [detailText appendFormat:@"\nCompany: <0x%@>", companyID];
        [detailText appendFormat:@"\nSpecificData: %@", spcific];
    }
    
    if (advHelper.serviceData) {
        NSDictionary * serviceData = advHelper.serviceData;
        [detailText appendFormat:@"\nServiceData:"];
        for (CBUUID * uuid in serviceData.allKeys) {
            NSData * value = serviceData[uuid];
            NSString * str = [NSString stringWithFormat:@"\n %@ %@", uuid.UUIDString, value.hexString.hexStringReverse];
            [detailText appendString:str];
        }
    }
    
    _subtitle = detailText;
    
    return self;
}

- (CGSize)textSizeWithContentSize:(CGSize)size {
    CGRect textBound = [self.subtitle boundingRectWithSize:size options:1 attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil];
    return textBound.size;
}

@end

#pragma mark - BlueViewController

@interface YPBlueViewController ()<UITextFieldDelegate>
{
    NSDictionary * _bleConfig;
    
    UIButton * _logBtn;
}
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UILabel * rssiValueLable;

/// @[nameTF, macTF, nameInterceptTF]
@property (nonatomic, strong) NSMutableArray<UITextField *> * textFields;

@property (nonatomic, strong) BTOptionsView * optionView;
@end

@implementation YPBlueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialData];
    
    [self initUI];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"LOG" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showLogAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    btn.frame = CGRectMake(88, 44, 44, 44);
    btn.layer.cornerRadius = CGRectGetHeight(btn.bounds) * 0.5;
    btn.layer.zPosition = 10;
    [[UIApplication sharedApplication].keyWindow addSubview:btn];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panGestureRecognizerActionForFrame:)];
    [btn addGestureRecognizer:pan];
    _logBtn = btn;
}

- (void)panGestureRecognizerActionForFrame:(UIPanGestureRecognizer *)sender {
    // 获取手势的移动，也是相对于最开始的位置
    UIView * v = sender.view;
    CGPoint offset = [sender translationInView:v];
    
    CGRect bounds = v.superview.frame;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, -10, -10, -10);
    if (sender.state == UIGestureRecognizerStateEnded) {
        insets = [[UIApplication sharedApplication] yp_safeAreaInsets]; // UIEdgeInsetsMake(44, 0, 34, 0);
    }
    
    bounds = UIEdgeInsetsInsetRect(bounds, insets);
    
    CGRect newFrame = CGRectOffset(v.frame, offset.x, offset.y);
    
    if (newFrame.origin.x < CGRectGetMinX(bounds)) {
        offset.x += CGRectGetMinX(bounds) - newFrame.origin.x;
    } else if (CGRectGetMaxX(newFrame) > CGRectGetMaxX(bounds)) {
        offset.x += CGRectGetMaxX(bounds) - CGRectGetMaxX(newFrame);
    }
    if (newFrame.origin.y < CGRectGetMinY(bounds)) {
        offset.y += CGRectGetMinY(bounds) - newFrame.origin.y;
    } else if (CGRectGetMaxY(newFrame) > CGRectGetMaxY(bounds)) {
        offset.y += CGRectGetMaxY(bounds) - CGRectGetMaxY(newFrame);
    }
    
    v.transform = CGAffineTransformTranslate(v.transform, offset.x, offset.y);
    
    // 复位
    [sender setTranslation:CGPointZero inView:v];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            
        }];
    }
}

- (void)showLogAction:(UIButton *)btn {
    [[YPLogger share] showOrHide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addNotificationObserver];
    
    [_bleManager checkBleEnabled:^(BOOL enabled, BLEOpErrorCode code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rightBarButtonAction:self.navigationItem.rightBarButtonItem];
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeNotificationObserver];
    
}

- (NSArray<CBUUID *> *)services {
    CBUUID * serviceUUID1 = [CBUUID UUIDWithString:@"FE59"];
    CBUUID * serviceUUID2 = [CBUUID UUIDWithString:@"180A"];
    CBUUID * serviceUUID3 = [CBUUID UUIDWithString:@"FEF5"]; // 小素晶片suota
    return @[serviceUUID1, serviceUUID2, serviceUUID3];
}

/** ============== **/
- (void)initialData {
    _dataSource = [NSMutableArray new];
    
    NSDictionary * bleConfig = [[NSUserDefaults standardUserDefaults] objectForKey:@"bleConfig"];
    if (!bleConfig) {
        bleConfig = @{
            @"localName": @"SMI-",
            @"mac": @"",
            @"RSSI": @60,
            @"ignoreLocalName": @"",
        };
    }
    _bleConfig = bleConfig;
    
    _bleManager = [YPBleManager share];
    
    _bleManager.settings.openConnectionTimer = YES;
    _bleManager.settings.connectionTimeoutPeriod = 5;
    
//    _bleManager.settings.services = [self services];
    _bleManager.settings.RSSIValue = [[bleConfig objectForKey:@"RSSI"] intValue];
    _bleManager.settings.localName = [bleConfig objectForKey:@"localName"];
    _bleManager.settings.mac = [bleConfig objectForKey:@"mac"];
    
    NSString * ignoreLocalName = [bleConfig objectForKey:@"ignoreLocalName"];
    _bleManager.settings.ignoreLocalNames = ignoreLocalName.length > 0? [ignoreLocalName componentsSeparatedByString:@","] : nil;
    _bleManager.settings.withoutDataIntercept = [bleConfig objectForKey:@"withoutDataIntercept"];
    _bleManager.settings.unnamedIntercept = [bleConfig objectForKey:@"unnamedIntercept"];
    
    _bleManager.settings.logger = ^(NSString *message) {
        [[YPLogger share] appendLog:message];
    };
}

- (void)setBleConfig:(NSDictionary *)info {
    NSMutableDictionary * temp = [NSMutableDictionary new];
    [temp setDictionary:_bleConfig];
    [temp addEntriesFromDictionary:info];
    _bleConfig = temp;
    [[NSUserDefaults standardUserDefaults] setObject:_bleConfig forKey:@"bleConfig"];
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIColor * navTintColor = [UIColor colorWithRed:0x6/255.0 green:0xAA/255.0 blue:0xC9/255.0 alpha:1];
//    self.navigationController.navigationBar.backgroundColor = [UIColor colorWithRed:0x3d/255.0 green:0xB9/255.0 blue:0xBF/255.0 alpha:1];
    self.navigationController.navigationBar.barTintColor = navTintColor;
    [self.navigationController.navigationBar setBuiltInBackgroundColor:navTintColor];
    
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return [UIColor blackColor];
            }
            return [UIColor whiteColor];
        }];
    }
    
    self.title = @"Scanner";
    
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    right.enabled = NO;
    self.navigationItem.rightBarButtonItem = right;
    
    UIBarButtonItem * left = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonAction:)];
    self.navigationItem.leftBarButtonItem = left;
    
    // 主列表
    UITableView * tableView = [self createTableVie];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    tableView.clipsToBounds = YES;
    [self.view addSubview: tableView];
    _tableView = tableView;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.frame;
    CGRect frame;
    frame = _tableView.frame;
    frame.size.width = CGRectGetWidth(rect);
    frame.size.height = CGRectGetHeight(rect) - CGRectGetMinY(frame);
    _tableView.frame = frame;
}

- (void)leftBarButtonAction:(UIBarButtonItem *)button {
    if (!_optionView) {
        NSArray * views = [NSBundle.mainBundle loadNibNamed:@"BTOptionsView" owner:nil options:nil];
        _optionView = views[0];
        _optionView.frame = self.view.bounds;
        [self.view addSubview:_optionView];
    }
    if (!button) {
        _optionView.hidden = YES;
    } else {
        _optionView.hidden = !_optionView.hidden;
    }
    
    return;
    // tool bar
    static UIView * configView;
    
    if (!button) {
        configView.superview.hidden = YES;
        return;
    }
    if (configView) {
        configView.superview.hidden = !configView.superview.hidden;
        return;
    }
    _textFields = [[NSMutableArray alloc] initWithCapacity:4];
    
    configView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 44)];
    configView.backgroundColor = [UIColor whiteColor];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 44)];
    [configView addSubview:view1];
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable.text = @"RSSI";
    [view1 addSubview:titleLable];
    
    UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 0, SCREENWIDTH * 0.5, 44)];
    slider.minimumValue = 20;
    slider.maximumValue = 100;
    slider.value = [(NSNumber *)[_bleConfig objectForKey:@"RSSI"] intValue]; // 60;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view1 addSubview:slider];
    
    UILabel * deltailLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(slider.frame) + 10, 0, 88, 44)];
    deltailLable.text = [NSString stringWithFormat:@"-%.0f dBm", slider.value];
    [view1 addSubview:deltailLable];
    _rssiValueLable = deltailLable;
    
    // 1. name tag
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(view1.frame), SCREENWIDTH, 44)];
    [configView addSubview:view2];
    
    UILabel * titleLable2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable2.text = @"Name";
    [view2 addSubview:titleLable2];
    
    UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(80, 0 + (44  - 36)*0.5, SCREENWIDTH * 0.5, 36)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.keyboardType = UIKeyboardTypeASCIICapable;
    tf.text = [_bleConfig objectForKey:@"localName"];
    tf.delegate = self;
//    tf.userInteractionEnabled = NO;
//    [tf addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [view2 addSubview:tf];
    _textFields[0] = tf;
    
    // 2. mac tag
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(view2.frame), SCREENWIDTH, 44)];
    [configView addSubview:view3];
    
    UILabel * titleLable_mac = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable_mac.text = @"Mac";
    [view3 addSubview:titleLable_mac];
    
    UITextField * tf_mac = [[UITextField alloc] initWithFrame:CGRectMake(80, 0 + (44  - 36)*0.5, SCREENWIDTH * 0.5, 36)];
    tf_mac.borderStyle = UITextBorderStyleRoundedRect;
    tf_mac.keyboardType = UIKeyboardTypeASCIICapable;
    tf_mac.text = [_bleConfig valueForKey:@"mac"];
    tf_mac.delegate = self;
//    [tf_mac addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];

    [view3 addSubview:tf_mac];
    _textFields[1] = tf_mac;
    
    // 2. 拦截携带名称
    UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(view3.frame), SCREENWIDTH, 44)];
    [configView addSubview:view4];
    
    UILabel * titleLable3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable3.text = @"忽略名";
    [view4 addSubview:titleLable3];
    
    UITextField * tf3 = [[UITextField alloc] initWithFrame:CGRectMake(80, 0 + (44  - 36)*0.5, SCREENWIDTH * 0.5, 36)];
    tf3.borderStyle = UITextBorderStyleRoundedRect;
    tf3.keyboardType = UIKeyboardTypeASCIICapable;
    tf3.delegate = self;
//    [tf3 addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view4 addSubview:tf3];
    _textFields[2] = tf3;
    tf3.placeholder = @"多个忽略名以,分隔";
    tf3.text = [_bleConfig valueForKey:@"ignoreLocalName"];
    
    CGRect newFrame = configView.frame;
    newFrame.size.height = CGRectGetMaxY(view4.frame);
    configView.frame = newFrame;
    
    UIView * v = [[UIView alloc] initWithFrame:self.view.bounds];
    v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [v addSubview:configView];
    
    [self.view addSubview:v];
}

- (void)rightBarButtonAction:(UIBarButtonItem *)button {
    if ([button.title isEqualToString:@"Scan"]) {
        _dataSource = [NSMutableArray new];
        [self.tableView reloadData];
        
        [[YPLogger share] clean];
        
        [_bleManager startScan];
        button.title = @"Stop scan";
    } else {
        [_bleManager stopScan];
        button.title = @"Scan";
    }
    
    [self leftBarButtonAction: nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    for (UITextField * textField in _textFields) {
        [textField resignFirstResponder];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    _rssiValueLable.text = [NSString stringWithFormat:@"-%.0f dBm", slider.value];
    
    [self setBleConfig:@{@"RSSI": @((int)slider.value)}];
    
    _bleManager.settings.RSSIValue = slider.value;
}

- (void)textFieldDidEndEditing:(UITextField *)tf {
    if (tf == _textFields[0]) {
        NSString * localName = _textFields[0].text ? : @"";
        
        [self setBleConfig:@{@"localName": localName}];
        
        _bleManager.settings.localName = localName;
    }
    else if (tf == _textFields[1]) {
        NSString * mac = _textFields[1].text? : @"";
        
        [self setBleConfig:@{@"mac": mac}];
        
        _bleManager.settings.mac = mac;
    }
    else if (tf == _textFields[2]) {
        NSString * ignoreName = _textFields[2].text? : @"";
        
        [self setBleConfig:@{@"ignoreLocalName": ignoreName}];
        
        NSArray * ignoreLocalNames = ignoreName ? [ignoreName componentsSeparatedByString:@","]: nil;
        _bleManager.settings.ignoreLocalNames = ignoreLocalNames;
    }
}

/** ============== **/
- (UITableView *)createTableVie {
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
//    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [tableView estimatedHeightZero];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return tableView;
}

/** ============== **/
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDiscoverDevice:) name: YPBLEManager_DidUpdateState object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDiscoverDevice:) name: YPBLEManager_DidDiscoverDevice object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAboutDiscoverDevice: (NSNotification *)notification {
//    NSLog(@"notificationAboutDiscoverDevice");
//    YPBleDevice * device = (YPBleDevice *)[notification object];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * name = notification.name;
        if ([name isEqualToString:YPBLEManager_DidUpdateState]) {
            if (self.bleManager.manager.state == CBManagerStatePoweredOn) {
                [self.navigationItem.rightBarButtonItem setTitle:@"Scan"];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }else {
                [self.navigationItem.rightBarButtonItem setTitle:@"Open Bluetooth"];
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
        
        if ([name isEqualToString:YPBLEManager_DidDiscoverDevice]) {
            [self.dataSource setArray:self.bleManager.discoverDevices];
            [self.tableView reloadData];
        }
    });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: tableViewCellDefaultIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableViewCellDefaultIdentifier];
    }
    YPBleDevice * device = [_dataSource objectAtIndex:indexPath.row];
    TableCellItem * item = [TableCellItem itemWithDevice:device];
    
    NSString * detailText = item.subtitle;
    NSInteger detailTextNumberOfLines = 10;
    
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = detailText;
    cell.detailTextLabel.numberOfLines = detailTextNumberOfLines;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YPBleDevice * device = [_dataSource objectAtIndex:indexPath.row];
    TableCellItem * item = [TableCellItem itemWithDevice:device];
    
    CGSize size = UIScreen.mainScreen.bounds.size;
    size.height = 200;
    size = [item textSizeWithContentSize:size];
    return 20 * 3 + size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    YPBleDevice * device = [_dataSource objectAtIndex:indexPath.row];
    
    [_bleManager stopScan];
    
    YPDeviceViewController * viewController = [[YPDeviceViewController alloc] init];
    viewController.bleManager = _bleManager;
    viewController.device = device;
    viewController.title = @"Services";
    [self.navigationController pushViewController:viewController animated:YES];

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    YPBleDevice * device = [_dataSource objectAtIndex:indexPath.row];
    
    NSMutableString * str = [NSMutableString new];
    __block NSTimeInterval time = 0;
    [device.RSSIRecords enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate * date = (NSDate *)[obj objectForKey:@"date"];
        NSTimeInterval time1 = [date timeIntervalSince1970];
        [str appendFormat: @"[%@] %@ (%.4f s)\n", [date yp_format:@"HH:mm:ss.SSS"], [[obj objectForKey:@"rssi"] stringValue], time == 0 ? 0 : (time1 - time)];
        time = time1;
    }];
    
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:[@"RSSI" stringByAppendingFormat:@"(dBm) %zi More", device.RSSIRecords.count] message:str preferredStyle:UIAlertControllerStyleActionSheet];
    [ac addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [ac dismissViewControllerAnimated:YES completion:nil];
    }]];
     [self presentViewController:ac animated:YES completion:nil];
}

@end
