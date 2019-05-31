//
//  CBPeripheral+YPExtension.h
//  SOOCASBLE
//
//  Created by Pro on 2019/6/5.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (YPExtension)

@end

@interface CBPeripheral (yp_BleOperation)

- (void)yp_setNotifyVuale:(BOOL)value forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID;

- (void)yp_readValueForCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID;

- (void)yp_writeValue:(NSData *)data forCharacteristicUUID:(CBUUID*)characteristicUUID serviceUUID:(CBUUID*)serviceUUID type:(CBCharacteristicWriteType)type;

- (CBService *)yp_findServiceWithUUID:(CBUUID *)UUID;

- (CBCharacteristic *)yp_findCharacteristicWithUUID:(CBUUID *)UUID service:(CBService *)service;

- (CBCharacteristic *)yp_findCharacteristicWithUUID:(CBUUID *)UUID serviceUUID:(CBUUID *)serviceUUID;

@end

NS_ASSUME_NONNULL_END
