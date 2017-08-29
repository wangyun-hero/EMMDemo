//
//  EMMMediator.m
//  EMMKitDemo
//
//  Created by Chenly on 16/6/28.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMMediator.h"
#import "EMMProtocol.h"
#import "EMMAnimation.h"
#import "EMMLocationService.h"
#import "EMMVersionManager.h"
#import "EMMW3FolderManager.h"
#import "EMMDataAccessor.h"

typedef NS_OPTIONS(NSUInteger, EMMServiceTypes) {
    EMMServiceTypeNone = 0,
    EMMServiceTypeLocation = 1 << 0,
    EMMServiceTypeVersion = 1 << 1,
};

@implementation EMMMediator

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EMMMediator *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMMediator alloc] init];
    });
    return sSharedInstance;
}

+ (NSDictionary *)applicationsConfig {
    
    static dispatch_once_t onceToken;
    static NSDictionary *config;
    dispatch_once(&onceToken, ^{
        NSString *configFile = [[NSBundle mainBundle] pathForResource:@"application" ofType:@"json"];
        config = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:configFile] options:0 error:nil];
    });
    return config;
}

+ (UIViewController *)instanceWithClassName:(NSString *)className type:(NSString *)type config:(id)config {

    UIViewController *viewController;
    Class class = NSClassFromString(className);
    if ([class conformsToProtocol:@protocol(EMMConfigurable)]) {
        viewController = (UIViewController *)[(id<EMMConfigurable>)[class alloc] initWithConfig:config];
    }
    else {
        if ([type isEqualToString:@"web"]) {
            
            if (!class) {
                class = NSClassFromString(@"EMMWebViewController");
            }
            viewController = [[class alloc] init];
            if ([config isKindOfClass:[NSDictionary class]]) {
                
                NSString *wwwFolder = [[EMMW3FolderManager sharedInstance] absoluteW3FolderForKey:kMainW3FolderKey];
                [viewController setValue:wwwFolder forKey:@"wwwFolderName"];
            }
        }
        else {
            viewController = [[class alloc] init];
        }
    }
    
    NSAssert(viewController, @"EMMTabBar：未找到类 - %@", className);
    return viewController;
}

+ (UIViewController *)loginViewControllerBySetting {
    
    NSDictionary *config = [EMMMediator  applicationsConfig];
    
    // 获取配置文件中支持的服务（定位、版本升级等）
    NSArray *services = [[EMMDataAccessor getDefaultBundle] isEqualToString:kEMMDataAccessorBundleDemo] ? nil : config[@"services"];
    EMMServiceTypes serviceTypes = EMMServiceTypeNone;
    for (NSString *service in services) {
        
        if ([service isEqualToString:@"location"]) {
            serviceTypes = serviceTypes | EMMServiceTypeLocation;
        }
        else if ([service isEqualToString:@"version"]) {
            serviceTypes = serviceTypes | EMMServiceTypeVersion;
        }
    }

    NSDictionary *loginConfig = config[@"login"];
    UIViewController *loginVC = [EMMMediator instanceWithClassName:loginConfig[@"class"] type:loginConfig[@"type"] config:loginConfig[@"configs"]];
    
    if ([loginVC conformsToProtocol:@protocol(EMMLoginCompletion)]) {
        [(id<EMMLoginCompletion>)loginVC setCompletion:^(BOOL success, id result) {
            
            UIViewController<EMMConfigurable> *tabBarController = [[NSClassFromString(@"EMMTabBarController") alloc] initWithConfig:config];
            [EMMAnimation addAnimationToWindowWithduration:0.5 fromDirection:@"right" target:self];
            [UIApplication sharedApplication].keyWindow.rootViewController = tabBarController;
            
            if (serviceTypes & EMMServiceTypeLocation) {
                // 开启定位服务
                [[EMMLocationService sharedInstance] beginLocationService];
            }
            if (serviceTypes & EMMServiceTypeVersion) {
                // 开启版本升级
                [[EMMVersionManager sharedInstance] checkVersion];
            }
        }];
    }
    return loginVC;
}

+ (void)segueToLoginViewController {

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"logined"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[EMMLocationService sharedInstance] stopLocationService];
    UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
    [EMMAnimation addAnimationToWindowWithduration:0.3 fromDirection:@"left" target:self];
    [UIApplication sharedApplication].delegate.window.rootViewController = loginVC;
}

@end
