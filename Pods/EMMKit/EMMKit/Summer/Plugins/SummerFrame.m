//
//  SUMFrame.m
//  SummerExample
//
//  Created by Chenly on 16/6/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerFrame.h"
#import "SUMWindowViewController.h"
#import "SUMFrameViewController.h"
#import "SUMGroupViewController.h"
#import "SUMAnimatedTransition.h"
#import "SUMFrameAnimation.h"
#import "SUMPreRender.h"
#import <FMDB/FMDB.h>

@interface SummerFrame () <SUMPreRenderDelegate>

@property (class, nonatomic, readonly) NSMutableDictionary *allWindows;
@property (nonatomic, strong) NSMutableDictionary *renderingWindows;
@property (nonatomic, strong) NSMutableDictionary *cachedWindows;

@end

@implementation SummerFrame

#pragma mark - CDVPlugin

- (void)pluginInitialize {
    [super pluginInitialize];
    
    if ([self.viewController isKindOfClass:[SUMWindowViewController class]]) {
        SUMWindowViewController *window = (SUMWindowViewController *)self.viewController;
        self.class.allWindows[window.sumId] = window;
    }
}

#pragma mark - getter & setter

- (NSMutableDictionary *)renderingWindows {
    if (!_renderingWindows) {
        _renderingWindows = [[NSMutableDictionary alloc] init];
    }
    return _renderingWindows;
}

- (NSMutableDictionary *)cachedWindows {
    if (!_cachedWindows) {
        _cachedWindows = [[NSMutableDictionary alloc] init];
    }
    return _cachedWindows;
}

static NSMutableDictionary *_allWindows;
+ (NSMutableDictionary *)allWindows {
    if (!_allWindows) {
        _allWindows = [[NSMutableDictionary alloc] init];
    }
    return _allWindows;
}

#pragma mark - Frame

- (void)openFrame:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *frameId = params[@"id"];        
    
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMFrameViewController *frame = [window frameWithId:frameId];
    if (frame) {
        [window openFrame:frame params:params opened:YES];
        return;
    }
    
    frame = [[SUMFrameViewController alloc] initWithSumId:frameId];
    [window openFrame:frame params:params opened:NO];
}

- (void)closeFrame:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *frameId = params[@"id"];
    
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMFrameViewController *frame = [window frameWithId:frameId];
    if (!frame) {
        return;
    }
    [frame.window closeFrame:frame];
}

- (void)bringFrameToFront:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *from = params[@"from"];
    NSString *to = params[@"to"];
    
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMFrameViewController *fromFrame = from ? [window frameWithId:from] : nil;
    if (!fromFrame) {
        return;
    }
    
    UIView *superView = fromFrame.view.superview;
    SUMFrameViewController *toFrame = to ? [window frameWithId:to] : nil;
    if (toFrame) {
        
        UIView *tempView = [[UIView alloc] init];
        tempView.hidden = YES;
        
        [superView sendSubviewToBack:fromFrame.view];
        [superView insertSubview:tempView aboveSubview:toFrame.view];
        NSUInteger toIndex = [superView.subviews indexOfObject:toFrame.view];
        [superView exchangeSubviewAtIndex:toIndex + 1 withSubviewAtIndex:0];
        
        [tempView removeFromSuperview];
    }
    else {
        [superView bringSubviewToFront:fromFrame.view];
    }
}

- (void)sendFrameToBack:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *from = params[@"from"];
    NSString *to = params[@"to"];
    
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMFrameViewController *fromFrame = from ? [window frameWithId:from] : nil;
    if (!fromFrame) {
        return;
    }
    
    UIView *superView = fromFrame.view.superview;
    SUMFrameViewController *toFrame = to ? [window frameWithId:to] : nil;
    if (toFrame) {
        UIView *tempView = [[UIView alloc] init];
        tempView.hidden = YES;
        
        [superView sendSubviewToBack:fromFrame.view];
        [superView insertSubview:tempView belowSubview:toFrame.view];
        NSUInteger toIndex = [superView.subviews indexOfObject:toFrame.view];
        [superView exchangeSubviewAtIndex:toIndex - 1 withSubviewAtIndex:0];
        
        [tempView removeFromSuperview];
    }
    else {
        // TODO: 会将 view 移到最底下，导致 frame 被遮盖。
        [superView sendSubviewToBack:fromFrame.view];
    }
}

#pragma mark - Group

- (void)openFrameGroup:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    
    NSString *groupId = params[@"id"];
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMGroupViewController *group = [window groupWithId:groupId];
    if (group) {
        [group.view.superview bringSubviewToFront:group.view];
        return;
    }
    
    NSArray *frameInfos = params[@"frames"];
    NSMutableArray *frames = [NSMutableArray array];
    for (NSDictionary *frameInfo in frameInfos) {
        
        NSString *startPage = frameInfo[@"url"];
        NSString *frameId = frameInfo[@"id"];
        SUMFrameViewController *frame = [[SUMFrameViewController alloc] initWithSumId:frameId];
        frame.wwwFolderName = window.wwwFolderName;
        frame.startPage = startPage;
        
        NSDictionary *pageParams = [params objectForKey:@"pageParam"];
        frame.pageParams = pageParams;
        
        NSDictionary *pageParam = params[@"pageParam"];
        if (pageParam.count > 0) {
            // 设置 pageParam
            frame.pageParams = pageParam;
        }
        [frames addObject:frame];
    }
    if (frames.count == 0) {
        return;
    }
    
    group = [[SUMGroupViewController alloc] initWithSumId:groupId frames:frames];
    [window openGroup:group params:params];
}

