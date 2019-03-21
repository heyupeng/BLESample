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

#import "YPBluetooth/YPBluetooth.h"

#import "CommunicationProtocol/SOCBlueToothWriteData.h"

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

    [_blueManager connectDevice:_deviceManager];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    [_blueManager disConnectDevice:_deviceManager];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutBlueManager:) name:YPBLE_DidConnectedDevice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDeviceManager:) name: YPDevice_DidDiscoverServices object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDeviceManager:) name: YPDevice_DidDiscoverCharacteristics object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutDeviceManager:) name: YPDevice_DidUpdateValue object:nil];

}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAboutBlueManager: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([notification.name isEqualToString:YPBLE_DidConnectedDevice]) {
            [self.deviceManager.peripheral discoverServices:nil];
        }

    });
}

- (void)notificationAboutDeviceManager: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([notification.name isEqualToString:YPDevice_DidDiscoverServices]) {
            [self.dataSource setArray:self.deviceManager.peripheral.services];
            [self.tableView reloadData];
        }
        
        if ([notification.name isEqualToString:YPDevice_DidDiscoverCharacteristics]) {
            [self.dataSource setArray:self.deviceManager.peripheral.services];
            [self.tableView reloadData];
        }
        
        if ([notification.name isEqualToString:YPDevice_DidUpdateValue]) {
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
    NSString * title = [UUID UUIDString];
    
    NSString * valueString = [[NSString alloc] initWithData:[character value] encoding:NSUTF8StringEncoding];
    
    cell.textLabel.text = [NSString stringWithFormat:@"character: %@ (%@)",UUID, title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", valueString, [character value]];
    
    if ([UUID.UUIDString isEqualToString:@"2A19"]) {
        long value = [[character value].hexString hexStringToLongValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %% %@", value, [character value]];
        [_deviceManager IntToCBUUID:0x2a19];
        [_deviceManager CBUUIDToInt:UUID];

    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView * header = (UITableViewHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    CBService * service = [_dataSource objectAtIndex:section];
    CBUUID * UUID = [service UUID];
    NSString * title = [UUID UUIDString];
    
    header.textLabel.text = [NSString stringWithFormat:@"CBServices: %@ (%@)", UUID, title];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    CBService * service = [_dataSource objectAtIndex:indexPath.section];
    CBCharacteristic * characteristic = [service.characteristics objectAtIndex:indexPath.row];
    
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"]]) {
        [_deviceManager setNotifyVuale:YES forCharacteristicUUID:[CBUUID UUIDWithString:NordicUARTServiceRxCharacteristicUUID] serviceUUID:[CBUUID UUIDWithString:NordicUARTServiceUUID]];
//        YPCmdViewController * cmdVC = [[YPCmdViewController alloc] init];
//        cmdVC.blueManager = _blueManager;
//        cmdVC.deviceManager = _deviceManager;
//        cmdVC.title = @"Cmd";
//        [self.navigationController pushViewController:cmdVC animated:YES];
//        return;
    }
//    YPUpgradeViewController * viewController = [[YPUpgradeViewController alloc] init];
//    viewController.blueManager = _blueManager;
//    [self.navigationController pushViewController:viewController animated:YES];
    [_deviceManager writeFFValue:[SOCBlueToothWriteData getSendStringOfSetFuncionWith:0]];
}

@end
