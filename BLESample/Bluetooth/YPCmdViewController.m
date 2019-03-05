//
//  YPCmdViewController.m
//  YPDemo
//
//  Created by Peng on 2019/3/4.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import "YPCmdViewController.h"

#import "YPBlueManager.h"
#import "YPDeviceManager.h"

#import "CommunicationProtocol/SOCBlueToothWriteData.h"
#import "YPUpgradeViewController.h"

@interface YPTextCell : UICollectionViewCell

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation YPTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    _titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_titleLabel];
    return self;
}

@end

@interface YPCmdViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>
{
    BOOL personalMode;
}
@property (nonatomic, strong) UITextField * tf;
@property (nonatomic, strong) UIButton * btn;

@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * dataSource;

@property (nonatomic, strong) UITextView * tv;
@property (nonatomic, strong) CADisplayLink * displayLink;
@end

@implementation YPCmdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initialData];
    
    [self initUI];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addNotificationObserver];
    
    if (_blueManager.currentDevice.peripheral.state == CBPeripheralStateConnected) {
        return;
    }
    [_blueManager connectDevice:_deviceManager];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_blueManager disConnectDevice:_deviceManager];
    [self removeNotificationObserver];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_tf resignFirstResponder];
}

/** ============== **/
- (void)initialData {
    _dataSource = [NSMutableArray new];
    
    NSArray * cmds = @[@"Function set",
                    @"Request records",
                    @"Local time set",
                    @"Request DFU",
                    @"剩余电量",
                    @"设备信息",
                    @"渐强模式",
                    @"附加功能模式",
                    @"电机参数设置",
                    @"请求设备绑定",
                    @"定制模式",
                    @"获取did",
                    @"写入did",
                    @"NTAG刷牙次数",
                    @"设置拿起唤醒状态",
                    @"固件升级"];
    [_dataSource setArray:cmds];
    
    self.title = self.deviceManager.localName;
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1.0
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, 44)];
    [self.view addSubview:view];
    
    UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, SCREENWIDTH * 2/3.0, 44)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    [tf addTarget:self action:@selector(tfValueChange:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:tf];
    _tf = tf;
    _tf.delegate = self;
    _tf.returnKeyType = UIReturnKeyDone;
    _tf.keyboardType = UIKeyboardTypeASCIICapable;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(SCREENWIDTH - 110, 0, 100, 44);
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"写入数据" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    _btn = btn;
    
    // 2.0
    CGRect frame = CGRectMake(0, 44 + 64, SCREENWIDTH, SCREENHEIGHT * 0.45);
    int vol = 2;
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((CGRectGetWidth(frame) - 10)/vol, 44);
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    _collectionView = collectionView;
    
    [_collectionView registerClass:[YPTextCell class] forCellWithReuseIdentifier:@"cell"];
    
    UITextView * tv = [[UITextView alloc] init];
    tv.editable = NO;
    tv.frame = CGRectMake(0, CGRectGetMaxY(collectionView.frame) + 10, SCREENWIDTH, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(collectionView.frame) - 20 - 44);
    [self.view addSubview:tv];
    _tv = tv;
}


- (void)setUpDisplayLink {
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)invalidateDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.tv.text.length > 1) {
            self.tv.text = [self.tv.text stringByAppendingFormat:@"\n%@",append];
        } else {
            self.tv.text = append;
        }
        [self autoScroll];
    });
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
    if ([notification.name isEqualToString:YPDevice_DidDiscoverServices]) {
       
    }
    
    if ([notification.name isEqualToString:YPDevice_DidDiscoverCharacteristics]) {
       
    }
    
    if ([notification.name isEqualToString:YPDevice_DidUpdateValue]) {
        CBCharacteristic * characteristic = notification.object;
        NSString *valueString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        NSString * log = [NSString stringWithFormat:@"Value for %@: \n%@ ==> %@", [characteristic UUID], [characteristic value], valueString];

        [self textforTextViewByAppending:log];
    }
}

//
- (void)writeFFValue:(NSString *)value {
    NSString * log = [NSString stringWithFormat:@"\nWrite FFValue: %@", value];
    [self textforTextViewByAppending:log];
    
    [_deviceManager writeFFValue:value];
}

// mark - action
- (void)tfValueChange:(UITextField *)sender {
    
}

