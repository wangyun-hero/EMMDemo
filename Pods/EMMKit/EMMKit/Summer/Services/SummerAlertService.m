//
//  SummerAlertService.m
//  EMMKitDemo
//
//  Created by Chenly on 16/8/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerAlertService.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SummerInvocation.h"

@implementation SummerAlertService

+ (void)load {
    if (self == [SummerAlertService self]) {
        [SummerServices registerService:@"UMJS" class:NSStringFromClass(self)];    // 弹出框或是加载框
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerAlertService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerAlertService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

- (void)showLoadingBar:(SummerInvocation *)invocation {
    
    NSString *title = invocation.params[@"title"];
    UIViewController *viewController = invocation.sender;
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    HUD.label.text = title;
}

- (void)hideLoadingBar:(SummerInvocation *)invocation {
    
    UIViewController *viewController = invocation.sender;
    [MBProgressHUD hideHUDForView:viewController.view animated:YES];
}

@end
