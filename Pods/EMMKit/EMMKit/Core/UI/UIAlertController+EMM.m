//
//  UIAlertController+EMM.m
//  CloudHR
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "UIAlertController+EMM.h"
#import <objc/runtime.h>

@implementation UIAlertController (EMM)

- (void)setHandler:(void (^)(UIAlertAction *, NSUInteger))handler {
    objc_setAssociatedObject(self, @selector(handler), handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UIAlertAction *, NSUInteger))handler {
    return objc_getAssociatedObject(self, @selector(handler));
}

- (void)handleAction:(UIAlertAction *)action buttonIndex:(NSUInteger)buttonIndex {

    if (self.handler) {
        self.handler(action, buttonIndex);
    }
}

+ (instancetype)alertControllerWithTitle:(NSString *)title
                                 message:(NSString *)message
                          preferredStyle:(UIAlertControllerStyle)preferredStyle
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                       otherButtonTitles:(NSString *)otherButtonTitles, ... {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    if(cancelButtonTitle) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [alertController handleAction:action buttonIndex:0];
        }];
        [alertController addAction:alertAction];
    }
    
    va_list args;
    va_start(args, otherButtonTitles);
    
    NSUInteger buttonIndex = 1;
    for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString*)) {
        
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [alertController handleAction:action buttonIndex:buttonIndex];
        }];
        [alertController addAction:alertAction];
        buttonIndex ++;
    }
    va_end(args);
    
    return alertController;
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
          otherButtonTitle:(NSString *)otherButtonTitle
                   handler:(void (^)(UIAlertAction *, NSUInteger))handler {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert
                                                                   cancelButtonTitle:cancelButtonTitle
                                                                   otherButtonTitles:otherButtonTitle, nil];
    alertController.handler = handler;
    [alertController show:YES];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title message:message cancelButtonTitle:@"知道了" otherButtonTitle:nil handler:nil];
}

@end
