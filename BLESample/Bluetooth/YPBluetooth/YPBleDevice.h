//
//  YPBleDevice.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "CBUUID+YPExtension.h"

@protocol YPDeviceDelete <NSObject>

@optional

@end

@interface YPBleDevice : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSDictionary * advertisementData;
@property (nonatomic, strong) NSNumber * RSSI;

// peripheral
@property (nonatomic) NSString *deviceName;
@property (nonatomic) NSString* identifier;

// advertisementData info
@property (nonatomic, readonly) NSString * localName;
@property (nonatomic, readonly) NSString * manufacturerData;
@property (nonatomic, readonly) NSString * specificData;

@property (nonatomic, strong) NSString * manufacturerName;
@property (nonatomic, strong) NSString * modelNumber;
@property (nonatomic, strong) NSString * serialNumber;
@property (nonatomic, strong) NSString * hardwareRevision;
@property (nonatomic, strong) NSString * firmwareRevision;

@property (nonatomic) void(^logger)(NSString * log);

// characteristic
@property (nonatomic, readonly) CBCharacteristic * TxCharacteristic;

- (instancetype)initWithDevice:(CBPeripheral*)device;

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID;

- (void)writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;

- (void)writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;

- (void)readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral;

- (void)writeFFValue:(NSString *)FFString;

@end
