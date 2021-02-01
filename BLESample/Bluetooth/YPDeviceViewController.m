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

#import "YPBleMacro.h"

#import "CommunicationProtocol/SOCCommander.h"

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

    [_bleManager connectDevice:_device];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    [_bleManager disconnectDevice:_device];
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
    UITableView * tableView = [[UITableView alloc] initWithFrame:rect style: UITableViewStyleGrouped];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutBleManager:) name:YPBLEManager_DidConnectedDevice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutManagerError:) name:YPBLEManager_BleOperationError object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidDiscoverServices object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidDiscoverCharacteristics object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidUpdateValue object:nil];

}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAboutBleManager: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([notification.name isEqualToString:YPBLEManager_DidConnectedDevice]) {
            [self.device.peripheral discoverServices:nil];
        }

    });
}

- (void)notificationAboutManagerError: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (![notification.name isEqualToString:YPBLEManager_BleOperationError]) {
            return;
        }
        id obj = [notification object];
        obj = [obj objectForKey:@"bleOpError"];
        [self bleManagerError:[obj integerValue]];
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

/* ble Manager */
- (void)bleManagerError:(BLEOperationErrorCode)error {
    if (error == BLEOperationErrorFailToConnect) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        
    }
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@", CBUUIDGetDescription(UUID)];
    
    NSMutableString * detailText = [[NSMutableString alloc] init];
    [detailText appendFormat:@"UUID: %@\n", [UUID UUIDString]];
    [detailText appendFormat:@"Properies: %@\n", [propertyDescriptions componentsJoinedByString:@"|"]];
    [detailText appendFormat:@"Value: (0x%@)", [character value].hexString];
    
    if ([UUID.UUIDString isEqualToString:@"2A19"]) {
        long value = [[character value].hexString yp_hexStringToLongValue];
        [detailText appendFormat: @" %ld %%", value];
    } else {
        [detailText appendFormat: @" %@", valueString];
    }
    
    cell.detailTextLabel.numberOfLines = 3;
    cell.detailTextLabel.text = detailText;
    return cell;
}

NSString * CBUUIDGetDescription(CBUUID * UUID) {
    NSString * UUIDString = UUID.UUIDString;
    if ([UUIDString isEqualToString:NordicUARTServiceUUIDString])           return @"Nordic UART Service";
    if ([UUIDString isEqualToString:NordicUARTRxCharacteristicUUIDString])  return @"Rx Characteristic";
    if ([UUIDString isEqualToString:NordicUARTTxCharacteristicUUIDString])  return @"Tx Characteristic";
    
    if ([UUIDString isEqualToString:LegacyDFUServiceUUIDString])        return @"Legacy DFU Service";
    if ([UUIDString isEqualToString:LegacyDFUControlPointUUIDString])   return @"Legacy DFU Control Point";
    if ([UUIDString isEqualToString:LegacyDFUPacketUUIDString])         return @"Legacy DFU Packet";
    if ([UUIDString isEqualToString:LegacyDFUVersionUUIDString])        return @"Legacy DFU Version";
    
    if ([UUIDString isEqualToString:SecureDFUServiceUUIDString])        return @"Secure DFU Service";
    if ([UUIDString isEqualToString:SecureDFUControlPointUUIDString])   return @"Secure DFU Control Point";
    if ([UUIDString isEqualToString:SecureDFUPacketUUIDString])         return @"Secure DFU Packet";
    
    if ([UUIDString isEqualToString:ButtonlessDFUServiceUUIDString])          return @"Buttonless DFU Service";
    if ([UUIDString isEqualToString:ButtonlessDFUCharacteristicUUIDString])   return @"Buttonless DFU";
    if ([UUIDString isEqualToString:ButtonlessDFUWithoutBondsUUIDString])     return @"Buttonless DFU Without Bonds";
    if ([UUIDString isEqualToString:ButtonlessDFUWithBondsUUIDString])        return @"Buttonless DFU With Bonds";
    
    return UUID.description;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView * header = (UITableViewHeaderFooterView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    
    CBService * service = [_dataSource objectAtIndex:section];
    CBUUID * UUID = [service UUID];
    NSString * title = [UUID UUIDString];
    
    NSString * UUIDName = CBUUIDGetDescription(UUID);
    
    header.textLabel.numberOfLines = 2;
    header.textLabel.text = [NSString stringWithFormat:@"%@", UUIDName];
    header.detailTextLabel.text = [NSString stringWithFormat:@"UUID: 0x%@", title];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        return 60;
    }
    return 20+60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    CBService * service = [_dataSource objectAtIndex:indexPath.section];
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]]) {
        [_device setNotifyVuale:YES forCharacteristicUUID:[CBUUID UUIDWithString:NordicUARTRxCharacteristicUUIDString] serviceUUID:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]];
        
        YPCmdViewController * cmdVC = [[YPCmdViewController alloc] init];
        cmdVC.bleManager = _bleManager;
        cmdVC.device = _device;
        cmdVC.title = @"Cmd";
        [self.navigationController pushViewController:cmdVC animated:YES];
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"]] || [service.UUID isEqual:[CBUUID UUIDWithString:@"FE59"]]) {
        YPUpgradeViewController * viewController = [[YPUpgradeViewController alloc] init];
        viewController.bleManager = _bleManager;
        [self.navigationController pushViewController:viewController animated:YES];
        [_device writeFFValue:[SOCCommander commandForSetFuncionWith:0]];
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]] || [service.UUID isEqual:[CBUUID UUIDWithString:@"180F"]]) {
        CBCharacteristic * characteristic = [[service characteristics] objectAtIndex:indexPath.row];
        if (characteristic == nil) { NSLog(@"'无效参数不满足: characteristic != nil"); }
        [_device.peripheral readValueForCharacteristic:characteristic];
    }
}

@end
