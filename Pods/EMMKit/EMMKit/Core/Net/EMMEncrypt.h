//
//  EMMEncrypUtil.h
//  EMMKitDemo
//
//  Created by Chenly on 16/6/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMEncrypt : NSObject

+ (NSString *)encryptDES:(NSString *)plainText;
+ (NSString *)decryptDES:(NSString *)plainText;

@end
