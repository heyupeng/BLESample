//
//  YPDeviceManager.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "YPBLEMacro.h"

@interface YPDeviceManager : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSDictionary * advertisementData;
@property (nonatomic, strong) NSNumber * RSSI;

// peripheral
@property (nonatomic) NSString *deviceName;
@property (nonatomic) NSString* identifier;

// advertisementData
@property (nonatomic, readonly) NSString * localName;
@property (nonatomic, readonly) NSString * manufacturerData;

@property (nonatomic, strong) NSString * manufacturerName;
@property (nonatomic, strong) NSString * modelNumber;
@property (nonatomic, strong) NSString * serialNumber;
@property (nonatomic, strong) NSString * hardwareRevision;
@property (nonatomic, strong) NSString * firmwareRevision;

- (instancetype)initWithDevice:(CBPeripheral*)device;

- (void)notification:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on;

- (void)writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;
- (void)writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data;

- (void)readValue: (CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p;

- (void)writeFFValue:(NSString *)FFString;

/*UUIDToString*/
- (const char *) CBUUIDToString:(CBUUID *) UUID;
- (const char *) UUIDToString:(CFUUIDRef)UUID;
- (int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
- (int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2;
- (UInt16) CBUUIDToInt:(CBUUID *) UUID;
- (CBUUID *) IntToCBUUID:(UInt16)UUID;

@end
