//
//  CBUUID+YPExtension.m
//  BLESample
//
//  Created by Peng on 2019/5/20.
//  Copyright © 2019 heyupeng. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import "CBUUID+YPExtension.h"

/*
 *  @method yp_CFUUIDCreateCStringPtr
 *
 *  @param UUID UUID to convert to cstring
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion yp_CFUUIDCreateCStringPtr converts the data of a CFUUIDRef class to a character pointer
 *
 */
const char * yp_CFUUIDCreateCStringPtr(CFUUIDRef uuid) {
    if (!uuid) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    return CFStringGetCStringPtr(s, 0);
}

/*
 * @method yp_swap
 *
 *  @discussion
 *      converts a 16-bit int to another 16-bit int by exchanging high and low.
 *
 */
UInt16 yp_swap(UInt16 s) {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

@implementation CBUUID (YPExtension)

/**
 Create a CBUUID from a 16-bit int.
 
 @param aUInt16     an UInt16ß
 */
+ (CBUUID *)yp_UUIDWithUInt16:(UInt16)aUInt16 {
    UInt16 cz = yp_swap(aUInt16);
    NSData *cdz = [[NSData alloc] initWithBytes:(char *)&cz length:2];
    CBUUID *cuz = [CBUUID UUIDWithData:cdz];
    return cuz;
}

/**
 Convert a CBUUID to an UInt16 representation of the UUID.
 
 @returns UInt16 Representation of the CBUUID
 */
- (UInt16)yp_UInt16Value {
    [CBUUID yp_UUIDWithUInt16:12];
    char b1[16];
    [self.data getBytes:b1 length:16];
    return ((b1[0] << 8) | b1[1]);
}

/**
 @method isEqualToUUID

 @param UUID UUID to compare
 @return a bool value (equal or not equal)
 */

- (BOOL)isEqualToUUID:(CBUUID *)UUID {
    if (!UUID) {return 0;}
    
    char b1[16];
    char b2[16];
    [self.data getBytes:b1 length:16];
    [UUID.data getBytes:b2 length:16];
    if (memcmp(b1, b2, UUID.data.length) == 0)return 1;
    else return 0;
}

/**
 *  @method yp_UUIDToString
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
- (const char *)yp_UUIDToString {
    return [[self.data description] cStringUsingEncoding:NSASCIIStringEncoding];
}

- (const char *)yp_UUIDToString:(CFUUIDRef)UUID {
    return yp_CFUUIDCreateCStringPtr(UUID);
}

@end


@implementation CBUUID (yp_deprecated_1_0)

+ (CBUUID *)UUIDWithUInt16:(UInt16)aUInt16 {
    return [self yp_UUIDWithUInt16:aUInt16];
}

- (UInt16)UInt16Value {
    return [self yp_UInt16Value];
}

- (const char *)UUIDToString {
    return [self yp_UUIDToString];
}

/**
 *  Compare two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *  @method compare:
 *
 *  @param UUID UUID compared
 *  @returns 1 or 0(equal or not)
 */
- (int)compare:(CBUUID *)UUID {
    char b1[16];
    char b2[16];
    [self.data getBytes:b1 length:16];
    [UUID.data getBytes:b2 length:16];
    if (memcmp(b1, b2, self.data.length) == 0)return 1;
    else return 0;
}

/**
 *  @method compareUInt16:
 *
 *  @param aUInt16 a UInt16 value of UUID
 *  @returns 1 or 0 (equal or not)
 *
 *  @discussion compareUInt16 compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
- (int)compareUInt16:(UInt16)aUInt16 {
    char b1[16];
    [self.data getBytes:b1 length:16];
    UInt16 b2 = yp_swap(aUInt16);
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}

@end
