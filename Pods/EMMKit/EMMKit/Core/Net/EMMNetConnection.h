//
//  EMMNetConnection.h
//  EMMFoundationDemo
//
//  Created by Chenly on 16/6/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

@interface EMMNetConnection : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

+ (instancetype)sharedInstance;
+ (BOOL)isNetReachable;

// 通用请求
- (void)POST:(NSURL *)URL body:(NSData *)body completionHandler:(void (^)(id result, BOOL succeed))completionHandler;
- (void)GET:(NSURL *)URL completionHandler:(void (^)(id result, BOOL succeed))completionHandler;

@end
