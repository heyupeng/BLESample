//
//  DFUManager.m
//  Test1
//
//  Created by xiehaiyan on 2017/3/21.
//  Copyright © 2017年 soocare. All rights reserved.
//

#import "DFUManager.h"
#import "DFUHelper.h"
#import "DFUOperations.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface DFUManager ()<CBCentralManagerDelegate, DFUOperationsDelegate>
{
    CBCentralManager *_centralManager;
    CBPeripheral *_peripheral;
    
    DFUOperations *_dfuOperation;
    DFUHelper *_dfuHelper;
    
    BOOL _startUpload;
    NSInteger _readDFUVersion;
}
@end

@implementation DFUManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _dfuOperation = [[DFUOperations alloc] initWithDelegate:self];
        _dfuHelper = [[DFUHelper alloc] initWithData:_dfuOperation];
    }
    return self;
}

- (void)startDfu {
    _startUpload = NO;
    _readDFUVersion = 0;
    
//    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)stopScanDevice {
    if (_centralManager) {
        [_centralManager stopScan];
    }
}

- (void)stopConnectDevice
{
    if (_centralManager && _peripheral) {
        [_centralManager cancelPeripheralConnection:_peripheral];
    }
}

- (void)connectDevice:(CBPeripheral *)peripheral {
    [_dfuOperation connectDevice:peripheral];
}

- (void)setCentralManager:(CBCentralManager *)centralManager {
    [_dfuOperation setCentralManager:centralManager];
}

- (void)setfilePath: (NSString *)filePath {
    if (!filePath) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];

    _dfuHelper.isSelectedFileZipped = YES;
    _dfuHelper.isManifestExist = YES;
    [_dfuHelper setFirmwareType:FIRMWARE_TYPE_APPLICATION];
    _dfuHelper.selectedFileURL = url;
    [_dfuHelper unzipFiles:url];
}

- (void)setFirmwareFilePath:(NSString *)firmwareFilePath {
    if ([_firmwareFilePath isEqualToString:firmwareFilePath]) {
        return;
    }
    _firmwareFilePath = firmwareFilePath;
    [self setfilePath:_firmwareFilePath];
}

- (void)initAndStartDfu
{
    [self setfilePath:self.firmwareFilePath];
    
    [self setCentralManager:_centralManager];
    [_dfuOperation connectDevice:_peripheral];
}

- (void)postNotificationWithBluetoothDidUpdateState:(BOOL) blueIsOpen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationWithBluetoothStateChanged object:[NSNumber numberWithBool:blueIsOpen]];
}

- (void)postNotificationWithDfuState:(DfuState) dfuState {
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationWithDfuStateChanged object:[NSNumber numberWithInteger:dfuState]];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStatePoweredOff:
            [self postNotificationWithBluetoothDidUpdateState:NO];
            break;
        case CBManagerStatePoweredOn:{
            [self postNotificationWithBluetoothDidUpdateState:YES];
            [self postNotificationWithDfuState:DfuStateSearching];
            [_centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
        }
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    // NSLog(@"%@", advertisementData);
    
    NSString *deviceName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    if (!deviceName || ![deviceName hasPrefix:self.deviceNamePrefix]) {
        return;
    }
    
    NSData *data;
    NSString *macStr;
    NSArray *keys = [advertisementData allKeys];
    if ([keys containsObject:@"kCBAdvDataManufacturerData"]) {
        data = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
        macStr = [self getDeviceMacByAdvDataManufacturerData: data];
    }else if([keys containsObject:@"kCBAdvDataServiceData"]) {
        data = [[advertisementData objectForKey:@"kCBAdvDataServiceData"] objectForKey:[CBUUID UUIDWithString:@"FE95"]];
        macStr = [self getDeviceMacByAdvDataServiceData:data];
    }else{
        return;
    }
    
    macStr = macStr.uppercaseString;
    self.deviceMac = self.deviceMac.uppercaseString;
    if ([macStr isEqualToString:self.deviceMac]) {
        [_centralManager stopScan];
        _peripheral = peripheral;
        [self initAndStartDfu];
        [self postNotificationWithDfuState:DfuStateConnecting];
    }
}

