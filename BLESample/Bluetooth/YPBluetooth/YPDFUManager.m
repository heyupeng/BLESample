//
//  YPDFUManager.m
//  YPDemo
//
//  Created by Peng on 2017/12/8.
//  Copyright © 2017年 heyupeng. All rights reserved.
//

#import "YPDFUManager.h"
#import <UIKit/UIKit.h>

#import "YPBlueConst.h"

#define UIALERTVIEW_TAG_REBOOT 1

@interface YPDFUManager()
{
    int step, nextStep;
    int expectedValue;
    
    int chunkSize;
    int blockStartByte;
}
@end

@implementation YPDFUManager
- (instancetype)initWithDevice:(YPBleDevice *)device {
    self = [super init];
    if (self) {
        step = 0;
        _device = device;
        [self  setAddress];
        
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        step = 0;
        [self  setAddress];
    }
    return self;
}
- (void)setUrlString:(NSString *)urlString {
    NSString * classString = NSStringFromClass([urlString class]);
    if ([classString isEqualToString:@"__NSCFString"]) {
        _urlString = [NSString stringWithFormat:@"%@",urlString];
    } else {
        _urlString = urlString;
    }
    _file_url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", urlString]];
}
- (void)setAddress {
    [self setMemoryType:MEM_TYPE_SUOTA_SPI];
    [self setSpiMISOAddress:P0_5];
    [self setSpiMOSIAddress:P0_6];
    [self setSpiCSAddress:P0_3];
    [self setSpiSCKAddress:P0_0];
    
    [self setMemoryBank:0];
    [self setBlockSize:240];
}

- (void)setUrl:(const char *)url {
    _url = (char *)url;
    _urlString = [NSString stringWithUTF8String:url];
    _file_url = [NSURL fileURLWithPath:_urlString];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
- (void) addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateValueForCharacteristic:)
                                                 name:YPBLEDevice_DidUpdateValue object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendValueForCharacteristic:)
                                                 name:YPBLEDevice_DidWriteValue object:nil];
    
    // Enable notifications on the status characteristic
//    [_device setNotifyVuale:YES forCharacteristicUUID:[CBUUID UUIDWithString:SPOTA_SERV_STATUS_UUID] serviceUUID:[_device IntToCBUUID:SPOTA_SERVICE_UUID]];
}

- (void)startUpgrade {
    [self addNotification];
    step = 1;
    [self doStep];
}

- (void) didUpdateValueForCharacteristic: (NSNotification*)notification {
    CBCharacteristic *characteristic = (CBCharacteristic*) notification.object;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SPOTA_SERV_STATUS_UUID]]) {
        char value;
        [characteristic.value getBytes:&value length:sizeof(char)];
        
        NSString *message = [self getErrorMessage:(SPOTA_STATUS_VALUES)value];
        [self debug:message];
        
        if (expectedValue != 0) {
            // Check if value equals the expected values
            if (value == expectedValue) {
                // If so, continue with the next step
                step = nextStep;
                
                expectedValue = 0; // Reset
                
                [self doStep];
            } else {
                // Else display an error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                expectedValue = 0; // Reset
                //                [autoscrollTimer invalidate];
                
                [self upgadeError:message];
            }
        }
    }
}

- (void) didSendValueForCharacteristic: (NSNotification*)notification {
    if (step) {
        [self doStep];
    }
}

