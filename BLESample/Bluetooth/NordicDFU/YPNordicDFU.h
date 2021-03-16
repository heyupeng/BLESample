//
//  YPNordicDFU.h
//  OCEmbedSwiftDemo
//
//  Created by Peng on 2019/3/27.
//  Copyright © 2019年 heyupeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

NS_ASSUME_NONNULL_BEGIN

// DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate
@protocol NordicDFUDelegate <NSObject, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>

- (void)dfuStateDidChangeTo:(enum DFUState)state;

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message;

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond;

- (void)logWith:(enum LogLevel)level message:(NSString *)message;

@end

@interface YPNordicDFU : NSObject <DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>

// Nordic DFU
@property (nonatomic, readonly) DFUServiceInitiator * dfuInitiator;

@property (nonatomic, readonly) DFUServiceController * dfuController;

@property (nonatomic, strong) DFUFirmware * firmware;

@property (nonatomic, weak) id<NordicDFUDelegate> delegate;

- (instancetype)initWithCentralManager:(CBCentralManager *)central peripheral:(CBPeripheral *)peripheral;

- (void)setFirmwareWithFileUrl:(NSURL *)fileUrl type:(DFUFirmwareType)firnwareType;

- (void)startDFU;

// aviliable when secureDFU
- (void)startDFUWithEncrypt:(BOOL)encrypt encryptData:(NSArray<NSNumber*> *)encryptData filePath:(NSString *)filePath;

- (NSString *)descriptionForDFUState:(DFUState)state;

@end

NS_ASSUME_NONNULL_END
