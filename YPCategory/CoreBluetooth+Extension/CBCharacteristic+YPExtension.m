//
//  CBCharacteristic+YPExtension.m
//  BLESample
//
//  Created by Peng on 2019/5/20.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import "CBCharacteristic+YPExtension.h"

/*
 CBCharacteristicPropertyBroadcast                                                = 0x01,
 CBCharacteristicPropertyRead                                                    = 0x02,
 CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
 CBCharacteristicPropertyWrite                                                    = 0x08,
 CBCharacteristicPropertyNotify                                                    = 0x10,
 CBCharacteristicPropertyIndicate                                                = 0x20,
 CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
 CBCharacteristicPropertyExtendedProperties                                        = 0x80,
 CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x100,
 CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x200
 */

static NSArray * _propertyDescriptions_;

@implementation CBCharacteristic (PropertyDescriptions)

- (NSArray *)propertyDescriptions {
    if (!_propertyDescriptions_) {
        _propertyDescriptions_ = @[
            @"Broadcast",
            @"Read",
            @"WriteWithoutResponse",
            @"Write",
            @"Notify",
            @"Indicate",
            @"AuthenticatedSignedWrites",
            @"ExtendedProperties",
            @"NotifyEncryptionRequired",
            @"IndicateEncryptionRequired",
        ];
    }
    return _propertyDescriptions_;
}

- (NSArray<NSString *> *)yp_propertyDescriptions {
    CBCharacteristicProperties properties = [self properties];
    NSArray * propertyKeys = [self propertyDescriptions];
    NSMutableArray * descriptions = [[NSMutableArray alloc] initWithCapacity:10];
    
    NSArray * options = @[
        @(0x01),
        @(0x02),
        @(0x04),
        @(0x08),
        @(0x10),
        @(0x20),
        @(0x40),
        @(0x80),
        @(0x100),
        @(0x200),
    ];
    
    for (NSNumber * option in options) {
       if (properties & [option unsignedIntegerValue]) {
           NSUInteger index = [options indexOfObject:option];
           [descriptions addObject:propertyKeys[index]];
       }
    }
    return descriptions;
}
@end
