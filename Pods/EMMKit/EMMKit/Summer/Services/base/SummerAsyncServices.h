//
//  SummerServices.h
//  SummerExample
//
//  Created by Chenly on 16/6/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Cordova/CDVPlugin.h>

/**
 *  异步调用服务，通过回调返回值
 */
@interface SummerAsyncServices : CDVPlugin

- (void)call:(CDVInvokedUrlCommand *)command;

@end
