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

@interface YPBlueViewController ()
{
    NSString * _deviceName;
}
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UILabel * rssiValueLable;

@end

@implementation YPBlueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialData];
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addNotificationObserver];
    _blueManager = [YPBlueManager share];
    _blueManager.RSSIValue = 60;
    _blueManager.name = _deviceName;
    [_blueManager updateState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeNotificationObserver];
    
}

/** ============== **/
- (void)initialData {
    _dataSource = [NSMutableArray new];
    
    _deviceName = @"SMI-X";
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Scanner";
    
    UIBarButtonItem * right = [[UIBarButtonItem alloc] initWithTitle:@"Scan" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonAction:)];
    right.enabled = NO;
    self.navigationItem.rightBarButtonItem = right;
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, 44)];
    [self.view addSubview:view1];
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable.text = @"RSSI";
    [view1 addSubview:titleLable];
    
    UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(80, 0, SCREENWIDTH * 0.5, 44)];
    slider.minimumValue = 20;
    slider.maximumValue = 100;
    slider.value = 60;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [view1 addSubview:slider];
    
    UILabel * deltailLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(slider.frame) + 10, 0, 88, 44)];
    deltailLable.text = [NSString stringWithFormat:@"-%.0f dBm", slider.value];
    [view1 addSubview:deltailLable];
    _rssiValueLable = deltailLable;
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(view1.frame), SCREENWIDTH, 44)];
    [self.view addSubview:view2];
    
    UILabel * titleLable2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 60, 44)];
    titleLable2.text = @"name";
    [view2 addSubview:titleLable2];
    
    UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(80, 0, SCREENWIDTH * 0.5, 44)];
    tf.text = _deviceName;
    tf.userInteractionEnabled = NO;
    [view2 addSubview:tf];
    [tf addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    
    UITableView * tableView = [self createTableVie];
    tableView.frame = CGRectMake(0, CGRectGetMaxY(view2.frame) , SCREENWIDTH, SCREENHEIGHT - CGRectGetMaxY(view2.frame) - 20);
    tableView.clipsToBounds = YES;
    [self.view addSubview: tableView];
    _tableView = tableView;
}

- (void)rightBarButtonAction:(UIBarButtonItem *)button {
    if ([button.title isEqualToString:@"Scan"]) {
        [_blueManager startScan];
        button.title = @"Stop scan";
    } else {
        [_blueManager stopScan];
        button.title = @"Scan";
    }
    
}

- (void)sliderValueChanged:(UISlider *)slider {
    _rssiValueLable.text = [NSString stringWithFormat:@"-%.0f dBm", slider.value];

    _blueManager.RSSIValue = slider.value;
}

- (void)textFieldValueChanged:(UITextField *)tf {

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
   
    [tableView estimatedHeightZero];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return tableView;
}

/** ============== **/
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDiscoverDevice:) name: YPBLE_DidUpdateState object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDiscoverDevice:) name: YPBLE_DidDiscoverDevice object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAboutDiscoverDevice: (NSNotification *)notification {
//    NSLog(@"notificationAboutDiscoverDevice");
//    YPDeviceManager * deviceManager = (YPDeviceManager *)[notification object];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString * name = notification.name;
        if ([name isEqualToString:YPBLE_DidUpdateState]) {
            if (_blueManager.manager.state == CBManagerStatePoweredOn) {
                [self.navigationItem.rightBarButtonItem setTitle:@"Scan"];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }else {
                [self.navigationItem.rightBarButtonItem setTitle:@"Open BlueTooth"];
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }
        }
        
        if ([name isEqualToString:YPBLE_DidDiscoverDevice]) {
            [_dataSource setArray:_blueManager.discoverDevices];
            [_tableView reloadData];
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
    YPDeviceManager * device = [_dataSource objectAtIndex:indexPath.row];
    NSString * title = device.deviceName;
    
    NSDictionary * serviceData = [device.advertisementData objectForKey: CBAdvertisementDataServiceDataKey];
    NSData * fe95 = [serviceData objectForKey:[CBUUID UUIDWithString:@"FE95"]];
    NSString * ip = [fe95 hexString];
    if (ip.length > 14) {
        ip = [ip substringFromIndex: ip.length - 12 - 2];
        ip = [ip substringToIndex: ip.length - 2];
    }
    ip = [NSString hexStringReverse:ip];
    
    NSData * manufacturerData = [device.advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString * localName = device.localName;
    
    cell.textLabel.text = [NSString stringWithFormat:@"name: %@, rssi: %.0f",title, device.RSSI.doubleValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"localName: %@  id: %@", localName, ip];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    YPDeviceManager * device = [_dataSource objectAtIndex:indexPath.row];
    
    [_blueManager stopScan];
    
//    YPDeviceViewController * viewController = [[YPDeviceViewController alloc] init];
//    viewController.blueManager = _blueManager;
//    viewController.deviceManager = device;
//    viewController.title = @"Services";
//    [self.navigationController pushViewController:viewController animated:YES];
//    return;

    YPCmdViewController * cmdVC = [[YPCmdViewController alloc] init];
    cmdVC.blueManager = _blueManager;
    cmdVC.deviceManager = device;
    cmdVC.title = @"Cmd";
    [self.navigationController pushViewController:cmdVC animated:YES];

}

@end
