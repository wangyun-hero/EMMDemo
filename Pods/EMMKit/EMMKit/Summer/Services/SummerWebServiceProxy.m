//
//  SummerWebServiceProxy.m
//  SummerDemo
//
//  Created by zm on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerWebServiceProxy.h"
#import <AFNetworking/AFNetworking.h>
#import "SummerWebSettingService.h"

@implementation SummerWebServiceProxy

+ (void)requestNetMethod:(NSString *)method urlString:(NSString *)urlString requestBody:(NSData *)requestBody timeout:(CGFloat)timeout completionHandler:(void (^)(id result, BOOL succeed))completionHandler{
//    NSDictionary *header = @{@"Content-Type":@"application/x-www-form-urlencoded; charset=UTF-8"};
    
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    NSDictionary *header = settingService.header;
    
    [SummerWebServiceProxy requestNetMethod:method urlString:urlString requestBody:requestBody timeout:timeout header:header completionHandler:completionHandler];
}

+ (void)requestNetMethod:(NSString *)method urlString:(NSString *)urlString requestBody:(NSData *)requestBody timeout:(CGFloat)timeout header:(NSDictionary *)header completionHandler:(void (^)(id result, BOOL succeed))completionHandler{
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    
//    if(![urlString hasPrefix:@"http://"]){
//        urlString = [@"http://" stringByAppendingString:urlString];
//    }
    
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"RSA2048CARoot"ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setPinnedCertificates:[NSSet setWithArray:@[certData]]];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = YES;
    [session setSecurityPolicy:securityPolicy];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [header enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [request setValue:obj forHTTPHeaderField:key];
    }];
    [request setHTTPBody:requestBody];
    [request setTimeoutInterval:timeout?timeout:30.0f];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            completionHandler(error, NO);
        }
        else {
            completionHandler(responseObject, YES);
        }
    }];
    [dataTask resume];
}

// 是否有网络
+ (BOOL)isNetReachable {
    return  [[AFNetworkReachabilityManager  sharedManager] networkReachabilityStatus];
}

@end
