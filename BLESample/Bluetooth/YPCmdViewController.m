//
//  YPCmdViewController.m
//  YPDemo
//
//  Created by Peng on 2019/3/4.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import "YPCmdViewController.h"

#import "YPBleMacro.h"

#import "CommunicationProtocol/SOCCommander.h"
#import "CommunicationProtocol/CMDType.h"

#import "YPUpgradeViewController.h"

@interface YPCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation YPCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

- (UILabel *)titleLabel {
    if (_titleLabel) {
        return _titleLabel;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:_titleLabel];
    _titleLabel.frame = self.bounds;
    
    return _titleLabel;
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

@property (nonatomic, strong) NSData * fileData;
@property (nonatomic) double progress;
@property (nonatomic) int step;

@property (nonatomic) SOCCommander * commander;
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
    
    __weak YPCmdViewController* weakSelf = self;
    [_device setLogger:^(NSString *log) {
        [weakSelf textforTextViewByAppending:log];
    }];
    
    if (_bleManager.currentDevice.peripheral.state == CBPeripheralStateConnected) {
        [_device setNotifyVuale:YES forCharacteristicUUID:[CBUUID UUIDWithString:NordicUARTRxCharacteristicUUIDString] serviceUUID:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]];
        return;
    }
    [_bleManager connectDevice:_device];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeNotificationObserver];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_tf resignFirstResponder];
}

/** ============== **/
- (void)initialData {
    _dataSource = [NSMutableArray new];
    
    SOCDeviceType type = SOCDeivceTypeCreateWithLocalName(self.device.localName);
    SOCCommander * commander = [SOCCommander commanderWithType:type];
    _commander = commander;
    
    NSArray * cmds = @[];
    NSArray * events = @[@{@"event": @"固件升级"}];
    if (_commander.deviceType == SOCDeviceMC1) {
        events = [@[@{@"event": @"Write Music File"}] arrayByAddingObjectsFromArray:events];
    }
    cmds = [[commander supportCommands] arrayByAddingObjectsFromArray:events];
    [_dataSource setArray:cmds];
    
    self.title = self.device.localName;
}

- (void)initUI {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1.0
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREENWIDTH, 44 * 2 + 5 * 1)];
    [self.view addSubview:view];
    
    UITextField * tf = [[UITextField alloc] initWithFrame:CGRectMake(1/5.0 *0.5 * SCREENWIDTH, 0, SCREENWIDTH * 4/5.0, 44)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    [tf addTarget:self action:@selector(tfValueChange:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:tf];
    _tf = tf;
    _tf.delegate = self;
    _tf.returnKeyType = UIReturnKeyDone;
    _tf.keyboardType = UIKeyboardTypeASCIICapable;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(1/5.0 *0.5 * SCREENWIDTH, CGRectGetMaxY(tf.frame) + 5, SCREENWIDTH * 4/5.0, 44);
    btn.backgroundColor = [UIColor colorWithRed:0x3d/255.0 green:0xB9/255.0 blue:0xBF/255.0 alpha:1];
    [btn setTitle:@"写入数据" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    _btn = btn;
    
    // 2.0
    CGRect frame = CGRectMake(0, CGRectGetMaxY(view.frame) + 10, SCREENWIDTH, CGRectGetHeight(self.view.frame) - CGRectGetMaxY(view.frame) - 5 - 120);
    
    int volumn = 3;
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((CGRectGetWidth(frame) - 10 * (volumn - 1) - 10)/volumn, 44);
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (@available(iOS 13.0, *)) {
        collectionView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    }
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self.view addSubview:collectionView];
    _collectionView = collectionView;

    [_collectionView registerClass:[YPCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    UIBarButtonItem * rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Log" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonAction:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    UITextView * tv = [[UITextView alloc] init];
    tv.editable = NO;
    tv.hidden = YES;
    tv.frame = self.view.bounds;
//    tv.frame = CGRectMake(0, CGRectGetMaxY(collectionView.frame) + 10, SCREENWIDTH, CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(collectionView.frame) - 20 - 44);
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
        [[YPLogger share] appendLog:append];
        [self autoScroll];
    });
}

- (void)rightButtonAction:(UIBarButtonItem *)sender {
    _tv.frame = self.view.bounds;
    _tv.hidden = !_tv.hidden;
}

/** ============== **/
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutBleManager:) name:YPBLEManager_DidConnectDevice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidDiscoverServices object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidDiscoverCharacteristics object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidUpdateValue object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAboutdevice:) name: YPBLEDevice_DidWriteValue object:nil];
}

