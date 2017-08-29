//
//  BluetoothHandler.h
//  EMMKitDemo
//
//  Created by zm on 2016/11/29.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void  (^bluetoothBlock)(BOOL isSuccess, NSString *result);

@interface BluetoothHandler : NSObject

+ (void)getCardUserInfo:(bluetoothBlock)block;

+ (void)getCardID:(bluetoothBlock)block;

+ (void)checkPWD:(unsigned char *)pin resultBlock:(bluetoothBlock)block;

+ (void)signName:(unsigned char *)random randomLen:(unsigned int)randomLen pin:(unsigned char *)pin resultBlock:(bluetoothBlock)block;

+ (void)signData:(unsigned char *)random randomLen:(unsigned int)randomLen pin:(unsigned char *)pin resultBlock:(bluetoothBlock)block;

+ (unsigned char *)enCodingFromString:(NSString *)string;
@end
