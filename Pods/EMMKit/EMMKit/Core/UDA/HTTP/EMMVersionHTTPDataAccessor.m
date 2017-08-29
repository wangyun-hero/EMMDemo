//
//  EMMVersionHTTPDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMVersionHTTPDataAccessor.h"

@implementation EMMVersionHTTPDataAccessor

- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *appid = params[@"appid"];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    NSDictionary *parameters = @{
                                 @"appid": appid
                                 };
    NSString *data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": data,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

@end
