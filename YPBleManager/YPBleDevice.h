//
//  YPBleDevice.h
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol AdvertisementDataExtendMethods <NSObject>
@required
@property (nonatomic, strong) NSDictionary * advertisementData;

@optional
// advertisementData info
@property (nonatomic, readonly, getter=isConnectable) BOOL connectable;
@property (nonatomic, readonly) NSString * localName;
@property (nonatomic, readonly) NSData * manufacturerData;
@property (nonatomic, readonly) NSDictionary * serviceData;

// Data in manufacturerData
@property (nonatomic, readonly) NSData * companysData;
@property (nonatomic, readonly) NSData * specificData;
@property (nonatomic, readonly) NSData * mac; // In ManufacturerData

// Data in serviceData
@property (nonatomic, readonly) NSData * macReverseInServiceForFE95; // In Service For FE95

@end

@interface AdvertisementDataHelper : NSObject <AdvertisementDataExtendMethods>

@property (nonatomic, strong) NSDictionary * advertisementData;

- (instancetype)initWithAdvertisementData:(NSDictionary *)advertisementData;

@end

// 设备广播发射频率记录
@protocol RSSIRecord <NSObject>
@optional
- (void)addRSSIRecord:(NSNumber *)rssi;
- (NSArray *)RSSIRecords;
@end

// Class - YPBleDevice
@interface YPBleDevice : NSObject <CBPeripheralDelegate, AdvertisementDataExtendMethods, RSSIRecord>

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

- (void)readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID;

- (void)writeValue:(NSData *)data forCharacteristicUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID;

- (void)writeValueWithoutResponse:(NSData *)data forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID;

/// Write hex string Value to a characteristic that is NordicUARTTxCharacteristic
/// @method writeFFValue
/// @param FFString The hex string value to write.
/// @return Bool
/// @discussion Writes <i>hex string value</i> to <i>NordicUARTTxCharacteristicUUIDString</i>'s characteristic value.
///             the <code>CBCharacteristicWriteWithResponse</code> type is specified.
- (BOOL)writeFFValue:(NSString *)FFString;

- (void)writeFFValue:(NSString *)FFString completion:(void(^)(BOOL success))completion;

@end