- (void)closeFrameGroup:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *groupId = params[@"id"];
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMGroupViewController *group = [window groupWithId:groupId];
    if (!group) {
        return;
    }
    [window closeGroup:group];
}

- (void)setFrameGroupAttr:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *groupId = params[@"id"];
    SUMWindowViewController *window = [self targetWithWindowId:nil frameId:nil];
    SUMGroupViewController *group = [window groupWithId:groupId];
    if (!group) {
        return;
    }
    [group setAttributes:params];
}

#pragma mark - Window

- (void)openWin:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowID = params[@"id"];
    NSString *startPage = params[@"url"];
    
    SUMWindowViewController *currentWindow = [self targetWithWindowId:nil frameId:nil];
    SUMWindowViewController *toWindow = [[SUMWindowViewController alloc] initWithSumId:windowID];
    toWindow.wwwFolderName = currentWindow.wwwFolderName;
    toWindow.startPage = startPage;
    
    NSDictionary *pageParams = [params objectForKey:@"pageParam"];
    toWindow.pageParams = pageParams;
    
    NSDictionary *attributes = [params dictionaryWithValuesForKeys:@[@"statusBarAppearance", @"statusBarStyle", @"fullScreen", @"screenOrientation", @"navigationBarAppearance"]];
    [toWindow setAttributes:attributes];
    
    BOOL animated = YES;
    NSDictionary *animation = params[@"animation"];
    if (animation) {
        toWindow.sum_transition = [SUMAnimatedTransition transitionWithInfo:animation operation:UINavigationControllerOperationPush completion:nil];
        
        if (toWindow.sum_transition && [toWindow.sum_transition.type isEqualToString:@"none"]) {
            animated = NO;
        }
    }
    UINavigationController *naviController = currentWindow.navigationController;
    [naviController pushViewController:toWindow animated:animated];
    
    BOOL isKeep = [((params[@"isKeep"] ?: params[@"iskeep"]) ?: @YES) boolValue];
    if (!isKeep) {
        NSMutableArray *childViewControllers = [naviController.childViewControllers mutableCopy];
        [childViewControllers removeObject:currentWindow];
        [naviController setViewControllers:childViewControllers];
    }
}

- (void)closeWindow:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowId = params[@"id"];
    SUMWindowViewController *window = (SUMWindowViewController *)[self targetWithWindowId:windowId frameId:nil];
    if (!window) {
        return;
    }
    
    NSMutableArray *childViewControllers = [window.navigationController.childViewControllers mutableCopy];
    if (childViewControllers.lastObject == window) {
        
        if (childViewControllers.count == 1) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeWin" object:nil];
            [window.navigationController dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        BOOL animated = YES;
        if (window.sum_transition && [window.sum_transition.type isEqualToString:@"none"]) {
            animated = NO;
        }
        NSMutableArray *sumWinControllers = [NSMutableArray new];
        [childViewControllers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[CDVViewController class]]){
                [sumWinControllers addObject:obj];
            }
        }];
        if(sumWinControllers.count == 1){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"closeWin" object:nil];
            [window.navigationController popViewControllerAnimated:animated];
            
        }
        else{
            [window.navigationController popViewControllerAnimated:animated];
        }
    }
    else {
        [childViewControllers removeObject:window];
        [window.navigationController setViewControllers:childViewControllers];
    }
    [self.class.allWindows removeObjectForKey:window.sumId];
}

- (void)closeToWin:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowId = params[@"id"];
    SUMWindowViewController *window = (SUMWindowViewController *)[self targetWithWindowId:windowId frameId:nil];
    if (!window) {
        return;
    }
    
    BOOL animated = YES;
    [window.navigationController popToViewController:window animated:animated];
}

- (void)createWin:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowId = params[@"id"];
    NSString *startPage = params[@"url"];
//    BOOL cached = [params[@"cached"] boolValue];
    BOOL cached = YES;
    if (cached) {
        SUMViewController *cache = self.cachedWindows[windowId];
        if (cache && [cache.startPage isEqualToString:startPage]) {
            return;
        }
    }
    
    SUMWindowViewController *currentWindow = [self targetWithWindowId:nil frameId:nil];
    SUMWindowViewController *toWindow = [[SUMWindowViewController alloc] initWithSumId:windowId];
    toWindow.wwwFolderName = currentWindow.wwwFolderName;
    toWindow.startPage = startPage;
    
    NSDictionary *pageParams = [params objectForKey:@"pageParam"];
    toWindow.pageParams = pageParams;
    
    NSDictionary *attributes = [params dictionaryWithValuesForKeys:@[@"statusBarAppearance", @"statusBarStyle", @"fullScreen", @"screenOrientation"]];
    [toWindow setAttributes:attributes];
    
    // toWindow.autoFinishRender = NO;
    self.renderingWindows[windowId] = toWindow;
    [[SUMPreRender sharedInstance] beginPreRenderingViewController:toWindow observer:self];
    
    if (cached) {
        self.cachedWindows[windowId] = toWindow;
    }
}

