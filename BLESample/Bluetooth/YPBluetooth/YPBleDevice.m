//
//  YPBleDevice.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPBleDevice.h"

#import "YPBlueConst.h"

@implementation YPBleDevice

- (instancetype)initWithDevice:(CBPeripheral*)device {
    self = [super init];
    if (self) {
        self.device = device;
    }
    return self;
}

- (instancetype)initWithDevice:(CBPeripheral*)device RSSI:(NSNumber *)RSSI  advertisementData:(NSDictionary *)advertisementData {
    self = [super init];
    if (self) {
        self.peripheral = device;
        _RSSI = RSSI;
        _advertisementData = advertisementData;
    }
    return self;
}

- (void)setDevice:(CBPeripheral *)device {
    if ([_peripheral isEqual:device] && [_peripheral.delegate isEqual:self]) {
        return;
    }
    _peripheral = device;
    _peripheral.delegate = self;
}

- (NSString *)deviceName {
    return _peripheral.name;
}

- (NSString *)identifier {
    return _peripheral.identifier.UUIDString;
}

- (NSString *)localName {
    NSString * localName = @"No Name";
    
    if (self.advertisementData && [[self.advertisementData allKeys] containsObject:CBAdvertisementDataLocalNameKey]) {
        localName = [self.advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    }
    return localName;
}

- (NSString *)manufacturerData {
    NSData * data = [self.advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (data) {
        NSString * string = data.description;
        //去除 < > space
        string = [[string substringToIndex:string.length -1 ] substringFromIndex:1];
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        return string;
    }
    return @"";
}

- (NSString *)specificData {
    NSString * manufacturerData = [self manufacturerData];
    NSString * specificData = @"";
    if (manufacturerData.length > 4) {
        specificData = [manufacturerData substringFromIndex:4];
    }
    return specificData;
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
    [self logWithFormat:@"did Update Value: \n\t UUID %@ \n\t Value %@ -> %@", [characteristic UUID], [characteristic value], valueString];
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

- (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2){
    va_list args;
    va_start(args, format);
    NSString * string = [[NSString alloc]initWithFormat:format arguments:args];
    va_end(args);
    
    if (_logger) {
        _logger(string);
    } else {
        NSLog(@"%@", string);
    }
}
#pragma mark - func
/*
 */
- (void)writeValue:(NSData *)data ForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral type:(CBCharacteristicWriteType)type {
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    if (!service) {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        return;
    }
    [peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeFFValue:(NSString *)FFString {
    NSData * data = [NSData dataWithHexString:FFString];
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:NordicUARTTxCharacteristicUUIDString];
    CBUUID * serviceUUID = [CBUUID UUIDWithString:NordicUARTServiceUUIDString];
    
    [self writeValue:data ForCharacteristicUUID:characteristicUUID serviceUUID: serviceUUID peripheral:_peripheral type:CBCharacteristicWriteWithResponse];
}

- (void)writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    [self writeValue:data ForCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:p type:CBCharacteristicWriteWithResponse];
}

- (void)writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    [self writeValue:data ForCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:p type:CBCharacteristicWriteWithoutResponse];
}

- (void)readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral {
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    if (!service) {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
//        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n", [characteristicUUID UUIDToString], [serviceUUID UUIDToString], peripheral.identifier);
        return;
    }
    NSLog(@"characteristic with UUID %s on service with UUID %s\n", [characteristicUUID UUIDToString], [serviceUUID UUIDToString]);
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral {
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    if (!service) {
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        return;
    }
    
    [peripheral setNotifyValue:value forCharacteristic:characteristic];
}

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID {
    CBPeripheral * peripheral = self.peripheral;
    [self setNotifyVuale:value forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:peripheral];
}

- (CBService *)findServiceFromUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)peripheral {
    for(int i = 0; i < peripheral.services.count; i++) {
        CBService *s = [peripheral.services objectAtIndex:i];
        if ([s.UUID isEqualToUUID:UUID]) return s;
    }
    NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n", [UUID UUIDToString], peripheral.identifier);
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID isEqualToUUID:UUID]) return c;
    }
    NSLog(@"Could not find characteristic with UUID %s on service with UUID %s\r\n", [UUID UUIDToString], [[service UUID] UUIDToString]);
    return nil; //Characteristic not found on this service
}

+ (UInt16)swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

@end
