//
//  SummerVersionService.m
//  SummerDemo
//
//  Created by zm on 16/9/6.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerVersionService.h"
#import "SummerInvocation.h"
#import "EMMW3FolderManager.h"

@interface SummerVersionService()

@property (nonatomic, strong) SummerInvocation *invocation;

@end

@implementation SummerVersionService

+ (void)load {
    
    if (self == [SummerVersionService self]) {
        [SummerServices registerService:@"XUpgrade" class:@"SummerVersionService"];
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerVersionService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerVersionService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

- (id)getAppVersion:(SummerInvocation *)invocation {

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionCode = infoDictionary[@"CFBundleVersion"];
    NSString *appVersionName = infoDictionary[@"CFBundleShortVersionString"];
    
    NSDictionary *info = @{
                           @"versionCode": appVersionCode,
                           @"versionName": appVersionName
                           };
    return info;
}

- (id)getVersion:(SummerInvocation *)invocation {
    
    NSDictionary *info = [[EMMW3FolderManager sharedInstance] versionInfoForKey:kMainW3FolderKey];
    if (!info) {
        info = [self getAppVersion:nil];
    }
    return info;
}

@end
