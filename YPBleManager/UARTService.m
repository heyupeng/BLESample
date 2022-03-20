//
//  UARTService.m
//  BLESample
//
//  Created by Peng on 2022/9/6.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import "UARTService.h"
#import "YPBleConst.h"

const NSErrorDomain BLEErrorDomainDevice = @"com.bluetooth.device";
const int BLEErrorCode_Peripheral= 9;
const int BLEErrorCode_Service = 10;
const int BLEErrorCode_Characteristic = 11;

@interface UARTService ()
{
    CBCharacteristic * _txCharacteristic;
    CBCharacteristic * _rxCharacteristic;
}

@property (nonatomic, copy) void(^completion)(NSData *res);
@property (nonatomic, copy) void(^error)(NSError *error);

@end

@implementation UARTService

+ (instancetype)service:(CBService *)service {
    UARTService * uart = [[UARTService alloc] init];
    uart.service = service;
    return uart;
}

- (BOOL)checkEnable:(NSError **)error {
    CBPeripheral * peripheral = self.service.peripheral;
    if (peripheral.state != CBPeripheralStateConnected) {
        NSError * err = [NSError errorWithDomain:BLEErrorDomainDevice code:BLEErrorCode_Peripheral userInfo:@{NSLocalizedDescriptionKey: @"Peripheral is not connected"}];
        return NO;
    }
    else if (_service == nil) {
        NSError * err = [NSError errorWithDomain:BLEErrorDomainDevice code:BLEErrorCode_Characteristic userInfo:@{NSLocalizedDescriptionKey: @"UARTService is nil"}];
        return NO;
    }
    else if (_txCharacteristic == nil) {
        NSError * err = [NSError errorWithDomain:BLEErrorDomainDevice code:BLEErrorCode_Characteristic userInfo:@{NSLocalizedDescriptionKey: @"Characteristic is nil"}];
        return NO;
    }
    return NO;
}

- (void)writeHexString:(NSString *)hex completion:(void(^)(NSData * res))completion error:(void(^)(NSError * error))error {
    [self write:[NSData dataWithHexString:hex] completion:completion error:error];
}

- (void)write:(NSData *)data completion:(void(^)(NSData * res))completion error:(void(^)(NSError * error))error {
    CBPeripheral * peripheral = self.service.peripheral;
    NSError * err;
    if ([self checkEnable:&err]) {
        if (error) error(err);
        return;
    }
    self.completion = completion;
    self.error = error;
    [peripheral writeValue:data forCharacteristic:_txCharacteristic type:CBCharacteristicWriteWithResponse];
}

/// CallBack

- (void)didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (![service isEqual:_service]) { return; }
    
    NSArray *characteristics = [service characteristics];
    for (CBCharacteristic *characteristic in characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:NordicUARTTxCharacteristicUUIDString]) {
            _txCharacteristic = characteristic;
        }
        else if ([characteristic.UUID.UUIDString isEqualToString:NordicUARTRxCharacteristicUUIDString]) {
            _rxCharacteristic = characteristic;
        }
    }
}

- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![characteristic isEqual:_rxCharacteristic]) { return; }
    
    if (error) {
        self.error(error);
        return;
    }
    
    NSData * value = characteristic.value;
    self.completion(value);
}

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![characteristic isEqual:_txCharacteristic]) { return; }
    
}

// MARK: - Peripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    [self didDiscoverCharacteristicsForService:service error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

@end

@implementation CBService (UARTService)

- (BOOL)isUART {
//    [self.UUID isEqualToUUID:[CBUUID UUIDWithString:NordicUARTServiceUUIDString]];
    return [self.UUID.UUIDString isEqualToString:NordicUARTServiceUUIDString];
}

@end
    