- (void)removeNotificationObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)notificationAboutBleManager: (NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([notification.name isEqualToString:YPBLEManager_DidConnectDevice]) {
            [self.device.peripheral discoverServices:nil];
        }
        
    });
}

- (void)notificationAboutdevice: (NSNotification *)notification {
    if ([notification.name isEqualToString:YPBLEDevice_DidDiscoverServices]) {
       
    }
    
    if ([notification.name isEqualToString:YPBLEDevice_DidDiscoverCharacteristics]) {
       
    }
    
    if ([notification.name isEqualToString:YPBLEDevice_DidUpdateValue]) {
        [self didUpdateValueForCharacteristic:notification];
    }
    
    if ([notification.name isEqualToString:YPBLEDevice_DidWriteValue]) {
        CBCharacteristic * characteristic = notification.object;
        NSString *valueString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        
        NSString * log = [NSString stringWithFormat:@"%@ Did Write Value %@ ==> %@", [characteristic UUID], [characteristic value], valueString];
//        [self textforTextViewByAppending:log];
    }
}

//
- (void)writeFFValue:(NSString *)value {
    if (value.length == 0) return;
    
    NSString * log = [NSString stringWithFormat:@"\nWrite HexValue: %@", value];
    [self textforTextViewByAppending:log];
    
    [_device writeFFValue:value];
}

// mark - action
- (void)tfValueChange:(UITextField *)sender {
    
}

- (void)btnAction:(UIButton *)sender {
    [self writeFFValue:_tf.text];
}

- (void)updateProgress:(double)progress {
    if (fabs(floor(progress * 1000) - floor(_progress * 1000)) < 10) {
        return;
    }
    _progress = progress;
    NSLog(@"Progress: %.3f", _progress);
    [self textforTextViewByAppending:[NSString stringWithFormat:@"Progress: %.2f", _progress]];
}

int byteStart = 0;

- (void)didUpdateValueForCharacteristic:(NSNotification *)notification {
    CBCharacteristic * characteristic = notification.object;
    NSString *valueString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSData * value = characteristic.value;
    Byte * bytes = (Byte*)value.bytes;
    NSInteger type = value.length > 1? bytes[0]: 0x00;
    NSData * data = nil;
    if (value.length > 8) {
        data = [value subdataWithRange:NSMakeRange(8, value.length - 8)];
    }
    
    NSString * log = [NSString stringWithFormat:@"did Update Value: \n\t UUID %@ \n\t Value %@ -> %@", [characteristic UUID], [characteristic value], valueString];
    NSLog(@"%@", log);
    if ( !(type == CMD_Empty ||
           (_commander.deviceType == SOCDeviceMC1 &&
            (type == CMD_MC1_FileTransferStart ||
             type == CMD_MC1_FileTransferControl ||
             type == CMD_MC1_FileTransferEnd)
            )
           )
        ) {
        [self textforTextViewByAppending:log];
    }
    
    [self didUpdateValueResultType:type];
}

- (void)didUpdateValueResultType:(CMDType)resultType {
    if (_commander.deviceType != SOCDeviceMC1) {
        return;
    }
    
    if (resultType == CMD_MC1_FileTransferStart) {
        NSLog(@"文件传输开始");
        byteStart = 0;
        
        // 设备内部每接受1024B处理一次，文件段不足1024B需补充至1024B，否则设备内部不会处理
        NSInteger dataLength = _fileData.length;
        int mod = dataLength % 1024;
        int size = (int)(dataLength / 1024);
        if (mod != 0) {
            size += 1;
            NSMutableData * appendData = [[NSMutableData alloc] initWithCapacity:1024];
            [appendData appendData:_fileData];
            for (int i = 0; i < 1024 - mod; i ++) {
                int c = 0;
                [appendData appendBytes:&c length:sizeof(char)];
            }
            _fileData = appendData;
        }
        
        _step = 2;
        [self writeFileValue];
    } else if (resultType == CMD_MC1_FileTransferControl) {
        if (_step == 2) {
            [self writeFileValue];
        } else if (_step == 3){
            [self writeFileEnd];
        }
        
    } else if (resultType == CMD_MC1_FileTransferEnd) {
        NSLog(@"文件传输结束");
    }
}

- (void)writeFileSize:(UInt32)size type:(UInt8)type {
    _step = 1;
    // 0e00 0500 0000 f632 000e a900 0b
    
//    NSString * append = [NSString stringWithFormat:@"%.2x%.8x", type, length];
//    append = [append hexStringReverse];
    
    NSString * append = [NSString stringWithFormat:@"%.8x%.2x", size, type];
    
    NSString * command = [SOCCommander commandWithType:@"000e" length:@"0005" appendData:append];
//    command = [NSString stringWithFormat:@"0e00 0500 0000 f632 %@", append];
    
    [_device writeFFValue:command];
}

