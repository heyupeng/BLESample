//
//  UARTService.h
//  BLESample
//
//  Created by Peng on 2022/9/6.
//  Copyright © 2022 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface UARTService : NSObject<CBPeripheralDelegate>

@property (nonatomic, weak) CBService * service;

+ (instancetype)service:(CBService *)service;

- (void)write:(NSData *)data completion:(void(^)(NSData *res))completion error:(void(^)(NSError *error))error;

- (void)didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;

- (void)didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

- (void)didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

@end

@interface CBService (UARTService)

- (BOOL)isUART;

@end
NS_ASSUME_NONNULL_END
