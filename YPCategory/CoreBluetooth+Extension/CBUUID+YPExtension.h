//
//  CBUUID+YPExtension.h
//  BLESample
//
//  Created by Peng on 2019/5/20.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBUUID (YPExtension)

/*!
 * @method UUIDWithUInt16:
 *
 *  @discussion
 *      Creates a CBUUID with a 16-bit UUID int.
 *
 */
+ (CBUUID *)yp_UUIDWithUInt16:(UInt16)aUInt16;

- (UInt16)yp_UInt16Value;

- (const char *)yp_UUIDToString;

- (BOOL)isEqualToUUID:(CBUUID *)UUID;

@end

@interface CBUUID (yp_deprecated_1_0)
+ (CBUUID *)UUIDWithUInt16:(UInt16)aUInt16;

- (UInt16)UInt16Value;

- (const char *)UUIDToString;

- (int)compare:(CBUUID *)UUID;

@end

NS_ASSUME_NONNULL_END
