//
//  SUMEMMService.m
//  SummerDemo
//
//  Created by Chenly on 2017/2/8.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import "SUMEMMService.h"
#import "SummerInvocation.h"
#import "EMMDataAccessor.h"
#import "EMMApplicationContext.h"
#import "EMMDeviceInfo.h"
#import "UIAlertController+EMM.h"
#import "EMMW3FolderManager.h"
#import "SUMWindowViewController.h"
#import "SUMFrameViewController.h"
#import "SUMViewController.h"
#import "EMMAppsManager.h"

#define Net_Error_Callback id returnValue = @{\
@"message": @"网络连接失败"\
};\
[invocation callbackWithObject:returnValue resultType:SummerInvocationResultTypeErrorOriginal];\

#define UnLogined_Error_Callback id returnValue = @{\
@"message": @"未登录"\
};\
[invocation callbackWithObject:returnValue resultType:SummerInvocationResultTypeErrorOriginal];\

@interface SUMEMMService ()

@property (nonatomic, copy) NSArray *apps;
@property (nonatomic, copy) NSArray *localApps;

@end

@implementation SUMEMMService

+ (void)load {
    if (self == [SUMEMMService self]) {
        [SummerServices registerService:@"UMEMMService" class:NSStringFromClass(self)];
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SUMEMMService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SUMEMMService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

- (void)writeConfig:(SummerInvocation *)invocation {

    NSString *host = invocation.params[@"host"];
    NSString *port = invocation.params[@"port"];
    
    [[EMMApplicationContext defaultContext] setObject:host forKey:@"emm_host"];
    [[EMMApplicationContext defaultContext] setObject:port forKey:@"emm_port"];
}

- (void)autofind:(SummerInvocation *)invocation {
    NSString *companyId = invocation.params[@"companyId"] ?: @"";
    NSDictionary *params = @{ @"companyID": companyId };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"autofind"];

    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        if (result && [result[@"success"] boolValue]) {
            NSData *data = [result[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *agentURL = jsonObject[@"config_agent_url"];
            [[EMMApplicationContext defaultContext] setObject:agentURL forKey:@"url_agent"];
        }
        [invocation callbackWithObject:result];
        
    } failure:^(NSError *error) {
        Net_Error_Callback;
    }];
}

- (void)registerDevice:(SummerInvocation *)invocation {
    
    NSString *username  = invocation.params[@"username"]  ?: @"";
    NSString *password  = invocation.params[@"password"]  ?: @"";
    NSString *companyId = invocation.params[@"companyId"] ?: @"";
    [[EMMApplicationContext defaultContext] setObject:companyId forKey:@"emm_companyid"];
    
    NSDictionary *params = @{
                             @"username": username,
                             @"password": password,
                             @"companyId": companyId,
                             };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"register"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {

        if (result) {
            int code =  [result[@"data"][@"code"] intValue];
            if (code == 1) {
                [[EMMApplicationContext defaultContext] setObject:username forKey:@"username"];
            }
            else {
                int status = [result[@"data"][@"status"] intValue];
                if (status == 1) {
                    // 设备没有证书，下载证书
                    [UIAlertController showAlertWithTitle:@"提示" message:@"未安装 MDM 证书" cancelButtonTitle:@"取消" otherButtonTitle:@"安装" handler:^(UIAlertAction *action, NSUInteger idx) {
                        
                        if (idx == 1) {
                            NSString *host = [[EMMApplicationContext defaultContext] objectForKey:@"emm_host"];
                            NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
                            NSString *url = [NSString stringWithFormat:@"https://%@/mobem/html/ca.jsp?serialnumber=%@", host, UUID];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                        }
                    }];
                    return;
                }
            }
        }
        [invocation callbackWithObject:result];
        
    } failure:^(NSError *error) {
        Net_Error_Callback;
    }];
}

- (void)login:(SummerInvocation *)invocation {
    
    NSString *username = invocation.params[@"username"];
    NSString *password = invocation.params[@"password"];
    NSDictionary *params = @{
                             @"username": username,
                             @"password": password
                             };
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"login"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {

        if (result) {
            int code = [result[@"data"][@"code"] intValue];
            if (code == 1) {
                // 登录成功
                [[EMMApplicationContext defaultContext] setObject:username forKey:@"username"];
                [[EMMApplicationContext defaultContext] setObject:password forKey:@"password"];
            }
        }
        [invocation callbackWithObject:result];
        
    } failure:^(NSError *error) {
        Net_Error_Callback;
    }];
}

- (void)logout:(SummerInvocation *)invocation {
    
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSString *password = [[EMMApplicationContext defaultContext] objectForKey:@"password"];
    NSDictionary *parameters = @{
                                 @"username": username,
                                 @"password": password
                                 };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"logout"];
    [dataAccessor sendRequestWithParams:parameters success:^(id result) {
        
        [invocation callbackWithObject:result];
        
    } failure:^(NSError *error) {
        Net_Error_Callback;
    }];
}

- (void)getApps:(SummerInvocation *)invocation {
    
    [[EMMAppsManager sharedInstance] fetchApps:^(NSArray *apps, NSError *error) {
        
        if (error) {
            [invocation callbackWithObject:error.description resultType:SummerInvocationResultTypeErrorOriginal];
        }
        else {
            [invocation callbackWithObject:apps];
        }
    }];
}