#pragma mark - DFUOperationsDelegate
-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    if (!_startUpload) {
        [_dfuOperation connectDevice: peripheral];
    }else{
        [self postNotificationWithDfuState:DfuStateComplete];
    }
}

-(void)onReadDFUVersion:(int)version
{
    _readDFUVersion++;
    if (_readDFUVersion > 2) {
        return;
    }
    _dfuHelper.isDfuVersionExist = _dfuOperation.dfuVersionCharacteristic? 1: 0;
    [_dfuOperation setAppToBootloaderMode];
    if ([_dfuHelper isValidFileSelected]) {
        [_dfuHelper checkAndPerformDFU];
    }
}

-(void)onDFUStarted
{
    _startUpload = YES;
    [self postNotificationWithDfuState:DfuStateStartUpload];
    [self postNotificationWithDfuState:DfuStateUploading];
}

-(void)onTransferPercentage:(int)percentage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationWithDfuProgressChanged object:[NSNumber numberWithInteger:percentage]];
}

-(void)onError:(NSString *)errorMessage
{
    [self postNotificationWithDfuState:DfuStateError];
}

-(void)onDeviceConnected:(CBPeripheral *)peripheral {
//    [_dfuOperation setAppToBootloaderMode];
//    _dfuHelper.isDfuVersionExist = _dfuOperation.dfuVersionCharacteristic? 1: 0;
//    if ([_dfuHelper isValidFileSelected]) {
//        [_dfuHelper checkAndPerformDFU];
//    }
}
-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral {}
-(void)onDFUCancelled {}
-(void)onSoftDeviceUploadStarted {}
-(void)onBootloaderUploadStarted {}
-(void)onSoftDeviceUploadCompleted {}
-(void)onBootloaderUploadCompleted {}
-(void)onSuccessfulFileTranferred {}

#pragma mark - 帮助类
- (NSString *)getDeviceMacByAdvDataManufacturerData: (NSData *) data {
    NSString *hexStr = [self dataToHex:data];
    NSString *macStr = [[hexStr substringWithRange:NSMakeRange(hexStr.length - 12, 12)] uppercaseString];
    NSMutableString *mutableStr = [NSMutableString string];
    for (NSInteger i = 0; i < macStr.length; i++) {
        if (i % 2 == 0) {
            NSString *subStr = [macStr substringWithRange:NSMakeRange(i, 2)];
            [mutableStr appendFormat:@"%@:", subStr];
        }
    }
    return [mutableStr substringWithRange:NSMakeRange(0, mutableStr.length - 1)];
}

- (NSString *)getDeviceMacByAdvDataServiceData: (NSData *) data {
    NSString *hexStr = [self dataToHex:data];
    NSString *macStr = [[hexStr substringWithRange:NSMakeRange(hexStr.length - 14, 12)] uppercaseString];
    NSMutableString *mutableStr = [NSMutableString string];
    for (NSInteger i = macStr.length - 1; i >= 0; i--) {
        if (i % 2 == 0) {
            NSString *subStr = [macStr substringWithRange:NSMakeRange(i, 2)];
            [mutableStr appendFormat:@"%@:", subStr];
        }
    }
    return [mutableStr substringWithRange:NSMakeRange(0, mutableStr.length - 1)];;
}

- (NSString *)dataToHex:(NSData *) data {
    Byte *bytes = (Byte *)[data bytes];
    NSMutableString *str = [NSMutableString stringWithCapacity:data.length * 2];
    for (int i = 0; i < data.length; i++) {
        NSString *hex = [NSString stringWithFormat:@"00%0x", bytes[i]];
        hex = [hex substringWithRange:NSMakeRange(hex.length - 2, 2)];
        [str appendString:hex];
    }
    return str;
}

@end
