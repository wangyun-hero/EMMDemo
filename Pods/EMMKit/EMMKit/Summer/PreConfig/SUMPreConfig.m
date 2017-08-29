//
//  SUMPreConfig.m
//  SummerDemo
//
//  Created by Chenly on 16/8/1.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMPreConfig.h"

@implementation SUMPreConfig

static NSString * const kConfigFileName = @"www/config.json";

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SUMPreConfig *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SUMPreConfig alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 默认设置
        self.statusBarStyle = nil;
        self.navigationBarHidden = YES;
        self.statusBarHidden = NO;
        self.isFullScreenLayout = NO;
        self.supportedOrientation = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;

        // 全局配置文件设置
        NSString *filePath = [[NSBundle mainBundle] pathForResource:kConfigFileName ofType:nil];
        if (filePath) {
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSDictionary *config = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            // statusbarstyle
            self.statusBarStyle = config[@"statusBarStyle"];
            // navigationbarhidden
            if (config[@"navigationBarHidden"]) {
                self.navigationBarHidden = [config[@"navigationBarHidden"] boolValue];
            }
            // statusBarAppearance
            if (config[@"statusBarAppearance"]) {
                self.statusBarHidden = ![config[@"statusBarAppearance"] boolValue];
            }
            // isFullScreenLayout
            if (config[@"fullScreen"]) {
                self.isFullScreenLayout = [config[@"fullScreen"] boolValue];
            }
            // orientation
            NSString *orientation = config[@"orientation"];
            if (orientation) {
                if ([orientation isEqualToString:@"portrait"]) {
                    self.supportedOrientation = UIInterfaceOrientationMaskPortrait;
                }
                else if ([orientation isEqualToString:@"landscape"]) {
                    self.supportedOrientation = UIInterfaceOrientationMaskLandscape;
                }
                else {
                    self.supportedOrientation = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
                }
            }
        }
    }
    return self;
}

@end
