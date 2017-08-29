//
//  UINavigationController+Extension.h
//  EMMKitDemo
//
//  Created by zm on 16/9/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Extension)
// 自定义没有返回文字的back
- (void)initNavBarBackBtnWithSystemStyle;
// 自定义nav右边按钮
- (void)initNavRightBtnWithImage:(NSString *)image targer:(id)targer action:(SEL)action;
@end