- (void)btnAction:(UIButton *)sender {
    [self writeFFValue:_tf.text];
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
    NSString * valueString1 = [[NSString alloc] initWithData:character.value encoding:NSASCIIStringEncoding];
    
    cell.textLabel.text = [NSString stringWithFormat:@"character: %@ (%@)",UUID, title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", valueString, [character value]];
    
    if ([UUID.UUIDString isEqualToString:@"2A19"]) {
        long value = [[NSString hexStringFromData:[character value]] hexStringToLongValue];
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
//    CBService * service = [_dataSource objectAtIndex:indexPath.section];
    
    //    YPUpgradeViewController * viewController = [[YPUpgradeViewController alloc] init];
    //    viewController.blueManager = _blueManager;
    //    viewController.title = @"固件升级";
    //    [self.navigationController pushViewController:viewController animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YPTextCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = [_dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * title = [_dataSource objectAtIndex:indexPath.row];
    
    NSString * cmd = @"";
    if ([title isEqualToString:@"Function set"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfSetFuncionWith:1];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"work time(120|150)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"tips time(30|38)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * worktime = [[alertC.textFields objectAtIndex:0] text];
            NSString * cmd = [SOCBlueToothWriteData getSendStringOfSetFuncionWith: [worktime isEqualToString:@"150"]];
            self.tf.text = cmd;
            
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if ([title isEqualToString:@"Request records"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfGetRequestRecords];
        
    }
    else if ([title isEqualToString:@"Local time set"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfSetLocalTime];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"work time(120|150)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"tips time(30|38)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * worktime = [[alertC.textFields objectAtIndex:0] text];
            NSString * cmd = [SOCBlueToothWriteData getSendStringOfSetFuncionWith: [worktime isEqualToString:@"150"]];
            self.tf.text = cmd;
            
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if ([title isEqualToString:@"Request DFU"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfDFURequest];
    }
    else if ([title isEqualToString:@"剩余电量"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfGetBattery];
    }
    else if ([title isEqualToString:@"设备信息"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfGetDeviceInfo];
    }
    else if ([title isEqualToString:@"渐强模式"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfSetfadeInWith:1];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"off/on(0|1)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            UInt8 mode = [[[alertC.textFields objectAtIndex:0] text] intValue];
            
            data = [NSString stringWithFormat:@"%.2x",mode];
            NSString * cmd = [SOCBlueToothWriteData getSendStringOfSetfadeInWith:mode];
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if ([title isEqualToString:@"附加功能模式"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfSetAddOnsWith:1];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"功能模式(0-3)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            UInt8 mode = [[[alertC.textFields objectAtIndex:0] text] intValue];
            
            data = [NSString stringWithFormat:@"%.2x",mode];
            NSString * cmd = [SOCBlueToothWriteData getSendStringOfSetAddOnsWith:mode];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if ([title isEqualToString:@"电机参数设置"]) {
        NSString * motor = @"";
        UInt32 rate = 100; // 100 - 400
        UInt8 duty = 50; // 1 - 99
        rate = (rate >> 8) |(rate << 8);
        motor = [@"11" stringByAppendingString:[NSString stringWithFormat:@"%.4x%.2x", rate, duty]];
        cmd = [SOCBlueToothWriteData getCmdOfMotorParameters:motor];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"档位：1Byte,高4bit(挡位)+低4bit(强弱)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"频率：100—400（Hz）";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"占空比：1-99（%）";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * motor = @"";
            
            NSString * gearStr = [[alertC.textFields objectAtIndex:0] text];
            UInt32 rate = [[[alertC.textFields objectAtIndex:1] text] intValue]; // 100 - 400
            UInt8 duty = [[[alertC.textFields objectAtIndex:2] text] intValue]; // 1 - 99
            rate = (rate >> 8) |(rate << 8);
            
            motor = [NSString stringWithFormat:@"%@%.4x%.2x",gearStr, rate, duty];
            NSString * cmd = [SOCBlueToothWriteData getCmdOfMotorParameters:motor];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
        
    }else if ([title isEqualToString:@"请求设备绑定"]) {
        cmd = [SOCBlueToothWriteData getSendStringOfBind];
        
    }
    else if ([title isEqualToString:@"定制模式"]) {
        UInt32 rate = 100; // 100 - 400
        UInt8 duty = 50; // 1 - 99
        rate = (rate >> 8) |(rate << 8);
        NSString * mode = [NSString stringWithFormat:@"%.4x%.2x", rate, duty];
        personalMode = !personalMode;
        cmd = [SOCBlueToothWriteData getCmdOfSetPersonalMode:personalMode mode:mode];
    }
    else if ([title isEqualToString:@"获取did"]) {
        cmd = [SOCBlueToothWriteData getCmdOfGetDid];
    }
    else if ([title isEqualToString:@"写入did"]) {
        cmd = [SOCBlueToothWriteData getCmdOfSetDid:@""];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"12Bytes";
            textField.keyboardType = UIKeyboardTypeASCIICapable;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            NSString * did = [[alertC.textFields objectAtIndex:0] text];
            data = did;
            
            NSString * cmd = [SOCBlueToothWriteData getCmdOfSetDid:data];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        
    }
    else if ([title isEqualToString:@"NTAG刷牙次数"]) {
        cmd = [SOCBlueToothWriteData getCmdOfGetCountInNTAG];
    }
    else if ([title isEqualToString:@"设置拿起唤醒状态"]) {
        cmd = [SOCBlueToothWriteData getCmdOfSetFlashState:@"01"];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"off/on(0|1)";
            textField.keyboardType = UIKeyboardTypeASCIICapable;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            UInt8 state = [[[alertC.textFields objectAtIndex:0] text] intValue];
            data = [NSString stringWithFormat:@"%.2x", state];
            
            NSString * cmd = [SOCBlueToothWriteData getCmdOfSetFlashState:data];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if ([title isEqualToString:@"固件升级"]) {
        YPUpgradeViewController * vc = [[YPUpgradeViewController alloc] init];
        vc.blueManager = _blueManager;
        
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    _tf.text = cmd;
}

#pragma mark -tf
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
