//
//  SUMSessionService.m
//  SummerDemo
//
//  Created by Chenly on 16/9/18.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMSessionService.h"
#import "SummerInvocation.h"

@implementation SUMSessionService

static NSString * const kSessionIdName = @"JSessionId";

+ (void)load {
    if (self == [SUMSessionService self]) {
        [SummerServices registerService:@"Session" class:NSStringFromClass(self)];
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SUMSessionService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SUMSessionService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

#pragma mark - method

- (id)getCookie:(SummerInvocation *)invocation {

    return [self getCookieWithProperties:invocation.params];
}

- (void)setCookie:(SummerInvocation *)invocation {
    
    [self setCookieWithProperties:invocation.params];
}

- (id)getSessionId:(SummerInvocation *)invocation {

    NSMutableDictionary *properties = [invocation.params mutableCopy];
    properties[@"name"] = kSessionIdName;
    return [self getCookieWithProperties:properties][kSessionIdName];
}

- (void)setSessionId:(SummerInvocation *)invocation {

    NSMutableDictionary *properties = [invocation.params mutableCopy];
    properties[@"name"] = kSessionIdName;
    [self setCookieWithProperties:properties];
}

#pragma mark - private

- (id)getCookieWithProperties:(NSDictionary *)properties {

    NSString *URLString = properties[@"url"];
    
    NSString *domain = properties[@"domain"];
    NSString *path   = properties[@"path"] ?: @"/";
    NSString *name   = properties[@"name"] ?: @"";
    
    if (!domain && !URLString) {
        return nil;
    }
    
    NSArray *cookies;
    if (URLString) {
        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:URLString]];
    }
    else {
        cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    }
    for (NSHTTPCookie *cookie in cookies) {
        
        if (domain && ![cookie.domain isEqualToString:domain]) {
            continue;
        }
        if ([cookie.path isEqualToString:path] && [cookie.name isEqualToString:name]) {
            return cookie.properties;
        }
    }
    return nil;
}

- (void)setCookieWithProperties:(NSDictionary *)properties {

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    cookieProperties[NSHTTPCookieDomain]     = properties[@"domain"]  ?: @"";
    cookieProperties[NSHTTPCookiePath]       = properties[@"path"]    ?: @"/";
    cookieProperties[NSHTTPCookieVersion]    = properties[@"version"] ?: @"0";
    cookieProperties[NSHTTPCookieMaximumAge] = properties[@"maxAge"]  ?: @"6000";
    cookieProperties[NSHTTPCookieName]       = properties[@"name"]    ?: @"";
    cookieProperties[NSHTTPCookieValue]      = properties[@"value"]   ?: @"";
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

@end
