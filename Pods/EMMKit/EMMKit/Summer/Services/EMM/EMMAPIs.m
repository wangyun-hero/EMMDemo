//
//  EMMAPIs.m
//  SummerDemo
//
//  Created by Chenly on 2017/2/24.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import "EMMAPIs.h"
#import "EMMApplicationContext.h"
#import "EMMDataAccessor.h"
#import "EMMAppModel.h"
#import <YYModel/YYModel.h>

@implementation EMMAPIs

+ (instancetype)sharedInstance {
    static EMMAPIs *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EMMAPIs alloc] init];
    });
    return instance;
}

- (void)fetchApps:(void(^)(NSArray<EMMAppModel *> *apps, NSError *error))completion {
    
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    if (!username) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"username == nil" code:0 userInfo:nil];
            completion(nil, error);
        }
        return;
    }
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.application" request:@"getApplications"];
    [dataAccessor sendRequestWithParams:@{@"username": username} success:^(id result) {
        
        NSArray *apps = [NSArray yy_modelArrayWithClass:[EMMAppModel class] json:result[@"data"][@"apps"]];
        completion(apps, nil);
        
    } failure:^(NSError *error) {
        
        if (completion) {
            completion(nil, error);
        }
    }];
}

@end