- (void)writeFileValue {
    int blockSize = 128;
    
    NSInteger dataLength = _fileData.length;
    int mod = dataLength % 1024;
    int size = (int)(dataLength / 1024);
    if (mod != 0) {
        size += 1;
    }
    
    NSInteger byteLength = MIN(1024, _fileData.length - byteStart);
//    NSData * byteData = [_fileData subdataWithRange:NSMakeRange(byteStart, byteLength)];
//    if (byteLength != 1024) {
//        NSMutableData * appendData = [[NSMutableData alloc] initWithCapacity:1024];
//        [appendData appendData:byteData];
//        for (int i = 0; i < 1024 - byteLength; i ++) {
//            int c = 0;
//            [appendData appendBytes:&c length:sizeof(char)];
//        }
//        byteData = appendData;
//    }
    
    int blockStart = 0;
    
    while (blockStart < byteLength) {
        if (byteLength - blockStart < blockSize) {
            blockSize = (int)byteLength - blockStart;
        }
//                NSLog(@"%d to %d (%d/%d) of %d", byteStart + blockStart, byteStart + blockStart + blockSize, blockStart + blockSize, (int)byteLength, (int)dataLength);
        double progress = (double)(byteStart + blockStart + blockSize) / (double)dataLength;
        [self updateProgress:progress];
        
        NSData * blockData = [_fileData subdataWithRange:NSMakeRange(byteStart + blockStart, blockSize)];
        blockStart += blockSize;
        
//        blockData = [byteData subdataWithRange:NSMakeRange(blockStart, blockSize)];
        
        [_device writeValueWithoutResponse:blockData forCharacteristicUUID:[CBUUID UUIDWithString:Private_Service_Tx_Characteristic_UUID] serviceUUID:[CBUUID UUIDWithString:Private_Service_UUID]];
    }
    
    byteStart += byteLength;
    
    if (byteStart == dataLength) {
        _step = 3;
    }
}

