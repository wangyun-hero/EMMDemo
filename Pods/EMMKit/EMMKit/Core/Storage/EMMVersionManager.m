//
//  EMMVersionManager.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMVersionManager.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "AFNetworking.h"

@implementation EMMVersionManager

static NSString * const kAppID = @"com.cscec3.mdmpush";

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EMMVersionManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMVersionManager alloc] init];
    });
    return sSharedInstance;
}

- (NSString *)version {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (void)checkVersion {
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.version" request:@"getVersionInfo"];
    [dataAccessor sendRequestWithParams:@{@"appid": kAppID} success:^(id result) {
        
        if (result) {
            NSString *code = [result valueForKeyPath:@"result.code"];
            if (![code isEqualToString:@"0"]) {
                return;
            }
            NSString *version = [result valueForKeyPath:@"data.appdetail.iosversion"];
            if ([version compare:self.version] == NSOrderedDescending) {
                // 有更新
                NSString *message = [NSString stringWithFormat:@"当前版本：%@\n 升级版本：%@", self.version, version];
                [UIAlertController showAlertWithTitle:@"有新版本" message:message cancelButtonTitle:@"知道了" otherButtonTitle:@"升级" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    
                    if (buttonIndex == 1) {
                        
                        NSString *downloadURL = [result valueForKeyPath:@"data.appdetail.iosurl"];
                        NSURL *url = [NSURL URLWithString:downloadURL];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }
                }];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"获取版本信息失败：%@", error.localizedDescription);
    }];
}

- (void)checkVersionInAppStore {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleId = infoDictionary[@"CFBundleIdentifier"];
    NSString *currentVersion = infoDictionary[@"CFBundleShortVersionString"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?bundleId=%@", bundleId];
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        BOOL resultCount = [responseObject[@"resultCount"] boolValue];
        if (resultCount == 0) {
            // 没找到该 APP
            return;
        }
        
        NSDictionary *appInfo = responseObject[@"results"][0];
        NSString *lastVersion = appInfo[@"version"];
        
        if ([lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
            
            NSString *title = [NSString stringWithFormat:@"新版本 %@", lastVersion];
            NSString *description = appInfo[@"releaseNotes"];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:description preferredStyle:UIAlertControllerStyleAlert cancelButtonTitle:nil otherButtonTitles:@"稍后", @"更新", nil];
            [alertController setHandler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                
                if (buttonIndex == 2) {
                    NSString *trackViewUrl = appInfo[@"trackViewUrl"];
                    NSURL *URL = [NSURL URLWithString:trackViewUrl];
                    if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                        [[UIApplication sharedApplication] openURL:URL];
                    }
                }
            }];
        }
    } failure:nil];
}

@end