- (void)getDocs:(SummerInvocation *)invocation {
    
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    if (!username) {
        UnLogined_Error_Callback;
        return;
    }
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.document" request:@"getDocuments"];
    [dataAccessor sendRequestWithParams:@{ @"username": username } success:^(id result) {
        
        [invocation callbackWithObject:result];
        
    } failure:^(NSError *error) {
        Net_Error_Callback;
    }];
}

- (void)getUserInfo:(SummerInvocation *)invocation {
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    if (!username) {
        UnLogined_Error_Callback;
        return;
    }
    
    NSDictionary *params = @{ @"username": username };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"getUserInfo"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [invocation callbackWithObject:result];
        
    } failure:^(NSError *error) {
        Net_Error_Callback;
    }];
}

- (void)getAppList:(SummerInvocation *)invocation {
    
    [[EMMAppsManager sharedInstance] fetchApps:^(NSArray *apps, NSError *error) {
        
        if (error) {
            [invocation callbackWithObject:error.description resultType:SummerInvocationResultTypeErrorOriginal];
        }
        else {
            [invocation callbackWithObject:apps];
        }
    }];
}

- (void)getLocalAppList:(SummerInvocation *)invocation {

    NSArray *apps = [EMMAppsManager sharedInstance].localApps;
    [invocation callbackWithObject:apps];
}

- (void)installWebApp:(SummerInvocation *)invocation {

    NSString *appid = invocation.params[@"appid"];
    if (appid.length == 0) {
        return;
    }
    
    __block BOOL resting = NO;
    [[EMMAppsManager sharedInstance] installAppWithId:appid progress:^(NSProgress *downloadProgress) {
        
        NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
        float completed = downloadProgress.completedUnitCount;
        float total = downloadProgress.totalUnitCount;
        if (resting && completed < total) {
            return;
        }
        else {
            message[@"isfinish"] = @(NO);
            message[@"fileSize"] = @(total);
            message[@"percent"] = @(completed * 100 / total);
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:message resultType:SummerInvocationResultTypeOriginal];
            });
            resting = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resting = NO;
            });
        }
        
    } completion:^(BOOL success, id result) {
        
        if(success) {
            id message = @{
                           @"appid": appid,
                           @"isfinish": @(YES),
                           };
            [invocation callbackWithObject:message resultType:SummerInvocationResultTypeOriginal];
        }
        else {
            id message = @{
                           @"appid": appid,
                           @"message": result
                           };
            [invocation callbackWithObject:message resultType:SummerInvocationResultTypeErrorOriginal];
        }
    }];
}

- (void)upgradeWebApp:(SummerInvocation *)invocation {
    
    NSString *appid = invocation.params[@"appid"];
    if (appid.length == 0) {
        return;
    }
    
    __block BOOL resting = NO;
    [[EMMAppsManager sharedInstance] upgradeAppWithId:appid progress:^(NSProgress *downloadProgress) {
        
        NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
        float completed = downloadProgress.completedUnitCount;
        float total = downloadProgress.totalUnitCount;
        if (resting && completed < total) {
            return;
        }
        else {
            message[@"isfinish"] = @(NO);
            message[@"fileSize"] = @(total);
            message[@"percent"] = @(completed * 100 / total);
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:message];
            });
            resting = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resting = NO;
            });
        }
        
    } completion:^(BOOL success, id result) {
        
        if(success) {
            id message = @{
                           @"appid": appid,
                           @"isfinish": @(YES),
                           };
            [invocation callbackWithObject:message];
        }
        else {
            id message = @{
                           @"appid": appid,
                           @"message": result
                           };
            [invocation callbackWithObject:message resultType:SummerInvocationResultTypeErrorOriginal];
        }
    }];
}

- (void)openWebApp:(SummerInvocation *)invocation {
    
    NSString *appid = invocation.params[@"appid"];
    if (appid.length == 0) {
        return;
    }
    SUMViewController *currentVC = invocation.sender;
    if ([currentVC isKindOfClass:[SUMFrameViewController class]]) {
        currentVC = ((SUMFrameViewController *)currentVC).window;
    }
    
    SUMWindowViewController *toViewController = [[SUMWindowViewController alloc] init];

    id result = [[EMMAppsManager sharedInstance] paramsForLaunchingAppWithId:appid];
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *params = result;
        toViewController.wwwFolderName = params[@"wwwFolderName"];
        toViewController.startPage = params[@"startPage"];
        toViewController.configFile = params[@"configFile"];
        [currentVC.navigationController pushViewController:toViewController animated:YES];
    }
    else {
        result = @{
                   @"appid": appid,
                   @"message": result
                   };
        [invocation callbackWithObject:result resultType:SummerInvocationResultTypeErrorOriginal];
    }
}

- (void)removeWebApp:(SummerInvocation *)invocation {

    NSString *appid = invocation.params[@"appid"];
    if (appid.length == 0) {
        return;
    }
    
    NSError *error;
    if ([[EMMAppsManager sharedInstance] uninstallAppWithId:appid error:&error]) {
        [invocation callbackWithObject:appid];
    }
    else {
        NSString *errorMessage = error.domain;
        id result = @{
                      @"appid": appid,
                      @"message": errorMessage
                      };
        [invocation callbackWithObject:result resultType:SummerInvocationResultTypeErrorOriginal];
    }
}

- (void)modifyPassword:(SummerInvocation *)invocation {}
- (void)modifyAvatar:(SummerInvocation *)invocation {}
- (void)feedback:(SummerInvocation *)invocation {}
- (void)startStrategy:(SummerInvocation *)invocation {}
- (void)stopStrategy:(SummerInvocation *)invocation {}

@end