- (void) doStep {
    [self debug:[NSString stringWithFormat:@"*** Next step: %d", step]];
    
    switch (step) {
        case 1: {
            // Step 1: Set memory type
            
            step = 0;
            expectedValue = 0x10;
            nextStep = 2;
            
            int _memDevData = (self.memoryType << 24) | (self.memoryBank & 0xFF);
            [self debug:[NSString stringWithFormat:@"Sending data: %#10x", _memDevData]];
            NSData *memDevData = [NSData dataWithBytes:&_memDevData length:sizeof(int)];
            [_device writeValue:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:_device.peripheral data:memDevData];
            break;
        }
            
        case 2: {
            // Step 2: Set memory params
            int _memInfoData;
            if (self.memoryType == MEM_TYPE_SUOTA_SPI) {
                _memInfoData = (self.spiMISOAddress << 24) | (self.spiMOSIAddress << 16) | (self.spiCSAddress << 8) | self.spiSCKAddress;
            } else if (self.memoryType == MEM_TYPE_SUOTA_I2C) {
                _memInfoData = (self.i2cAddress << 16) | (self.i2cSCLAddress << 8) | self.i2cSDAAddress;
            }
            [self debug:[NSString stringWithFormat:@"Sending data: %#10x", _memInfoData]];
            NSData *memInfoData = [NSData dataWithBytes:&_memInfoData length:sizeof(int)];
            
            step = 3;
            [_device writeValue:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_GPIO_MAP_UUID] p:_device.peripheral data:memInfoData];
            break;
        }
            
        case 3: {
            // Load patch data
            _file_url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:_url]];
            [self debug:[NSString stringWithFormat:@"Loading data from %@", [(NSURL *)_file_url absoluteString]]];
            _fileData = [[NSData dataWithContentsOfURL:_file_url] mutableCopy];
            [self appendChecksum];
            [self debug:[NSString stringWithFormat:@"Size: %d", (int) [_fileData length]]];
            
            // Step 3: Set patch length
            chunkSize = 20;
            blockStartByte = 0;
            
            step = 4;
            [self doStep];
            break;
        }
            
        case 4: {
            // Set patch length
            //UInt16 blockSizeLE = (blockSize & 0xFF) << 8 | (((blockSize & 0xFF00) >> 8) & 0xFF);
            
            [self debug:[NSString stringWithFormat:@"Sending data: %#6x", _blockSize]];
            NSData *patchLengthData = [NSData dataWithBytes:&_blockSize length:sizeof(UInt16)];
            
            step = 5;
            
            [_device writeValue:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_PATCH_LEN_UUID] p:_device.peripheral data:patchLengthData];
//            [_device readValueForCharacteristicUUID:[CBUUID UUIDWithString:SPOTA_PATCH_LEN_UUID] serviceUUID:[_device IntToCBUUID:SPOTA_SERVICE_UUID] peripheral:_device.peripheral];
            break;
        }
            
        case 5: {
            // Send current block in chunks of 20 bytes
            step = 0;
            expectedValue = 0x02;
            nextStep = 5;
            
            int dataLength = (int) [_fileData length];
            int chunkStartByte = 0;
            
            while (chunkStartByte < _blockSize) {
                
                // Check if we have less than current block-size bytes remaining
                int bytesRemaining = _blockSize - chunkStartByte;
                if (bytesRemaining < chunkSize) {
                    chunkSize = bytesRemaining;
                }
                
                [self debug:[NSString stringWithFormat:@"Sending bytes %d to %d (%d/%d) of %d", blockStartByte + chunkStartByte, blockStartByte + chunkStartByte + chunkSize, chunkStartByte, _blockSize, dataLength]];
                
                double progress = (double)(blockStartByte + chunkStartByte + chunkSize) / (double)dataLength;
                //
                [self upgradeProgress:progress];
                
                // Step 4: Send next n bytes of the patch
                char bytes[chunkSize];
                [_fileData getBytes:bytes range:NSMakeRange(blockStartByte + chunkStartByte, chunkSize)];
                NSData *byteData = [NSData dataWithBytes:&bytes length:sizeof(char)*chunkSize];
                
                // On to the chunk
                chunkStartByte += chunkSize;
                
                // Check if we are passing the current block
                if (chunkStartByte >= _blockSize) {
                    // Prepare for next block
                    blockStartByte += _blockSize;
                    
                    int bytesRemaining = dataLength - blockStartByte;
                    if (bytesRemaining == 0) {
                        nextStep = 6;
                        
                    } else if (bytesRemaining < _blockSize) {
                        _blockSize = bytesRemaining;
                        nextStep = 4; // Back to step 4, setting the patch length
                    }
                }
                
                [_device writeValueWithoutResponse:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_PATCH_DATA_UUID] p:_device.peripheral data:byteData];
            }
            
            break;
        }
            
        case 6: {
            // Send SUOTA END command
            step = 0;
            expectedValue = 0x02;
            nextStep = 7;
            
            int suotaEnd = 0xFE000000;
            [self debug:[NSString stringWithFormat:@"Sending data: %#10x", suotaEnd]];
            NSData *suotaEndData = [NSData dataWithBytes:&suotaEnd length:sizeof(int)];
            [_device writeValue:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:_device.peripheral data:suotaEndData];
            break;
        }
            
        case 7: {
            // Wait for user to confirm reboot
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device has been updated" message:@"Do you wish to reboot the device?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes, reboot", nil];
//            [alert setTag:UIALERTVIEW_TAG_REBOOT];
//            [alert show];
            
            // Send reboot signal to device
            step = 8;
            int suotaEnd = 0xFD000000;
            [self debug:[NSString stringWithFormat:@"Sending data: %#10x", suotaEnd]];
            NSData *suotaEndData = [NSData dataWithBytes:&suotaEnd length:sizeof(int)];
            [_device writeValue:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:_device.peripheral data:suotaEndData];
            break;
        }
            
        case 8: {
            // Go back to overview of devices
            [self upgradeSuccessful];

            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    [autoscrollTimer invalidate];
//
//    if (alertView.tag == UIALERTVIEW_TAG_REBOOT) {
//        if (buttonIndex != alertView.cancelButtonIndex) {
//            // Send reboot signal to device
//            step = 8;
//            int suotaEnd = 0xFD000000;
//            [self debug:[NSString stringWithFormat:@"Sending data: %#10x", suotaEnd]];
//            NSData *suotaEndData = [NSData dataWithBytes:&suotaEnd length:sizeof(int)];
//            [_device writeValue:[_device IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:_device.peripheral data:suotaEndData];
//        }
//    }
}

