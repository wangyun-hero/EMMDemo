//
//  SummerServices.m
//  SummerExample
//
//  Created by Chenly on 16/6/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerAsyncServices.h"
#import "SummerInvocation.h"
#import "SummerServices.h"

@implementation SummerAsyncServices

- (void)call:(CDVInvokedUrlCommand *)command {
    
    NSString *method = [command argumentAtIndex:0];
    NSDictionary *params = [command argumentAtIndex:1];
    NSString *callback = params[@"callback"];
    NSString *errorFunction = params[@"error"];
    [self callSeviceWithAction:method params:params callback:callback errorFunction:errorFunction];
}

- (void)callSync:(CDVInvokedUrlCommand *)command {
    // 兼容
    NSString *method = [command argumentAtIndex:0][@"method"];
    NSDictionary *params = [command argumentAtIndex:0][@"params"];
    NSString *callback = params[@"callback"];
    NSString *errorFunction = params[@"error"];
    [self callSeviceWithAction:method params:params callback:callback errorFunction:errorFunction];
}

- (void)callSeviceWithAction:(NSString *)action params:(NSDictionary *)params callback:(NSString *)callback errorFunction:(NSString *)errorFunction {
    
    // method == "xxx.action"
    // 调用原生
    if (![action containsString:@"."]) {
        return;
    }
    
    NSArray *components = [action componentsSeparatedByString:@"."];
    NSString *serviceName = components[0];
    NSString *method = components[1];
    Class targetClass = [SummerServices classForService:serviceName];
    // TODO: 需要添加一个安全机制
    if (![targetClass conformsToProtocol:@protocol(SummerServiceProtocol)]) {
        return;
    }
    id<SummerServiceProtocol> target = [(id<SummerServiceProtocol>)targetClass instanceForServices];
    
    SummerInvocation *invocation = [SummerInvocation invocationWithTarget:target method:method params:params callback:callback sender:self.viewController];
    invocation.errorFunction = errorFunction;
    NSString *bindfield = params[@"bindfield"];
    invocation.bindfield = bindfield.length > 0 ? bindfield : nil;
    [invocation invoke];
}

@end
