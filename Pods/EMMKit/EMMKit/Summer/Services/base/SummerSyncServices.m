//
//  SummerSyncServices.m
//  SummerExample
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerSyncServices.h"
#import "SummerServices.h"
#import "SummerInvocation.h"
#import "JSContext+Summer.h"

@implementation SummerSyncServices

+ (id)callSync:(NSString *)action args:(NSString *)argsJSON {
    
    NSData *data = [argsJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    // method == "xxx.action"
    // 调用原生
    if (![action containsString:@"."]) {
        return nil;
    }
    NSArray *components = [action componentsSeparatedByString:@"."];
    NSString *serviceName = components[0];
    NSString *method = components[1];
    NSString *callback = [params isKindOfClass:[NSDictionary class]] ? params[@"callback"] : nil;
    
    Class targetClass = [SummerServices classForService:serviceName];
    if (![targetClass conformsToProtocol:@protocol(SummerServiceProtocol)]) {
        return nil;
    }
    id<SummerServiceProtocol> target = [(id<SummerServiceProtocol>)targetClass instanceForServices];
    SummerInvocation *invocation = [SummerInvocation invocationWithTarget:target method:method params:params callback:callback sender:[JSContext currentContext].sender];
    id result = [invocation invoke];
    if ([result isKindOfClass:[NSArray class]] ||
        [result isKindOfClass:[NSDictionary class]]) {
        result = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:0 error:nil] encoding:NSUTF8StringEncoding];
    }
    return result;
}

@end
