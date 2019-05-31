//
//  YPBleDevice.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPBleDevice.h"

#import "YPBlueConst.h"

#import "CBPeripheral+YPExtension.h"
#import "CBUUID+YPExtension.h"

@implementation YPBleDevice

- (instancetype)initWithDevice:(CBPeripheral*)peripheral {
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
    }
    return self;
}

- (instancetype)initWithDevice:(CBPeripheral*)peripheral RSSI:(NSNumber *)RSSI  advertisementData:(NSDictionary *)advertisementData {
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        _RSSI = RSSI;
        _advertisementData = advertisementData;
    }
    return self;
}

- (void)setPeripheral:(CBPeripheral *)peripheral {
    if ([_peripheral isEqual:peripheral] && [_peripheral.delegate isEqual:self]) {
        return;
    }
    _peripheral = peripheral;
    _peripheral.delegate = self;
}

- (NSString *)deviceName {
    return _peripheral.name;
}

- (NSString *)identifier {
    return _peripheral.identifier.UUIDString;
}

- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

#pragma mark - peripheral delegate

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *s in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:s];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEDevice_DidDiscoverServices object:peripheral.services];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self logWithFormat:@"Service UUID: %@", service.UUID];
    
    NSArray *characteristics = [service characteristics];
    for (CBCharacteristic *characteristic in characteristics) {
        [self logWithFormat:@"\tCharacteristic UUID: %@", [characteristic UUID]];
        
        /*  x3 某一个版本的设备 readValueForCharacteristic: 后, UARTService Tx 无法 writeValue()
         (Error Domain=CBErrorDomain Code=8 "The specified UUID is not allowed for this operation.")
         */
        if (characteristic.properties & CBCharacteristicPropertyRead) {
//            [peripheral readValueForCharacteristic:characteristic];
        }
        
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]]) {
//            if ([[characteristic.UUID description] isEqualToString:NordicUARTRxCharacteristicUUIDString]) {
//                /*
//                 _RxCharacteristic = characteristic;
//                 */
//                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            }
//            if ([[characteristic.UUID description] isEqualToString:NordicUARTTxCharacteristicUUIDString]) {
//                /*
//                _TxCharacteristic = characteristic;
//                 */
//            }
//        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEDevice_DidDiscoverCharacteristics object:service];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *valueString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//    [self logWithFormat:@"did Update Value: \n\t UUID %@ \n\t Value %@ -> %@", [characteristic UUID], [characteristic value], valueString];
    if (error) {
        [self logWithFormat:@"error: %@", error.localizedDescription];
    }
    
    char * b1 = (char *)[characteristic.UUID.data bytes];
    UInt16 v = (b1[0] << 8) | b1[1];
    
    if (v == 0x2A29) {
        _manufacturerName = valueString;
    } else if (v == 0x2A24) {
        _modelNumber = valueString;
    } else if (v == 0x2A25) {
        _serialNumber = valueString;
    } else if (v == 0x2A27) {
        _hardwareRevision = valueString;
    } else if (v == 0x2A26) {
        _firmwareRevision = valueString;
    } else if (v == 0x2A19) {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEDevice_DidUpdateValue object:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self logWithFormat:@"did Write Value: \n\t UUID %@ \n\t Value %@", [characteristic UUID], [characteristic value]];
    if (error) {
        [self logWithFormat:@"error: %@", error.localizedDescription];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPBLEDevice_DidWriteValue object:characteristic];
}

#pragma mark - func
- (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2){
    va_list args;
    va_start(args, format);
    NSString * string = [[NSString alloc]initWithFormat:format arguments:args];
    va_end(args);
    
    if (_logger) {
        _logger(string);
    } else {
        NSLog(@"%@", string);
        [[YPLogger share] appendLog:string];
    }
}

@end

@implementation YPBleDevice (yp_BleOperation)

