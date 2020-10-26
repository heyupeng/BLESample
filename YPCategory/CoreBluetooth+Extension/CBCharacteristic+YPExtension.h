//
//  CBCharacteristic+YPExtension.h
//  BLESample
//
//  Created by Peng on 2019/5/20.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBCharacteristic (PropertyDescriptions)

- (NSArray<NSString *> *)yp_propertyDescriptions;

@end

NS_ASSUME_NONNULL_END
