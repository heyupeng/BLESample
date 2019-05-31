//
//  YPBleDevice.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BleAdvertisementData <NSObject>
@required
@property (nonatomic, strong) NSDictionary * advertisementData;

@optional
// advertisementData info
@property (nonatomic, readonly) NSString * localName;
@property (nonatomic, readonly) NSData * manufacturerData;
@property (nonatomic, readonly) NSData * companysData;
@property (nonatomic, readonly) NSData * specificData;
@property (nonatomic, readonly) NSData * mac; // In ManufacturerData
@end


// 设备广播发射频率记录
@protocol RSSIRecord <NSObject>
@optional
- (void)addRSSIRecord:(NSNumber *)rssi;
- (NSArray *)RSSIRecords;
@end

// Class - YPBleDevice
@interface YPBleDevice : NSObject <CBPeripheralDelegate, BleAdvertisementData, RSSIRecord>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSDictionary * advertisementData;
@property (nonatomic, strong) NSNumber * RSSI;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> * RSSIRecords;

// peripheral
@property (nonatomic) NSString *deviceName;
@property (nonatomic) NSString* identifier;

@property (nonatomic, strong) NSString * manufacturerName;
@property (nonatomic, strong) NSString * modelNumber;
@property (nonatomic, strong) NSString * serialNumber;
@property (nonatomic, strong) NSString * hardwareRevision;
@property (nonatomic, strong) NSString * firmwareRevision;

@property (nonatomic) void(^logger)(NSString * log);

// characteristic
@property (nonatomic, readonly) CBCharacteristic * TxCharacteristic;

- (instancetype)initWithDevice:(CBPeripheral*)device;

@end

@interface YPBleDevice (yp_BleOperation)

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID;

- (void)readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral;

- (void)writeValue:(NSData *)data forCharacteristicUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID peripheral:(CBPeripheral *)peripheral;

- (void)writeValueWithoutResponse:(NSData *)data forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral;

- (void)writeFFValue:(NSString *)FFString;

@end

@interface YPBleDevice (yp_BleOperation_depaecated_1_0)

- (void)writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data NS_DEPRECATED_IOS(4_0, 5_0, "Use instead");

- (void)writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data NS_DEPRECATED_IOS(4_0, 5_0, "Use instead");

@end
