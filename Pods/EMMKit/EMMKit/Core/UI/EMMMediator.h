//
//  EMMMediator.h
//  EMMKitDemo
//
//  Created by Chenly on 16/6/28.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  ViewController 中介，通过配置生成对应 ViewController 的实例。
 */
@interface EMMMediator : NSObject

+ (NSDictionary *)applicationsConfig;
+ (UIViewController *)loginViewControllerBySetting;
+ (UIViewController *)instanceWithClassName:(NSString *)className type:(NSString *)type config:(id)config;

// 跳转到登录页
+ (void)segueToLoginViewController;

@end
