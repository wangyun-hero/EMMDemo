//
//  SUMWindowViewController.h
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMViewController.h"
#import "SUMTransitionsDelegate.h"

@class SUMFrameViewController;
@class SUMGroupViewController;

@protocol SUMWindowViewControllerResponderDelegate <NSObject>

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event;
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event;

@end

@interface SUMWindowViewController : SUMViewController <SUMTransitionsDelegate>

@property (nonatomic, assign) BOOL sum_navigationBarHidden;             // 导航栏是否隐藏
@property (nonatomic, assign) BOOL sum_statusBarHidden;                 // 状态栏是否隐藏
@property (nonatomic, assign) BOOL sum_isFullScreenLayout;              // 是否使用状态栏的20高度
@property (nonatomic, assign) NSUInteger sum_preferredOrientation;      // 优先方向
@property (nonatomic, assign) NSUInteger sum_supportedOrientation;      // 支持方向
@property (nonatomic, copy)   NSString  *sum_statusBarStyle;            // 状态栏风格: dark | light
@property (nonatomic, copy)   NSString  *sum_statusBarBackgroundColor;  // 状态栏背景色

- (void)openWindow:(SUMWindowViewController *)window animated:(BOOL)animated;

- (void)openFrame:(SUMFrameViewController *)frame params:(NSDictionary *)params opened:(BOOL)opened;
- (void)closeFrame:(SUMFrameViewController *)frame;
- (SUMFrameViewController *)frameWithId:(NSString *)sumId;

- (void)openGroup:(SUMGroupViewController *)group params:(NSDictionary *)params;
- (void)closeGroup:(SUMGroupViewController *)group;
- (SUMGroupViewController *)groupWithId:(NSString *)sumId;

@property (nonatomic, strong) SUMAnimatedTransition *sum_transition;
@property (nonatomic, weak) id<SUMWindowViewControllerResponderDelegate> responderDelegate;

@end
