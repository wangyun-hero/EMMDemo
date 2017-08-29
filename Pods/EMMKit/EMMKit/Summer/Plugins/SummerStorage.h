//
//  SummerStorage.h
//  SummerExample
//
//  Created by Chenly on 16/6/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Cordova/CDVPlugin.h>

@interface SummerStorage : CDVPlugin

- (void)writeLocalStorage:(CDVInvokedUrlCommand *)command;
- (void)getLocalStorage:(CDVInvokedUrlCommand *)command;

@end