- (void)writeValue:(NSData *)data forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral type:(CBCharacteristicWriteType)type {
    CBCharacteristic *characteristic = [peripheral yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    if (!data) {
        NSLog(@"======= data is nil =======");
    }
    [peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeValue:(NSData *)data forCharacteristicUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID peripheral:(CBPeripheral *)peripheral {
    [self writeValue:data forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:peripheral type:CBCharacteristicWriteWithResponse];
}

- (void)writeValueWithoutResponse:(NSData *)data forCharacteristicUUID:(CBUUID *)characteristicUUID serviceUUID:(CBUUID *)serviceUUID peripheral:(CBPeripheral *)peripheral {
    [self writeValue:data forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:peripheral type:CBCharacteristicWriteWithoutResponse];
}

- (void)writeFFValue:(NSString *)FFString {
    NSData * data = [NSData dataWithHexString:FFString];
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:NordicUARTTxCharacteristicUUIDString];
    CBUUID * serviceUUID = [CBUUID UUIDWithString:NordicUARTServiceUUIDString];
    
    [self writeValue:data forCharacteristicUUID:characteristicUUID serviceUUID: serviceUUID peripheral:_peripheral type:CBCharacteristicWriteWithResponse];
}


- (void)readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral {
    CBCharacteristic *characteristic = [peripheral yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    NSLog(@"characteristic with UUID %s on service with UUID %s\n", [characteristicUUID UUIDToString], [serviceUUID UUIDToString]);
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral {
    CBCharacteristic *characteristic = [peripheral yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    
    [peripheral setNotifyValue:value forCharacteristic:characteristic];
}

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID {
    CBPeripheral * peripheral = self.peripheral;
    [self setNotifyVuale:value forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:peripheral];
}

@end

@implementation YPBleDevice(BleAdvertisementData)
- (NSString *)localName {
    NSString * localName = @"No Name";
    if (!self.advertisementData || ![[self.advertisementData allKeys] containsObject:CBAdvertisementDataLocalNameKey]) {
        return localName;
    }
    
    localName = [self.advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    return localName;
}

- (NSData *)manufacturerData {
    if (!self.advertisementData) {
        return nil;
    }
    if (![[self.advertisementData allKeys] containsObject:CBAdvertisementDataManufacturerDataKey]) {
        return nil;
    }
    
    NSData * data = [self.advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    return data;
}

- (NSData *)companysData {
    if (!self.manufacturerData) {
        return nil;
    }
    if (self.manufacturerData.length < 2) {
        return [self.manufacturerData mutableCopy];
    }
    
    NSData * data = [self.manufacturerData subdataWithRange:NSMakeRange(0, 2)];
    return data;
}

- (NSData *)specificData {
    if (!self.manufacturerData) {
        return nil;
    }
    if (self.manufacturerData.length < 3) {
        return nil;
    }
    
    NSData * manufacturerData = [self manufacturerData];
    NSData * specificData = [manufacturerData subdataWithRange:NSMakeRange(2, manufacturerData.length - 2)];
    return specificData;
}

- (NSData *)mac {
    if (!self.manufacturerData) {
        return nil;
    }
    if (self.manufacturerData.length < 2 + 6) {
        return nil;
    }
    
    NSData * manufacturerData = [self manufacturerData];
    NSData * macData = [manufacturerData subdataWithRange:NSMakeRange(manufacturerData.length - 6, 6)];
    return macData;
}

@end

@interface YPBleDevice (RSSIRecord)
@property (nonatomic, strong) NSMutableArray * records;
@end

@implementation  YPBleDevice(RSSIRecord)
- (void)setRecords:(NSMutableArray *)records {
    objc_setAssociatedObject(self, @"records", records, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray *)records {
    return objc_getAssociatedObject(self, @"records");
}

- (void)addRSSIRecord:(NSNumber *)rssi {
    if (!self.records) {
        self.records = [NSMutableArray new];
    }
    
    [self.records addObject:@{@"date": [NSDate date], @"rssi": rssi}];
}

- (NSArray *)RSSIRecords {
    return self.records;
}

@end

@implementation YPBleDevice (yp_BleOperation_depaecated_1_0)

- (void)writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data NS_DEPRECATED_IOS(4_0, 5_0, "Use instead") {
    [self writeValue:data forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:p type:CBCharacteristicWriteWithResponse];
}

- (void)writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data NS_DEPRECATED_IOS(4_0, 5_0, "Use instead") {
    [self writeValue:data forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:p type:CBCharacteristicWriteWithoutResponse];
}
@end
