//
//  SummerNetService.m
//  SummerDemo
//
//  Created by Chenly on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerNetService.h"
#import "Reachability.h"
#import "SummerInvocation.h"
#import <AFNetworking/AFNetworking.h>
#import "EMMApplicationContext.h"
#import "SummerWebServiceHandle.h"
#import "EMMStorage.h"

@implementation SummerNetService

+ (void)load {    
    if (self == [SummerNetService self]) {
        [SummerServices registerService:@"UMService" class:@"SummerNetService"];    // 网络请求
        [SummerServices registerService:@"UMNetwork" class:@"SummerNetService"];    // 网络状态
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerNetService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerNetService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

- (id)getNetworkInfo:(SummerInvocation *)invocation {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    id result;
    switch (reachability.currentReachabilityStatus) {
        case NotReachable:
            result = @(NO);
            break;
        case ReachableViaWiFi:
            result = @{@"Type": @"Wifi"};
            break;
        case ReachableViaWWAN:
            result = @{@"Type": @"Mobile"};
            break;
        default:
            break;
    }
    result = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    return result;
}

- (id)isAvailable:(SummerInvocation *)invocation {

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    id result = [NSNumber numberWithBool:reachability.currentReachabilityStatus];    
    return result;
}

#pragma mark - 网络请求

- (void)get:(SummerInvocation *)invocation {

    [self request:invocation withHTTPMethod:@"GET"];
}

- (void)post:(SummerInvocation *)invocation {

    [self request:invocation withHTTPMethod:@"POST"];
}

- (void)request:(SummerInvocation *)invocation withHTTPMethod:(NSString *)HTTPMethod {

    NSString *urlString = invocation.params[@"url"];
    NSDictionary *headers = invocation.params[@"header"];
    NSString *timeout = invocation.params[@"timeout"];
    id data = invocation.params[@"data"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:timeout.integerValue];
    request.HTTPMethod = HTTPMethod;
    id HTTPBody;
    if ([data isKindOfClass:[NSDictionary class]]) {
        HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    }
    else if ([data isKindOfClass:[NSString class]]) {
        HTTPBody = [(NSString *)data dataUsingEncoding:NSUTF8StringEncoding];
    }
    request.HTTPBody = HTTPBody;
    if ([headers isKindOfClass:[NSDictionary class]]) {
        [request setAllHTTPHeaderFields:headers];
    }
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [invocation callbackWithObject:@{@"error": error.localizedDescription}];
        } else {
            NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            [invocation callbackWithObject:responseString];
        }
    }];
    [dataTask resume];
}

#pragma mark - Config

- (void)writeConfigure:(SummerInvocation *)invocation {
    
    [invocation.params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [[EMMStorage sharedInstance] setValue:obj forKey:key toLocation:EMMStorageLocationConfigure];
    }];
}

- (id)readConfigure:(SummerInvocation *)invocation {
    
    NSString *key = [invocation.params allValues].firstObject;
    id result = [[EMMStorage sharedInstance] valueForKey:key fromLocation:EMMStorageLocationConfigure];;
    [invocation callbackWithObject:result resultType:SummerInvocationResultTypeString];
    return result;
}

- (void)login:(SummerInvocation *)invocation {
    
    [[SummerWebServiceHandle sharedInstance] loginMaWebServiceHandle:invocation completionHandler:^(id result, BOOL succeed) {
        
        NSString *errorMessage = nil;
        if (succeed) {
            NSString *code = result[@"code"];
            if (code && [code isEqualToString:@"1"]) {
                id obj = result[@"resultctx"] ?: result;
                [invocation callbackWithObject:obj resultType:SummerInvocationResultTypeOriginal];
                return;
            }
            else {
                errorMessage = result[@"msg"];
            }
        }
        else {
            errorMessage = @"网络请求异常，请检查。";
        }
        [invocation callbackWithObject:@{@"err_msg": errorMessage ?: @""} resultType:SummerInvocationResultTypeErrorOriginal];
    }];
}

- (void)callAction:(SummerInvocation *)invocation {
    
    [[SummerWebServiceHandle sharedInstance] callActionHandle:invocation completionHandler:^(id result, BOOL succeed) {
        
        NSString *errorMessage = nil;
        if (succeed) {
            NSString *code = result[@"code"];
            if (code && [code isEqualToString:@"1"]) {
                if (!result[@"serviceid"]) {
                    NSMutableDictionary *tempResult = [result mutableCopy];
                    tempResult[@"serviceid"] = @"umCommonService";
                    result = [tempResult copy];
                }
                id obj = result[@"resultctx"] ?: result;
                [invocation callbackWithObject:obj resultType:SummerInvocationResultTypeOriginal];
                return;
            }
            else {
                errorMessage = result[@"msg"];
            }
        }
        else {
            errorMessage = @"网络请求异常，请检查。";
        }
        [invocation callbackWithObject:@{@"err_msg": errorMessage ?: @""} resultType:SummerInvocationResultTypeErrorOriginal];
    }];
}

#pragma mark - 本地通知

- (void)localNotification:(SummerInvocation *)invocation {

    NSString *sendBody = invocation.params[@"sendBody"];
    NSString *sendTime = invocation.params[@"sendTime"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertTitle = @"提醒服务";
    localNotification.alertBody = sendBody;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.fireDate = [df dateFromString:sendTime];
    localNotification.userInfo = @{@"type": @"summerService"};
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
