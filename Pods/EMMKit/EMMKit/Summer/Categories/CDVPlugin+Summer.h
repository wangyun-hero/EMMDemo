//
//  CDVPlugin+Summer.h
//  SummerExample
//
//  Created by Chenly on 16/6/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Cordova/CDVPlugin.h>

@interface CDVPlugin (Summer)

- (void)summer_sendResultOK:(NSString *)message withCommand:(CDVInvokedUrlCommand *)command;
- (void)summer_sendResultError:(NSString *)message withCommand:(CDVInvokedUrlCommand *)command;

@end
