//
//  YPDeviceManager.m
//  YPDemo
//
//  Created by Peng on 2017/11/3.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPDeviceManager.h"

#import "YPBlueConst.h"

@implementation YPDeviceManager

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPDevice_DidDiscoverServices object:peripheral.services];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self logWithFormat:@"Service UUID: %@", service.UUID];
    
    NSArray *characteristics = [service characteristics];
    for (CBCharacteristic *characteristic in characteristics) {
        [self logWithFormat:@"\tCharacteristic UUID: %@", [characteristic UUID]];
        
        if (characteristic.properties & CBCharacteristicPropertyRead) {
            /*  x3 某一个版本的设备 readValue() 后, UARTService Rx、Tx 无法 writeValue()
             (Error Domain=CBErrorDomain Code=8 "The specified UUID is not allowed for this operation.")
             */
//            [peripheral readValueForCharacteristic:characteristic];
        }
        
//        if ([service.UUID isEqual:[CBUUID UUIDWithString:NordicUARTServiceUUID]]) {
//            if ([characteristic.UUID.data.hexString isEqualToString:@"6e400003b5a3f393e0a9e50e24dcca9e"]) {
//                /*
//                 _RxCharacteristic = characteristic;
//                 */
//                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//            }
//            if ([characteristic.UUID.data.hexString isEqualToString:@"6e400002b5a3f393e0a9e50e24dcca9e"]) {
//                /*
//                _TxCharacteristic = characteristic;
//                 */
//            }
//        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPDevice_DidDiscoverCharacteristics object:service];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPDevice_DidUpdateValue object:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    [self logWithFormat:@"did Write Value: \n\t UUID %@ \n\t Value %@", [characteristic UUID], [characteristic value]];
    if (error) {
        [self logWithFormat:@"error: %@", error.localizedDescription];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:YPDevice_DidWriteValue object:characteristic];
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
- (void)writeValue:(NSData *)data ForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral type:(CBCharacteristicWriteType)type
{
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:serviceUUID], peripheral.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID], peripheral.identifier);
        return;
    }
    [peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)writeFFValue:(NSString *)FFString {
    NSData * data = [NSData dataWithHexString:FFString];
    CBUUID * characteristicUUID = [CBUUID UUIDWithString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"];
    CBUUID * serviceUUID = [CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"];
    
//    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
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
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:serviceUUID], peripheral.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID], peripheral.identifier);
        return;
    }
    NSLog(@"characteristic with UUID %s on service with UUID %s\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID]);
    [peripheral readValueForCharacteristic:characteristic];
}

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID peripheral:(CBPeripheral *)peripheral {
    CBService *service = [self findServiceFromUUID:serviceUUID peripheral:peripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:serviceUUID], peripheral.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID], peripheral.identifier);
        return;
    }
    
    [peripheral setNotifyValue:value forCharacteristic:characteristic];
}

- (void)setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID {
    CBPeripheral * peripheral = self.peripheral;
    [self setNotifyVuale:value forCharacteristicUUID:characteristicUUID serviceUUID:serviceUUID peripheral:peripheral];
}


/*
 */
/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [YPDeviceManager swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    /*char t[16];
     t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
     NSData *data = [[NSData alloc] initWithBytes:t length:16];
     return [CBUUID UUIDWithData:data];
     */
    UInt16 cz = [YPDeviceManager swap:UUID];
    NSData *cdz = [[NSData alloc] initWithBytes:(char *)&cz length:2];
    CBUUID *cuz = [CBUUID UUIDWithData:cdz];
    return cuz;
}


- (CBService *)findServiceFromUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
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
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

+ (UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

@end
