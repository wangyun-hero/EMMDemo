//
//  SUMSessionService.h
//  SummerDemo
//
//  Created by Chenly on 16/9/18.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SummerServices.h"

@class SummerInvocation;

@interface SUMSessionService : NSObject <SummerServiceProtocol>

- (id)getCookie:(SummerInvocation *)invocation;
- (void)setCookie:(SummerInvocation *)invocation;

- (id)getSessionId:(SummerInvocation *)invocation;
- (void)setSessionId:(SummerInvocation *)invocation;

@end
