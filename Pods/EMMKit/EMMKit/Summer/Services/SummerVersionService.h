//
//  SummerVersionService.h
//  SummerDemo
//
//  Created by zm on 16/9/6.
//  Copyright © 2016年 Yonyou. All rights reserved.
//


#import "SummerServices.h"

@class SummerInvocation;

@interface SummerVersionService : NSObject<SummerServiceProtocol>

+ (id)instanceForServices;

// app升级
- (id)getAppVersion:(SummerInvocation *)invocation;

// app内应用升级
- (id)getVersion:(SummerInvocation *)invocation;

@end