- (void)showWin:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowId = params[@"id"];
    SUMWindowViewController *window = self.renderingWindows[windowId];
    if (window) {
        [[SUMPreRender sharedInstance] finishPreRenderingViewController:window];
    }
    else {
        window = self.cachedWindows[windowId];
        if (window) {
            UIViewController *currentWindow = [self targetWithWindowId:nil frameId:nil];
            [currentWindow.navigationController pushViewController:window animated:YES];
        }
    }
}

#pragma mark - <SUMPreRenderDelegate>

- (void)preRender:(SUMPreRender *)preRender didViewControllerFinishedRender:(UIViewController *)viewController {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SUMWindowViewController *window = (SUMWindowViewController *)viewController;
        [self.renderingWindows removeObjectForKey:window.sumId];
        UIViewController *currentWindow = [self targetWithWindowId:nil frameId:nil];
        [currentWindow.navigationController pushViewController:window animated:YES];
    });
}

#pragma mark - Attributes

// iOS 单独新增以实现动态改变状态栏背景色
- (void)setWinAttr:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowId = params[@"id"];
    SUMWindowViewController *window = [self targetWithWindowId:windowId frameId:nil];
    [window setAttributes:params];
}

- (void)setFrameAttr:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *frameId = params[@"id"];
    
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    SUMWindowViewController *window;
    if ([viewController isKindOfClass:[SUMWindowViewController class]]) {
        
        window = (SUMWindowViewController *)viewController;
    }
    else if ([viewController isKindOfClass:[SUMFrameViewController class]]) {
        
        window = ((SUMFrameViewController *)viewController).window;
    }
    SUMFrameViewController *frame = [window frameWithId:frameId];
    if (!frame) {
        return;
    }
    [frame setAttributes:params];
}

#pragma mark - MJRefresh

- (void)setRefreshHeaderInfo:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    BOOL autoRefresh = [params[@"autoRefresh"] boolValue];
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    
    viewController.webView.scrollView.bounces = YES;
    [viewController setRefreshingHeaderWithParams:params refreshingBlock:^{
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES]; // 设置 keepCallback，让 JS 下拉刷新的 JS 代码可以多次回调
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
    if (autoRefresh) {
        [viewController beginHeaderRefreshing];
    }
}

- (void)refreshHeaderBegin:(CDVInvokedUrlCommand *)command {
    
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    [viewController beginHeaderRefreshing];
}

- (void)refreshHeaderLoadDone:(CDVInvokedUrlCommand *)command {
    
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    [viewController endHeaderRefreshing];
}

- (void)setRefreshFooterInfo:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    
    viewController.webView.scrollView.bounces = YES;
    [viewController setRefreshingFooterWithParams:params refreshingBlock:^{
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:YES]; // 设置 keepCallback，让 JS 下拉刷新的 JS 代码可以多次回调
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

- (void)refreshFooterBegin:(CDVInvokedUrlCommand *)command {
    
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    [viewController beginFooterRefreshing];
}

- (void)refreshFooterLoadDone:(CDVInvokedUrlCommand *)command {
    
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    [viewController endFooterRefreshing];
}

#pragma mark - Param

- (void)winParam:(CDVInvokedUrlCommand *)command {
    // 兼容以前错误的用法
    return [self pageParam:command];
}

- (void)frameParam:(CDVInvokedUrlCommand *)command {
    // 兼容以前错误的用法
    return [self pageParam:command];
}

- (void)pageParam:(CDVInvokedUrlCommand *)command {
    
    SUMViewController *viewController = (SUMViewController *)self.viewController;
    
    NSDictionary *pageParams = viewController.pageParams ?: @{};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pageParams options:0 error:nil];
    NSString *pageParamsStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:pageParamsStr];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)execScript:(CDVInvokedUrlCommand *)command {
    
    NSDictionary *params = [command argumentAtIndex:0];
    NSString *windowId = params[@"winId"];
    NSString *frameId = params[@"frameId"];
    NSString *script = params[@"script"];
    
    SUMViewController *viewController = [self targetWithWindowId:windowId frameId:frameId];
    if (!viewController) {
        return;
    }
    [(UIWebView *)viewController.webView stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark - private

- (id)targetWithWindowId:(NSString *)windowId frameId:(NSString *)frameId {
    
    SUMWindowViewController *window;
    if (windowId) {
        window = self.class.allWindows[windowId];
        if (!window) {
            return nil;
        }
    }
    else {
        if ([self.viewController isMemberOfClass:[SUMFrameViewController class]]) {
            window = ((SUMFrameViewController *)self.viewController).window;
        } else {
            window = (SUMWindowViewController *)self.viewController;
        }
    }
    return frameId ? [window frameWithId:frameId] : window;
}

@end
