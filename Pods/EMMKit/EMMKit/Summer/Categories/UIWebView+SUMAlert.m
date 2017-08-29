//
//  UIWebView+SUMAlert.m
//  SummerDemo
//
//  Created by Chenly on 2016/10/18.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "UIWebView+SUMAlert.h"

@implementation UIWebView (SUMAlert)

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

@end
