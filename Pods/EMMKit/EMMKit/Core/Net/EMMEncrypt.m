//
//  EMMEncrypUtil.m
//  EMMKitDemo
//
//  Created by Chenly on 16/6/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMEncrypt.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation EMMEncrypt

+ (NSString *)encryptDES:(NSString *)plainText {
    return [self encryptDES:plainText operation:kCCEncrypt];
}

+ (NSString *)decryptDES:(NSString *)plainText {
    return [self encryptDES:plainText operation:kCCDecrypt];
}

+ (NSString *)encryptDES:(NSString *)plainText operation:(CCOperation)operation {
    
    NSString *key = @"12345678";
    
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (operation == kCCEncrypt) {
        
        NSData *encryptData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [encryptData length];
        vplainText = (const void *)[encryptData bytes];
    }
    else {
        // 先 Base64 解密
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:plainText options:NSDataBase64DecodingIgnoreUnknownCharacters];
        plainTextBufferSize = [decodedData length];
        vplainText = [decodedData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    const void *vkey = (const void *) [key UTF8String];
    Byte  iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
    
    ccStatus = CCCrypt(operation,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding,
                       vkey,
                       kCCKeySizeDES,
                       iv,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    
    NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    
    NSString *result;
    if (operation == kCCEncrypt) {
        // DES 加密后，使用 Base64 加密。
        result = [data base64EncodedStringWithOptions:0];
    }
    else {
        result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    }
    return result;
}

@end
