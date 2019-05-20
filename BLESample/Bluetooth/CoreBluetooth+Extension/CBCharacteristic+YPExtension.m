//
//  CBCharacteristic+YPExtension.m
//  SOOCASBLE
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

static NSArray * PropertyDescriptions__;

@implementation CBCharacteristic (PropertyDescriptions)

- (NSArray *)PropertyDescriptions {
    if (!PropertyDescriptions__) {
        PropertyDescriptions__ = @[@"Broadcast", @"Read", @"WriteWithoutResponse", @"Write", @"Notify", @"Indicate", @"AuthenticatedSignedWrites", @"ExtendedProperties", @"NotifyEncryptionRequired", @"IndicateEncryptionRequired"];
    }
    return PropertyDescriptions__;
}

- (NSArray<NSString *> *)yp_propertyDescriptions {
    CBCharacteristicProperties properties = [self properties];
    /*
     @[@"Broadcast", @"Read", @"WriteWithoutResponse", @"Write", @"Notify", @"Indicate", @"AuthenticatedSignedWrites", @"ExtendedProperties", @"NotifyEncryptionRequired", @"IndicateEncryptionRequired"]
     */
    NSArray * Descriptions = [self PropertyDescriptions];
    NSMutableArray * descriptions = [[NSMutableArray alloc] initWithCapacity:10];
    
    if (properties & CBCharacteristicPropertyBroadcast) {
        [descriptions addObject:Descriptions[0]];
    }
    if (properties & CBCharacteristicPropertyRead) {
        [descriptions addObject:Descriptions[1]];
    }
    if (properties & CBCharacteristicPropertyWriteWithoutResponse) {
        [descriptions addObject:Descriptions[2]];
    }
    if (properties & CBCharacteristicPropertyWrite) {
        [descriptions addObject:Descriptions[3]];
    }
    if (properties & CBCharacteristicPropertyNotify) {
        [descriptions addObject:Descriptions[4]];
    }
    if (properties & CBCharacteristicPropertyIndicate) {
        [descriptions addObject:Descriptions[5]];
    }
    return descriptions;
}
@end
