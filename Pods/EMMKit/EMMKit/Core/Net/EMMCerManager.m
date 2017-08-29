//
//  EMMCerManager.m
//  SummerDemo
//
//  Created by Chenly on 2016/12/26.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "EMMCerManager.h"
#import <Aspects/Aspects.h>
#import <AFNetworking/AFNetworking.h>

@implementation EMMCerManager

+ (void)load {
    // 在 AFURLSessionManager 初始化之后加入证书处理
//    SEL sel = NSSelectorFromString(@"initWithSessionConfiguration:");
//    [AFURLSessionManager aspect_hookSelector:sel withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
//        
//        EMMCerManager *cerManager = [EMMCerManager sharedManager];
//        NSSet *certificates = cerManager.pinnedCertificates ?: [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
//        
//        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certificates];
//        securityPolicy.allowInvalidCertificates = cerManager.allowInvalidCertificates;
//        securityPolicy.validatesDomainName = cerManager.validatesDomainName;
//        
//        AFURLSessionManager *manager = [info instance];
//        manager.securityPolicy = securityPolicy;
//        
//    } error:NULL];
}

+ (instancetype)sharedManager {
    static EMMCerManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EMMCerManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _allowInvalidCertificates = YES;
        _validatesDomainName = NO;
    }
    return self;
}

@end