- (void)writeFileEnd {
    NSString * command = [SOCCommander commandWithType:@"000f" length:@"0000" appendData:@""];
    [_device writeFFValue:command];
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
        long value = [[character value].hexString yp_hexStringToLongValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld %% %@", value, [character value]];
        [CBUUID UUIDWithUInt16:0x2a19];
        [UUID UInt16Value];
        
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
    //    viewController.bleManager = _bleManager;
    //    viewController.title = @"固件升级";
    //    [self.navigationController pushViewController:viewController animated:YES];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    YPCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor whiteColor];
    id item = [_dataSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = [item objectForKey:@"event"]? :[item objectForKey:@"cmd"];
    
    cell.contentView.layer.borderWidth = 0.5;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id item = [_dataSource objectAtIndex:indexPath.row];
    CMDType type = [[item objectForKey:@"value"] intValue];
    NSString * title = [item objectForKey:@"event"];
    
    NSString * cmd = @"";
    if (type == CMD_FunctionSet) {
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
            
            NSString * cmd = [SOCCommander commandForSetFuncionWith: [worktime isEqualToString:@"150"]];
            self.tf.text = cmd;
            
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if (type == CMD_RequestRecords) {
        cmd = [SOCCommander commandForGetRequestRecords];
        
    }
    else if (type == CMD_LocaltimeSet) {
        cmd = [SOCCommander commandForSetLocalTime];
        
    }
    else if (type == CMD_RequestDFU) {
        cmd = [SOCCommander commandForDFURequest];
    }
    else if (type == CMD_Battery) {
        cmd = [SOCCommander commandForGetBattery];
    }
    else if (type == CMD_DeviceInfo) {
        cmd = [SOCCommander commandForGetDeviceInfo];
    }
    else if (type == CMD_ModeSetFadeIn) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"off/on(0|1)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            UInt8 mode = [[[alertC.textFields objectAtIndex:0] text] intValue];
            
            data = [NSString stringWithFormat:@"%.2x",mode];
            NSString * cmd = [SOCCommander commandForSetfadeInWith:mode];
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if (type == CMD_ModeSetAddOn) {
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"功能模式(0-3)";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            UInt8 mode = [[[alertC.textFields objectAtIndex:0] text] intValue];
            
            data = [NSString stringWithFormat:@"%.2x",mode];
            NSString * cmd = [SOCCommander commandForSetAddOnsWith:mode];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if (type == CMD_MotorParametersSet) {
        NSString * motor = @"";
        UInt32 rate = 100; // 100 - 400
        UInt8 duty = 50; // 1 - 99
        rate = (rate >> 8) |(rate << 8);
        motor = [@"11" stringByAppendingString:[NSString stringWithFormat:@"%.4x%.2x", rate, duty]];
        cmd = [SOCCommander commandForMotorParameters:motor];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"档位：1Byte,高(挡位)+低(强弱)";
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
            rate = (rate >> 8) |((rate & 0xff) << 8);
            
            motor = [NSString stringWithFormat:@"%@%.4x%.2x",gearStr, rate, duty];
            NSString * cmd = [SOCCommander commandForMotorParameters:motor];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
        
    }else if (type == CMD_RequestResponse) {
        cmd = [SOCCommander commandForBind];
        
    }
    else if (type == CMD_ModeSet) {
        UInt32 rate = 100; // 100 - 400
        UInt8 duty = 50; // 1 - 99
        rate = (rate >> 8) |(rate << 8);
        NSString * mode = [NSString stringWithFormat:@"%.4x%.2x", rate, duty];
        personalMode = !personalMode;
        cmd = [SOCCommander commandForSetPersonalMode:personalMode mode:mode];
    }
    else if (type == CMD_DeviceIDGet) {
        cmd = [SOCCommander commandForGetDid];
    }
    else if (type == CMD_DeviceIDSet) {
        cmd = [SOCCommander commandForSetDid:@""];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"12Bytes";
            textField.keyboardType = UIKeyboardTypeASCIICapable;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            NSString * did = [[alertC.textFields objectAtIndex:0] text];
            data = did;
            
            NSString * cmd = [SOCCommander commandForSetDid:data];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        
    }
    
    else if (type == CMD_X5_NTAGGet && _commander.deviceType == SOCDeviceX5) {
        cmd = [SOCCommander commandForGetCountInNTAG];
    }
    else if (type == CMD_X5_FlashSet && _commander.deviceType == SOCDeviceX5) {
        cmd = [SOCCommander commandForSetFlashState:@"01"];
        
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"off/on(0|1)";
            textField.keyboardType = UIKeyboardTypeASCIICapable;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * data = @"";
            
            UInt8 state = [[[alertC.textFields objectAtIndex:0] text] intValue];
            data = [NSString stringWithFormat:@"%.2x", state];
            
            NSString * cmd = [SOCCommander commandForSetFlashState:data];;
            self.tf.text = cmd;
        }]];
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    }
    else if ((type == CMD_X5_RequestDFUCRC && _commander.deviceType == SOCDeviceX5) ||
             (type == CMD_M1_RequestDFUCRC && _commander.deviceType == SOCDeviceM1) ||
             (type == CMD_MC1_RequestDFUCRC && _commander.deviceType == SOCDeviceMC1)
             ) {
        UIAlertController * alertC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = @"0x85150616";
            textField.placeholder = @"0x85150616";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * text = [[alertC.textFields objectAtIndex:0] text];
            if ([text hasPrefix:@"0x"]) {
                text = [text substringFromIndex:2];
            }
            NSString * cmd = [self.commander commandForDFURequestCRC: text];
            self.tf.text = cmd;
        }]];
        
        [alertC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alertC animated:YES completion:nil];
        return;
    } else if ([title isEqualToString:@"Music File"]) {
        NSString * filePath = [[NSBundle mainBundle] pathForResource:@"5" ofType:@"mp3"];
        [self fileTransferStartWithFile:filePath];
        
    }
    else if ([title isEqualToString:@"固件升级"]) {
        YPUpgradeViewController * vc = [[YPUpgradeViewController alloc] init];
        vc.bleManager = _bleManager;
        
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    _tf.text = cmd;
}

- (void)fileTransferStartWithFile:(NSString *)filePath {
    NSData * fileData = [NSData dataWithContentsOfFile:filePath];
    NSInteger length = fileData.length;
    NSInteger type = 0;
    if (length > 0 && length <= PRIVATE_FILE_TYPE_Length1) {
        type = 1;
    } else if (length > PRIVATE_FILE_TYPE_Length1 && length <= PRIVATE_FILE_TYPE_Length2) {
        type = 11;
    }
    
    if (type == 0) {
        NSLog(@"文件不合法");
        return;
    }
    _fileData = fileData;
    
    [self writeFileSize:(UInt32)length type:type];
}


#pragma mark -tf
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
