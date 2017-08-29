//
//  SummerUpgrade.m
//  SummerExample
//
//  Created by Chenly on 16/6/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerUpgrade.h"
#import "CDVPlugin+Summer.h"
#import "EMMW3FolderManager.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@implementation SummerUpgrade

- (void)upgradeApp:(CDVInvokedUrlCommand *)command {
    
    NSMutableDictionary *params = [command argumentAtIndex:0];
    NSURL *URL = [NSURL URLWithString:params[@"url"]];
    if([[UIApplication sharedApplication] canOpenURL:URL]){
        [[UIApplication sharedApplication] openURL:URL];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"错误的 URL：%@", params[@"url"]];
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)upgrade:(CDVInvokedUrlCommand *)command {
    
    NSMutableDictionary *params = [command argumentAtIndex:0];
    NSArray *versions = params[@"url"];
    
    if (versions.count == 0) {
        return;
    }
    
    // 显示加载框
    BOOL showProgress = [params[@"showProgress"] boolValue];
    if (showProgress) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:NO];
        hud.detailsLabel.text = @"应用更新中...";
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    queue.suspended = YES;
    for (NSDictionary *versionInfo in versions) {
        __block BOOL stop;
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            if (stop) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 发生错误
                    [queue cancelAllOperations];
                    if (showProgress) {
                        [MBProgressHUD hideHUDForView:self.viewController.view animated:NO];
                    }
                });
                return;
            }
            [self upgrade:command version:versionInfo stop:&stop];
        }];
        if (versionInfo == versions.lastObject) {
            // 移除加载框
            [operation setCompletionBlock:^{
                if (showProgress) {
                    [MBProgressHUD hideHUDForView:self.viewController.view animated:NO];
                }
                id message = @{
                               @"percent": @(100),
                               @"isfinish": @(YES),
                               };
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }];
        }
        [queue addOperation:operation];
    }
    queue.suspended = NO;
}

- (void)upgrade:(CDVInvokedUrlCommand *)command version:(NSDictionary *)versionInfo stop:(BOOL *)stop {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSString *url = versionInfo[@"url"];
    NSString *versionCode = versionInfo[@"versionCode"];
    NSString *versionName = versionInfo[@"versionName"];
    BOOL incremental = [versionInfo[@"isIncremental"] boolValue];
    
    if (url) {
        [[EMMW3FolderManager sharedInstance] downloadW3FolderWithURL:url key:kMainW3FolderKey version:versionCode versionName:versionName incremental:incremental progress:^(NSProgress *downloadProgress) {
            
            static BOOL resting = NO;
            
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
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
                    [pluginResult setKeepCallbackAsBool:YES];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                });
                resting = YES;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    resting = NO;
                });
            }
            
        } completion:^(BOOL success, id result) {
            
            *stop = success;
            if(!success) {
                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:result];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            dispatch_semaphore_signal(semaphore);
        }];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
