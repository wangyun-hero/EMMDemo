//
//  UINavigationController+SUMTopBarStyle.m
//  SummerDemo
//
//  Created by Chenly on 16/9/13.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "UINavigationController+SUMTopBarStyle.h"
#import "SUMWindowViewController.h"

#import <Aspects/Aspects.h>

@implementation UINavigationController (SUMTopBarStyle)

+ (void)load {
    [self aspect_hookSelector:@selector(supportedInterfaceOrientations) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UINavigationController *instance = aspectInfo.instance;
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        
        // UINavigationController 的当前 ViewController 为 Summer 时，SUMViewController 支持的屏幕方向
        UIViewController *currentViewController = instance.topViewController;
        if ([currentViewController isKindOfClass:[SUMWindowViewController class]]) {
            
            UIInterfaceOrientationMask orientation = [currentViewController supportedInterfaceOrientations];
            [invocation setReturnValue:&orientation];
        }
    } error:NULL];
    
    [self aspect_hookSelector:@selector(preferredStatusBarStyle) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        
        UINavigationController *instance = aspectInfo.instance;
        NSInvocation *invocation = aspectInfo.originalInvocation;
        [invocation invoke];
        
        UIViewController *currentViewController = instance.topViewController;
        if ([currentViewController isKindOfClass:[SUMWindowViewController class]]) {
            UIStatusBarStyle preferredStatusBarStyle = [currentViewController preferredStatusBarStyle];
            [invocation setReturnValue:&preferredStatusBarStyle];
        }
    } error:NULL];
}

@end
