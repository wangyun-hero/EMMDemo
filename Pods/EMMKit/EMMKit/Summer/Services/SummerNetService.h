//
//  SummerNetService.h
//  SummerDemo
//
//  Created by Chenly on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerServices.h"

@class SummerInvocation;

@interface SummerNetService : NSObject <SummerServiceProtocol>

/*
 *  网络状态
 */
- (id)getNetworkInfo:(SummerInvocation *)invocation;

/*
 *  是否联网
 */
- (id)isAvailable:(SummerInvocation *)invocation;

/*
 *  网络请求
 */
- (void)get:(SummerInvocation *)invocation;
- (void)post:(SummerInvocation *)invocation;

/*
 *  写入配置
 */
- (void)writeConfigure:(SummerInvocation *)invocation;
- (id)readConfigure:(SummerInvocation *)invocation;

/*
 *  MA
 */
- (void)login:(SummerInvocation *)invocation;
- (void)callAction:(SummerInvocation *)invocation;

@end
