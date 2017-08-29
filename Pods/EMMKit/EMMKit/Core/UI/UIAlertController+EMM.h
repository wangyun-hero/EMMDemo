//
//  UIAlertController+EMM.h
//  CloudHR
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertController+Window.h"

@class UIAlertAction;

@interface UIAlertController (EMM)

@property (nonatomic, copy) void (^handler)(UIAlertAction *action, NSUInteger buttonIndex);

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(UIAlertControllerStyle)preferredStyle
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                       otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitle:(NSString *)otherButtonTitle
                   handler:(void (^)(UIAlertAction *, NSUInteger))handler;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
