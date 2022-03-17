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

// MARK: 关于 Bootloader Encrypt 模式，iOSDFULibrary 修改五步走说明。（X5 v1.02less）
// MARK: 1. DFUServiceInitiator 增加关联属性
/**
 // yp add to set jumpToBootloaderEncrypt
//    @objc public var jumpToBootloaderEncrypt: Bool = false
//    @objc public var jumpToBootloaderEncryptData: [UInt8] = []
 or:
 
 @objc public extension DFUServiceInitiator {
 // yp add to set jumpToBootloaderEncrypt
 //    @objc public var jumpToBootloaderEncrypt: Bool = false
 //    @objc public var jumpToBootloaderEncryptData: [UInt8] = []
 
     // Extension Associated Key
     private struct ExtensionAssociatedKey {
         static var jumpToBootloaderEncrypt: String = "jumpToBootloaderEncrypt"
         static var jumpToBootloaderEncryptData: String = "jumpToBootloaderEncryptData"
     }
     
     @objc var jumpToBootloaderEncrypt: Bool {
         get {
             return objc_getAssociatedObject(self, &ExtensionAssociatedKey.jumpToBootloaderEncrypt) as? Bool ?? false
         }
         set {
             objc_setAssociatedObject(self, &ExtensionAssociatedKey.jumpToBootloaderEncrypt, newValue, .OBJC_ASSOCIATION_ASSIGN)
         }
     }
     
     @objc var jumpToBootloaderEncryptData: [UInt8] {
         get {
             return objc_getAssociatedObject(self, &ExtensionAssociatedKey.jumpToBootloaderEncryptData) as? [UInt8] ?? []
         }
         set {
             objc_setAssociatedObject(self, &ExtensionAssociatedKey.jumpToBootloaderEncryptData, newValue, .OBJC_ASSOCIATION_COPY)
         }
     }
 }
 */

// MARK: 2. SecureDFUPeripheral 扩展
/**
 extension SecureDFUPeripheral {
     // yp add to set dfu Bootloader encryption (X5/M1S/MiTu)
     func jumpToBootloader(WithEncryp encryp: Bool, encrypData: [UInt8]) {
         jumpingToBootloader = true
         newAddressExpected = dfuService!.newAddressExpected
         
         dfuService!.jumpToBootloaderMode(withEncryp: encryp, encrypData: encrypData, withAlternativeAdvertisingName: alternativeAdvertisingNameEnabled,
                                          // onSuccess the device gets disconnected and centralManager(_:didDisconnectPeripheral:error) will be called
             onError: { (error, message) in
                 self.jumpingToBootloader = false
                 self.delegate?.error(error, didOccurWithMessage: message)
             }
         )
     }
 }
 */

// MARK: 3. SecureDFUService 扩展
/**
 extension SecureDFUService {
     // yp add to jumpToBootloaderMode with encryption if need
     func jumpToBootloaderMode(withEncryp encrypt: Bool, encrypData: [UInt8],  withAlternativeAdvertisingName rename: Bool, onError report: @escaping ErrorCallback) {
         if !aborted {
             func enterBootloader() {
                 if encrypt {
                     self.buttonlessDfuCharacteristic!.send(ButtonlessDFURequest.enterBootloaderWith(data: encrypData), onSuccess: nil, onError: report)
                     return;
                 }
                 self.buttonlessDfuCharacteristic!.send(ButtonlessDFURequest.enterBootloader, onSuccess: nil, onError: report)
             }
             enterBootloader()
         } else {
             sendReset(onError: report)
         }
     }
 }
 */

// MARK: 4. ButtonlessDFURequest 枚举 增加一个case分例
/** 替换
 public enum ButtonlessDFURequest {
     case enterBootloader
     case enterBootloaderWith(data: [UInt8])
     case set(name : String)
     
     var data : Data {
         switch self {
         case .enterBootloader:
             return Data(bytes: [ButtonlessDFUOpCode.enterBootloader.code])
         case .enterBootloaderWith(let bytes):
             // yp add a new case
             var data = Data(bytes: bytes)
             data += ButtonlessDFUOpCode.enterBootloader.code
             return data
         case .set(let name):
             var data = Data(bytes: [ButtonlessDFUOpCode.setName.code])
             data += UInt8(name.lengthOfBytes(using: String.Encoding.utf8))
             data += name.utf8
             return data
         }
     }
 }
 */

// MARK: 5. SecureDFUExecutor.peripheralDidEnableControlPoint() 修改
/** 替换
 func peripheralDidEnableControlPoint() {
     // Check whether the target is in application or bootloader mode
     if peripheral.isInApplicationMode(initiator.forceDfu) {
         DispatchQueue.main.async(execute: {
             self.delegate?.dfuStateDidChange(to: .enablingDfuMode)
         })
         
         // yp add to replace {peripheral.jumpToBootloader()}
         if self.initiator.jumpToBootloaderEncrypt {
             peripheral.jumpToBootloader(WithEncryp: self.initiator.jumpToBootloaderEncrypt, encrypData: self.initiator.jumpToBootloaderEncryptData)
             return;
         }
         
         peripheral.jumpToBootloader()
     } else {
         // The device is ready to proceed with DFU
         
         // Start by reading command object info to get the maximum write size.
         peripheral.readCommandObjectInfo()
     }
 }
 */
