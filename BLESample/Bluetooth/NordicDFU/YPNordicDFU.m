//
//  YPNordicDFU.m
//  OCEmbedSwiftDemo
//
//  Created by Peng on 2019/3/27.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import "YPNordicDFU.h"

@interface YPNordicDFU ()<DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>

@end
@implementation YPNordicDFU

- (instancetype)initWithCentralManager:(CBCentralManager *)central peripheral:(CBPeripheral *)peripheral {
    self = [super init];
    if (self) {
        _dfuInitiator = [self dfuServiceInitiatorWithCentralManager:central peripheral:peripheral];
    }
    return self;
}

- (DFUServiceInitiator *)dfuServiceInitiatorWithCentralManager:(CBCentralManager *)central peripheral: peripheral {
    DFUServiceInitiator * dfuInitiator = [[DFUServiceInitiator alloc] initWithCentralManager:central target:peripheral];
    dfuInitiator.delegate = self;
    dfuInitiator.progressDelegate = self;
    dfuInitiator.logger = self;
    
    return dfuInitiator;
}


- (void)setFirmwareWithFileUrl:(NSURL *)fileUrl type:(DFUFirmwareType)type {
    DFUFirmware * firmware = [[DFUFirmware alloc] initWithUrlToZipFile:fileUrl type:type];
    _firmware = firmware;
}

- (void)setBootloaderEncrypt:(BOOL)encrypt data:(NSArray<NSNumber *> *)data {
    self.dfuInitiator.jumpToBootloaderEncrypt = encrypt;
    self.dfuInitiator.jumpToBootloaderEncryptData = data;
    self.dfuInitiator.alternativeAdvertisingNameEnabled = !encrypt; //默认为YES, bootloader加密下不可重命名
}

- (void)startDFU {
    if (!_firmware) {
        return;
    }
    
    _dfuController = [[_dfuInitiator withFirmware:_firmware] start];
    
}

- (void)startDFUWithEncrypt:(BOOL)encrypt encryptData:(NSArray<NSNumber*> *)encryptData filePath:(NSString *)filePath {
    DFUServiceInitiator * dfuInitiator = [self dfuInitiator];
    dfuInitiator.jumpToBootloaderEncrypt = encrypt; // 自定义属性
    dfuInitiator.jumpToBootloaderEncryptData = encryptData;
    dfuInitiator.alternativeAdvertisingNameEnabled = !encrypt;
    
    dfuInitiator.enableUnsafeExperimentalButtonlessServiceInSecureDfu = YES;
    
    NSString * zipFile = filePath;
    DFUFirmware * firmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL URLWithString:zipFile]];
    _dfuController = [[dfuInitiator withFirmware:firmware] start];
}

#pragma mark - DFUInitiator Delegate
- (void)dfuStateDidChangeTo:(enum DFUState)state {
    if (state == DFUStateCompleted) {
        _dfuController = nil;
    }
    
    if (self.delegate && [self respondsToSelector:@selector(dfuStateDidChangeTo:)]) {
        [self.delegate dfuStateDidChangeTo: state];
    }
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message {
    if (self.delegate && [self respondsToSelector:@selector(dfuError:didOccurWithMessage:)]) {
        [self.delegate dfuError:error didOccurWithMessage:message];
    }
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    if (self.delegate && [self respondsToSelector:@selector(dfuProgressDidChangeFor:outOf:to:currentSpeedBytesPerSecond:avgSpeedBytesPerSecond:)]) {
        [self.delegate dfuProgressDidChangeFor:part outOf:totalParts to:progress currentSpeedBytesPerSecond:currentSpeedBytesPerSecond avgSpeedBytesPerSecond:avgSpeedBytesPerSecond];
    }
}

- (void)logWith:(enum LogLevel)level message:(NSString *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(logWith:message:)]) {
        [self.delegate logWith:level message:message];
    }
}

- (NSString *)descriptionForDFUState:(DFUState)state {
    switch (state) {
        case DFUStateConnecting:      return @"Connecting";
        case DFUStateStarting:        return @"Starting";
        case DFUStateEnablingDfuMode: return @"Enabling DFU Mode";
        case DFUStateUploading:       return @"Uploading";
        case DFUStateValidating:      return @"Validating"  ;// this state occurs only in Legacy DFU
        case DFUStateDisconnecting:   return @"Disconnecting";
        case DFUStateCompleted:       return @"Completed";
        case DFUStateAborted:         return @"Aborted";
    }
}


@end
