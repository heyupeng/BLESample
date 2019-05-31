//
//  YPDeviceViewController.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPDeviceViewController.h"
#import "YPUpgradeViewController.h"
#import "YPCmdViewController.h"

#import "YPBluetooth/YPBlueConst.h"

#import "CommunicationProtocol/SOCBluetoothWriteData.h"

@interface YPDeviceViewController ()

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@end

@implementation YPDeviceViewController

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

    [_blueManager connectDevice:_device];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    [_blueManager disConnectDevice:_device];
    [self removeNotificationObserver];
}
/** ============== **/
- (void)initialData {
    _dataSource = [NSMutableArray new];
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView * tableView = [self createTableVie];
    tableView.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT - 64);

    [self.view addSubview: tableView];
    _tableView = tableView;
}

/** ============== **/
- (UITableView *)createTableVie {
    CGRect rect = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    UITableView * tableView = [[UITableView alloc] initWithFrame:rect style: UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self setTableViewDefaultPropertys:tableView];
    
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCellDefaultIdentifier];
    [tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"header"];
    
    return tableView;
}

- (UITableView *)setTableViewDefaultPropertys: (UITableView *)tableView {
    tableView.clipsToBounds = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tableView estimatedHeightZero];
    
    if (@available(iOS 11.0, *)) {
        tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return tableView;
}

/** ============== **/
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutBlueManager:) name:YPBLEManager_DidConnectedDevice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidDiscoverServices object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidDiscoverCharacteristics object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidUpdateValue object:nil];

}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAboutBlueManager: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([notification.name isEqualToString:YPBLEManager_DidConnectedDevice]) {
            [self.device.peripheral discoverServices:nil];
        }

    });
}

- (void)notificationAboutdevice: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([notification.name isEqualToString:YPBLEDevice_DidDiscoverServices]) {
            [self.dataSource setArray:self.device.peripheral.services];
            [self.tableView reloadData];
        }
        
        if ([notification.name isEqualToString:YPBLEDevice_DidDiscoverCharacteristics]) {
            [self.dataSource setArray:self.device.peripheral.services];
            [self.tableView reloadData];
        }
        
        if ([notification.name isEqualToString:YPBLEDevice_DidUpdateValue]) {
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_dataSource[section] characteristics] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: tableViewCellDefaultIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableViewCellDefaultIdentifier];
    }
    CBService * service = [_dataSource objectAtIndex:indexPath.section];
    CBCharacteristic * character = [[service characteristics] objectAtIndex:indexPath.row];
    CBUUID * UUID = [character UUID];
    NSArray * propertyDescriptions = [character yp_propertyDescriptions];
    
    NSString * valueString = [[NSString alloc] initWithData:[character value] encoding:NSUTF8StringEncoding];
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.text = [NSString stringWithFormat:@"Characteristic: %@", UUID];
    
    NSMutableString * detailText = [[NSMutableString alloc] init];
    [detailText appendFormat:@"UUIDString: %@\n", [UUID UUIDString]];
    [detailText appendFormat:@"Properies: %@\n", [propertyDescriptions componentsJoinedByString:@"|"]];
    [detailText appendFormat:@"Value: (0x%@)", [character value].hexString];
    
    if ([UUID.UUIDString isEqualToString:@"2A19"]) {
        long value = [[character value].hexString hexStringToLongValue];
        [detailText appendFormat: @" %ld %%", value];
    } else {
        [detailText appendFormat: @" %@", valueString];
    }
    
    cell.detailTextLabel.numberOfLines = 3;
    cell.detailTextLabel.text = detailText;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView * header = (UITableViewHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    CBService * service = [_dataSource objectAtIndex:section];
    CBUUID * UUID = [service UUID];
    NSString * title = [UUID UUIDString];
    
    header.textLabel.numberOfLines = 2;
    header.textLabel.text = [NSString stringWithFormat:@"CBServices:%@ (0x%@)", UUID, title];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    CBService * service = [_dataSource objectAtIndex:indexPath.section];
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]]) {
        [_device setNotifyVuale:YES forCharacteristicUUID:[CBUUID UUIDWithString:NordicUARTRxCharacteristicUUIDString] serviceUUID:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]];
        
        YPCmdViewController * cmdVC = [[YPCmdViewController alloc] init];
        cmdVC.blueManager = _blueManager;
        cmdVC.device = _device;
        cmdVC.title = @"Cmd";
        [self.navigationController pushViewController:cmdVC animated:YES];
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"]] || [service.UUID isEqual:[CBUUID UUIDWithString:@"FE59"]]) {
        YPUpgradeViewController * viewController = [[YPUpgradeViewController alloc] init];
        viewController.blueManager = _blueManager;
        [self.navigationController pushViewController:viewController animated:YES];
        [_device writeFFValue:[SOCBluetoothWriteData commandForSetFuncionWith:0]];
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]] || [service.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) {
        CBCharacteristic * characteristic = [[service characteristics] objectAtIndex:indexPath.row];
        [_device.peripheral readValueForCharacteristic:characteristic];
    }
}

@end
