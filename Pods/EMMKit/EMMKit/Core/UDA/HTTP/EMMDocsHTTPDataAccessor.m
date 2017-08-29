//
//  EMMDocsHTTPDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMDocsHTTPDataAccessor.h"
#import "EMMDeviceInfo.h"

@implementation EMMDocsHTTPDataAccessor

- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure {

    [self getDocumentsWithParams:params success:success failure:failure];
}

- (void)getDocumentsWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *username = params[@"username"];
    NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
    NSString *OSType = @"ios";
    
    NSDictionary *parameters = @{
                                 @"userid": username,
                                 @"os": OSType,
                                 @"deviceid": UUID
                                 };
    NSString *data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": data,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

@end
