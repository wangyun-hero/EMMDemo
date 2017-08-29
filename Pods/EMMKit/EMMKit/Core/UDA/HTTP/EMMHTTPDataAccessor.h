//
//  EMMHTTPDataAccessor.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMDataAccessor.h"

@interface EMMHTTPDataAccessor : EMMDataAccessor

@property (nonatomic, copy) NSString *URLString;

/**
 params: {
    "httpMehod": "POST",
    "parameters": {
        "username": "usr",
        "password": "pwd"
    }
 }
 */
- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)sendImageWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
@end
