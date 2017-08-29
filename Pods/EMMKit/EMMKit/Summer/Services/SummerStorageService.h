//
//  SummerStorageService.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SummerServices.h"

@class SummerInvocation;

@interface SummerStorageService : NSObject <SummerServiceProtocol>

+ (id)instanceForServices;

- (void)writeApplicationContext:(SummerInvocation *)invocation;
- (id)readApplicationContext:(SummerInvocation *)invocation;

- (void)writeConfigure:(SummerInvocation *)invocation;
- (id)readConfigure:(SummerInvocation *)invocation;

- (void)writeWindowContext:(SummerInvocation *)invocation;
- (id)readWindowContext:(SummerInvocation *)invocation;

@end