//
//  SUMEMMService.h
//  SummerDemo
//
//  Created by Chenly on 2017/2/8.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SummerServices.h"

@class SummerInvocation;

@interface SUMEMMService : NSObject <SummerServiceProtocol>

/**
 设置
 @param host 服务器 ip
 @param port 服务器 port
 */
- (void)writeConfig:(SummerInvocation *)invocation;

/**
 自动发现
 @param companyId 公司id(允许为空)
 */
- (void)autofind:(SummerInvocation *)invocation;

/**
 注册设备
 @param username 用户名
 @param password 密码
 @param companyId 租户id
 */
- (void)registerDevice:(SummerInvocation *)invocation;

/**
 登录 
 @param username 用户名
 @param password 密码
 */
- (void)login:(SummerInvocation *)invocation;

- (void)logout:(SummerInvocation *)invocation;
- (void)getApps:(SummerInvocation *)invocation;
- (void)getDocs:(SummerInvocation *)invocation;
- (void)getUserInfo:(SummerInvocation *)invocation;
- (void)modifyPassword:(SummerInvocation *)invocation;
- (void)modifyAvatar:(SummerInvocation *)invocation;
- (void)feedback:(SummerInvocation *)invocation;
- (void)startStrategy:(SummerInvocation *)invocation;
- (void)stopStrategy:(SummerInvocation *)invocation;

@end
