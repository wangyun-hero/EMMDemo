//
//  EMMNetConnection.m
//  EMMFoundationDemo
//
//  Created by Chenly on 16/6/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMNetConnection.h"
#import "AFNetworking.h"

@interface EMMNetConnection ()

@end

@implementation EMMNetConnection

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EMMNetConnection *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMNetConnection alloc] init];
    });
    return sSharedInstance;
}

- (AFHTTPSessionManager *)sessionManager {
    
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return _sessionManager;
}

// 是否有网络
+ (BOOL)isNetReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

- (void)POST:(NSURL *)URL body:(NSData *)body completionHandler:(void (^)(id result, BOOL succeed))completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:body];
    
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            completionHandler(error, NO);
        }
        else {
            completionHandler(responseObject, YES);
        }
    }];
    [dataTask resume];
}

- (void)GET:(NSURL *)URL completionHandler:(void (^)(id result, BOOL succeed))completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            completionHandler(error, NO);
        }
        else {
            completionHandler(responseObject, YES);
        }
    }];
    [dataTask resume];
}

@end
