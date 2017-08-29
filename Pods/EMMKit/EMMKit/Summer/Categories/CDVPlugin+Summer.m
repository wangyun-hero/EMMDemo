//
//  CDVPlugin+Summer.m
//  SummerExample
//
//  Created by Chenly on 16/6/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "CDVPlugin+Summer.h"

@implementation CDVPlugin (Summer)

- (void)summer_sendResultOK:(NSString *)message withCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)summer_sendResultError:(NSString *)message withCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
