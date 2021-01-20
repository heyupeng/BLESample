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

@interface YPBlueViewController ()<UITextFieldDelegate>
{
    NSDictionary * _bleConfig;
    
    UIButton * _logBtn;
}
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UILabel * rssiValueLable;
@property (nonatomic, strong) UITextField * nameTextField;;
@property (nonatomic, strong) UITextField * macTextField;;

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
    btn.frame = CGRectMake(0, 44, 60, 60);
    btn.layer.cornerRadius = 60 * 0.5;
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
    UIEdgeInsets insets = UIEdgeInsetsMake(44, 0, 34, 0);
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
    _blueManager = [YPBleManager share];
    [_blueManager bleEnabled];
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
        };
    }
    _bleConfig = bleConfig;
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
    
    // tool bar
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 44)];
    [self.view addSubview:view1];
    
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
    
    // name tag
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(view1.frame), SCREENWIDTH, 44)];
    [self.view addSubview:view2];
    
    UILabel * titleLable2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable2.text = @"Name";
    [view2 addSubview:titleLable2];
    
    UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(80, 0 + (44  - 36)*0.5, SCREENWIDTH * 0.5, 36)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.keyboardType = UIKeyboardTypeASCIICapable;
    tf.text = [_bleConfig objectForKey:@"localName"];
    tf.delegate = self;
//    tf.userInteractionEnabled = NO;
    [view2 addSubview:tf];
    _nameTextField = tf;
    [tf addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    // mac tag
    UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(view2.frame), SCREENWIDTH, 44)];
    [self.view addSubview:view3];
    
    UILabel * titleLable_mac = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable_mac.text = @"Mac";
    [view3 addSubview:titleLable_mac];
    
    UITextField * tf_mac = [[UITextField alloc] initWithFrame:CGRectMake(80, 0 + (44  - 36)*0.5, SCREENWIDTH * 0.5, 36)];
    tf_mac.borderStyle = UITextBorderStyleRoundedRect;
    tf_mac.keyboardType = UIKeyboardTypeASCIICapable;
    tf_mac.text = [_bleConfig valueForKey:@"mac"];
    tf_mac.delegate = self;
    [tf_mac addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];

    [view3 addSubview:tf_mac];
    _macTextField = tf_mac;
    
    // 主列表
    UITableView * tableView = [self createTableVie];
    tableView.frame = CGRectMake(0, CGRectGetMaxY(view3.frame) , SCREENWIDTH, SCREENHEIGHT - CGRectGetMaxY(view3.frame));
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

- (void)rightBarButtonAction:(UIBarButtonItem *)button {
    if ([button.title isEqualToString:@"Scan"]) {
        _dataSource = [NSMutableArray new];
        [self.tableView reloadData];
        
        [[YPLogger share] clean];
        
        NSString * localName = _nameTextField.text;
        NSString * mac = _macTextField.text;
        
        [self setBleConfig:@{@"localName": localName, @"mac": mac}];
        
        _blueManager.bleConfiguration.localName = localName;
        _blueManager.bleConfiguration.mac = mac;
        _blueManager.bleConfiguration.withoutDataIntercept = YES;
        _blueManager.bleConfiguration.unnamedIntercept = YES;

        [_blueManager startScan];
        button.title = @"Stop scan";
    } else {
        [_blueManager stopScan];
        button.title = @"Scan";
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [_nameTextField resignFirstResponder];
    [_macTextField resignFirstResponder];
}

- (void)sliderValueChanged:(UISlider *)slider {
    _rssiValueLable.text = [NSString stringWithFormat:@"-%.0f dBm", slider.value];
    
    _blueManager.bleConfiguration.RSSIValue = slider.value;
    
}

- (void)textFieldValueChanged:(UITextField *)tf {
    if (tf == _nameTextField) {
        
    } else {
        
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString * name = notification.name;
        if ([name isEqualToString:YPBLEManager_DidUpdateState]) {
            if (self.blueManager.manager.state == CBManagerStatePoweredOn) {
                [self.navigationItem.rightBarButtonItem setTitle:@"Scan"];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }else {
                [self.navigationItem.rightBarButtonItem setTitle:@"Open BlueTooth"];
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
        
        if ([name isEqualToString:YPBLEManager_DidDiscoverDevice]) {
            [self.dataSource setArray:self.blueManager.discoverDevices];
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
    NSString * name = device.deviceName;
    
    NSDictionary * serviceData = [device.advertisementData objectForKey: CBAdvertisementDataServiceDataKey];
    NSData * fe95 = [serviceData objectForKey:[CBUUID UUIDWithString:@"FE95"]];
    NSString * ip = fe95.hexString;
    
    NSString * localName = device.localName;
    
    NSData * specificData = device.specificData;
    NSString * specificDataHexString = specificData.hexString;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (📶 %.0f dBm)", name, device.RSSI.doubleValue];
    
    NSInteger detailTextNumberOfLines = 5;
    NSString * companyID = device.companysData.hexString.hexStringReverse;
    if (companyID) companyID = [NSString stringWithFormat:@"<0x%@>", companyID];
    NSString * detailText = [NSString stringWithFormat:@"UUID: %@ \
                                 \nLocalName: %@ \
                                 \nCompany: %@ \
                                 \nSpecificData: %@ \
                                 \nMac: %@",device.identifier, localName, companyID, specificDataHexString, device.mac.hexString.uppercaseString];
    
    cell.detailTextLabel.numberOfLines = detailTextNumberOfLines;
    cell.detailTextLabel.text = detailText;
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20 * (1 + 5);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    YPBleDevice * device = [_dataSource objectAtIndex:indexPath.row];
    
    [_blueManager stopScan];
    
    YPDeviceViewController * viewController = [[YPDeviceViewController alloc] init];
    viewController.blueManager = _blueManager;
    viewController.device = device;
    viewController.title = @"Services";
    [self.navigationController pushViewController:viewController animated:YES];

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    
    YPBleDevice * device = [_dataSource objectAtIndex:indexPath.row];
    
    NSMutableString * str = [NSMutableString new];
    __block NSTimeInterval time = 0;
    [device.RSSIRecords enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval time1 = [(NSDate *)[obj objectForKey:@"date"] timeIntervalSince1970];
        [str appendFormat: @"%@: %@ (%.4f ms)\n", [(NSDate *)[obj objectForKey:@"date"] yp_short_description], [[obj objectForKey:@"rssi"] stringValue], time==0?0:time1 - time];
        time = time1;
    }];
    
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:[@"RSSI" stringByAppendingFormat:@"(dBm) %lu More", device.RSSIRecords.count] message:str preferredStyle:UIAlertControllerStyleActionSheet];
    [ac addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [ac dismissViewControllerAnimated:YES completion:nil];
    }]];
     [self presentViewController:ac animated:YES completion:nil];
}

@end