- (void) debug:(NSString*)message {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.textView.text = [self.textView.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", message]];
    });
    NSLog(@"DFU %@", message);
}

- (void)upgradeProgress:(float)progress {
//    [self.progressView setProgress:progress];
//    [self.progressTextLabel setText:[NSString stringWithFormat:@"%d%%", (int)(100 * progress)]];
    NSLog(@"DFU upgradeProgress:%.2f", progress);
}

- (void)upgadeError:(NSString *)error {
    NSLog(@"DFU upgadeError:%@", error);

}

- (void)upgradeSuccessful {
    NSLog(@"DFU upgradeSuccessful");
}

- (void)autoscrollTimerFired:(NSTimer*)timer {
//    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length], 0)];
}

- (void) appendChecksum {
    uint8_t crc_code = 0;
    
    const char *bytes = (const char *)[_fileData bytes];
    for (int i = 0; i < [_fileData length]; i++) {
        crc_code ^= bytes[i];
    }
    
    [self debug:[NSString stringWithFormat:@"Checksum for file: %#4x", crc_code]];
    
    [_fileData appendBytes:&crc_code length:sizeof(uint8_t)];
}

- (NSString*) getErrorMessage:(SPOTA_STATUS_VALUES)status {
    NSString *message;
    
    switch (status) {
        case SPOTAR_SRV_STARTED:
            message = @"Valid memory device has been configured by initiator. No sleep state while in this mode";
            break;
            
        case SPOTAR_CMP_OK:
            message = @"SPOTA process completed successfully.";
            break;
            
        case SPOTAR_SRV_EXIT:
            message = @"Forced exit of SPOTAR service.";
            break;
            
        case SPOTAR_CRC_ERR:
            message = @"Overall Patch Data CRC failed";
            break;
            
        case SPOTAR_PATCH_LEN_ERR:
            message = @"Received patch Length not equal to PATCH_LEN characteristic value";
            break;
            
        case SPOTAR_EXT_MEM_WRITE_ERR:
            message = @"External Mem Error (Writing to external device failed)";
            break;
            
        case SPOTAR_INT_MEM_ERR:
            message = @"Internal Mem Error (not enough space for Patch)";
            break;
            
        case SPOTAR_INVAL_MEM_TYPE:
            message = @"Invalid memory device";
            break;
            
        case SPOTAR_APP_ERROR:
            message = @"Application error";
            break;
            
            // SUOTAR application specific error codes
        case SPOTAR_IMG_STARTED:
            message = @"SPOTA started for downloading image (SUOTA application)";
            break;
            
        case SPOTAR_INVAL_IMG_BANK:
            message = @"Invalid image bank";
            break;
            
        case SPOTAR_INVAL_IMG_HDR:
            message = @"Invalid image header";
            break;
            
        case SPOTAR_INVAL_IMG_SIZE:
            message = @"Invalid image size";
            break;
            
        case SPOTAR_INVAL_PRODUCT_HDR:
            message = @"Invalid product header";
            break;
            
        case SPOTAR_SAME_IMG_ERR:
            message = @"Same Image Error";
            break;
            
        case SPOTAR_EXT_MEM_READ_ERR:
            message = @"Failed to read from external memory device";
            break;
            
        default:
            message = @"Unknown error";
            break;
    }
    
    return message;
}
@end
