//
//  CBPeripheral+YPExtension.m
//  BLESample
//
//  Created by Pro on 2019/6/5.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import "CBPeripheral+YPExtension.h"
#import "CBUUID+YPExtension.h"

@implementation CBPeripheral (yp_BleOperation)

- (void)yp_writeValue:(NSData *)data forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID type:(CBCharacteristicWriteType)type {
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
    if (!data) {
        NSLog(@"ERROR: The data being written is nil.");
        return;
    }
    [self writeValue:data forCharacteristic:characteristic type:type];
}

- (void)yp_readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID {
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:characteristicUUID serviceUUID:serviceUUID];
    if (!characteristic) {
        return;
    }
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
@end


@implementation CBPeripheral (yp_ServiceAndCharacteristic)

- (CBService *)yp_serviceWithUUID:(CBUUID *)serviceUUID {
    CBPeripheral * peripheral = self;
    for(int i = 0; i < peripheral.services.count; i++) {
        CBService *s = [peripheral.services objectAtIndex:i];
        if ([s.UUID isEqualToUUID:serviceUUID]) return s;
    }
    NSLog(@"ERROR: The service (UUID %s) is not found on peripheral (UUID %@) .\n", [serviceUUID UUIDToString], peripheral.identifier);
    return nil; // Service is not found on this peripheral
}


- (CBCharacteristic *)yp_characteristicWithUUID:(CBUUID *)UUID serviceUUID:(CBUUID *)serviceUUID {
    CBPeripheral * peripheral = self;
    CBService *service = [self yp_findServiceWithUUID:serviceUUID];
    if (!service) {
        return nil;
    }
    
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID isEqualToUUID:UUID]) return c;
    }
    NSLog(@"ERROR: The characteristic (UUID %s) is not found on service (UUID %s) .\n", [UUID UUIDToString], [[service UUID] UUIDToString]);
    return nil; // Characteristic is not found on this service
}
@end


@implementation CBPeripheral (yp_Deprecated)

/**
 @method findServiceWithUUID: peripheral:
 
 @param UUID       The Bluetooth UUID of the service.
 @return           Return a service if found
 */
- (CBService *)yp_findServiceWithUUID:(CBUUID *)UUID {
    CBPeripheral * peripheral = self;
    for(int i = 0; i < peripheral.services.count; i++) {
        CBService *s = [peripheral.services objectAtIndex:i];
        if ([s.UUID isEqualToUUID:UUID]) return s;
    }
    NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n", [UUID UUIDToString], peripheral.identifier);
    return nil; //Service not found on this peripheral
}

- (CBCharacteristic *)yp_findCharacteristicWithUUID:(CBUUID *)UUID serviceUUID:(CBUUID *)serviceUUID {
    CBService *service = [self yp_findServiceWithUUID:serviceUUID];
    if (!service) {
        return nil;
    }
    CBCharacteristic *characteristic = [self yp_findCharacteristicWithUUID:UUID service:service];
    return characteristic;
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
