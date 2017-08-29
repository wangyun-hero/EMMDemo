//
//  SummerUpgrade.h
//  SummerExample
//
//  Created by Chenly on 16/6/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Cordova/CDVPlugin.h>

@interface SummerUpgrade : CDVPlugin

/**
 *  App 更新
 */
- (void)upgradeApp:(CDVInvokedUrlCommand *)command;

/**
 *  www 更新
 */
- (void)upgrade:(CDVInvokedUrlCommand *)command;

@end
