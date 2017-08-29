//
//  UINavigationController+Extension.m
//  EMMKitDemo
//
//  Created by zm on 16/9/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "UINavigationController+Extension.h"

@implementation UINavigationController (Extension)

- (void)initNavBarBackBtnWithSystemStyle
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.topViewController.navigationItem.backBarButtonItem = backItem;
    UIImage *backButtonImage = [[UIImage imageNamed:@"navigationItem_back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 18, 0, 10)];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)initNavRightBtnWithImage:(NSString *)image targer:(id)targer action:(SEL)action{
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [rightButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [rightButton addTarget:targer action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.topViewController.navigationItem.rightBarButtonItem = rightItem;
}

@end
