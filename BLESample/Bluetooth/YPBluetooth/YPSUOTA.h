//
//  YPSUOTA.h
//  YPDemo
//
//  Created by Peng on 2017/12/8.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPBleDevice.h"
#import "YPBlueDefines.h"

@interface YPSUOTA : NSObject
{
    NSMutableData *_fileData;
    char * _url;
}
@property char memoryType;
@property int memoryBank;
@property UInt16 blockSize;

@property int i2cAddress;
@property char i2cSDAAddress;
@property char i2cSCLAddress;

@property char spiMOSIAddress;
@property char spiMISOAddress;
@property char spiCSAddress;
@property char spiSCKAddress;

@property (nonatomic, strong) YPBleDevice * device;
@property (nonatomic, strong) NSString * urlString;
@property (nonatomic, strong) NSURL *file_url;

- (instancetype)initWithDevice:(YPBleDevice *)device;

- (void)setUrl:(const char *)url;
- (void)startUpgrade;
@end
