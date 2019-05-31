//
//  CBPeripheral+YPExtension.m
//  SOOCASBLE
//
//  Created by Pro on 2019/6/5.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import "CBPeripheral+YPExtension.h"
#import "CBUUID+YPExtension.h"

@implementation CBPeripheral (YPExtension)

@end

@implementation CBPeripheral (yp_BleOperation)

- (void)yp_writeValue:(NSData *)data forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID type:(CBCharacteristicWriteType)type {
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    if (!data) {
        NSLog(@"======= data is nil =======");
    }
    [self writeValue:data forCharacteristic:characteristic type:type];
}

- (void)yp_readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID {
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    NSLog(@"characteristic with UUID %s on service with UUID %s\n", [characteristicUUID UUIDToString], [serviceUUID UUIDToString]);
    [self readValueForCharacteristic:characteristic];
}

- (void)yp_setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID {
    CBPeripheral * peripheral = self;
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    
    [peripheral setNotifyValue:value forCharacteristic:characteristic];
}

- (CBService *)yp_findServiceWithUUID:(CBUUID *)UUID {
    return [self yp_findServiceWithUUID:UUID peripheral:self];
}

- (CBCharacteristic *)yp_findCharacteristicWithUUID:(CBUUID *)UUID serviceUUID:(CBUUID *)serviceUUID peripheral:(CBPeripheral *)peripheral {
    CBService *service = [self yp_findServiceWithUUID:serviceUUID peripheral:peripheral];
    if (!service) {
        return nil;
    }
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:UUID service:service];
    return characteristic;
}

- (CBCharacteristic *)yp_findCharacteristicWithUUID:(CBUUID *)UUID serviceUUID:(CBUUID *)serviceUUID {
    return [self yp_findCharacteristicWithUUID:UUID serviceUUID:serviceUUID peripheral:self];
}

/**
 @method findServiceWithUUID: peripheral:
 
 @param UUID       The Bluetooth UUID of the service.
 @param peripheral The peripheral this service belongs to
 @return           Return a service if found
 */
- (CBService *)yp_findServiceWithUUID:(CBUUID *)UUID peripheral:(CBPeripheral *)peripheral {
    for(int i = 0; i < peripheral.services.count; i++) {
        CBService *s = [peripheral.services objectAtIndex:i];
        if ([s.UUID isEqualToUUID:UUID]) return s;
    }
    NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n", [UUID UUIDToString], peripheral.identifier);
    return nil; //Service not found on this peripheral
}

/**
 @method findCharacteristicWithUUID: service:

 @param UUID        The Bluetooth UUID of the Characteristic to find in Characteristic list of service.
 @param service     The Bluetooth Service.
 @return            Return a CBCharacteristic with a specific UUID if found, or return nil if not.
 */
- (CBCharacteristic *)yp_findCharacteristicWithUUID:(CBUUID *)UUID service:(CBService *)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID isEqualToUUID:UUID]) return c;
    }
    NSLog(@"Could not find characteristic with UUID %s on service with UUID %s\r\n", [UUID UUIDToString], [[service UUID] UUIDToString]);
    return nil; //Characteristic not found on this service
}

@end
