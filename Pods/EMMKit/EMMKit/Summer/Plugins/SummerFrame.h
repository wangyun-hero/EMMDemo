//
//  SUMFrame.h
//  SummerExample
//
//  Created by Chenly on 16/6/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Cordova/CDVPlugin.h>

@interface SummerFrame : CDVPlugin

- (void)openFrame:(CDVInvokedUrlCommand *)command;
- (void)closeFrame:(CDVInvokedUrlCommand *)command;
- (void)bringFrameToFront:(CDVInvokedUrlCommand *)command;

- (void)openFrameGroup:(CDVInvokedUrlCommand *)command;
- (void)closeFrameGroup:(CDVInvokedUrlCommand *)command;
- (void)setFrameGroupAttr:(CDVInvokedUrlCommand *)command;

- (void)openWin:(CDVInvokedUrlCommand *)command;
- (void)closeWindow:(CDVInvokedUrlCommand *)command;
- (void)closeToWin:(CDVInvokedUrlCommand *)command;

- (void)setFrameAttr:(CDVInvokedUrlCommand *)command;

- (void)setRefreshHeaderInfo:(CDVInvokedUrlCommand *)command;
- (void)refreshHeaderLoadDone:(CDVInvokedUrlCommand *)command;
- (void)setRefreshFooterInfo:(CDVInvokedUrlCommand *)command;
- (void)refreshFooterLoadDone:(CDVInvokedUrlCommand *)command;

- (void)winParam:(CDVInvokedUrlCommand *)command;
- (void)frameParam:(CDVInvokedUrlCommand *)command;

- (void)execScript:(CDVInvokedUrlCommand *)command;

@end
