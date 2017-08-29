//
//  SummerWebServiceHandle.h
//  SummerDemo
//
//  Created by zm on 16/8/4.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SummerInvocation;

typedef  void (^completionHandle)(id result,BOOL succeed);

@interface SummerWebServiceHandle : NSObject
+ (instancetype)sharedInstance;

// MA登录服务
- (void)loginMaWebServiceHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler;

- (void)postWebServiceHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler;

- (void)getWebServiceHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler;

- (void)callActionHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler;

// 压缩
+ (NSData *)gzipData:(NSData *)pUncompressedData;
// 解压缩
+ (NSData *)uncompressZippedData:(NSData *)compressedData;
@end
