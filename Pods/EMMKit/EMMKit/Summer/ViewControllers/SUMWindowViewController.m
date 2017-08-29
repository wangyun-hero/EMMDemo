//
//  SUMWindowViewController.m
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMWindowViewController.h"
#import "SUMPreConfig.h"
#import "SUMPreRender.h"
#import "SUMFrameAnimation.h"
#import "SUMAnimatedTransition.h"
#import "SUMFrameViewController.h"
#import "SUMGroupViewController.h"
#import "UIColor+HexString.h"

@interface SUMWindowViewController () <SUMPreRenderDelegate>

@property (nonatomic, strong) UIView *statusBarBlockView;

@end

@implementation SUMWindowViewController
{
    NSMutableDictionary<NSString *, SUMFrameViewController *> *_frames;
    NSMutableDictionary<NSString *, SUMGroupViewController *> *_groups;
}

#pragma mark - getter & setter

- (UIView *)statusBarBlockView {
    if (!_statusBarBlockView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20);
        _statusBarBlockView = [[UIView alloc] initWithFrame:rect];
    }
    return _statusBarBlockView;
}

- (void)setSum_statusBarBackgroundColor:(NSString *)sum_statusBarBackgroundColor {
    _sum_statusBarBackgroundColor = sum_statusBarBackgroundColor;
    UIColor *backgroundColor = [UIColor emm_colorWithHexString:sum_statusBarBackgroundColor];
    if (backgroundColor) {
        self.statusBarBlockView.backgroundColor = backgroundColor;
        if (!self.statusBarBlockView.superview) {
            
            self.statusBarBlockView.alpha = 0;
            [self.view addSubview:self.statusBarBlockView];
            [UIView animateWithDuration:0.2 animations:^{
                self.statusBarBlockView.alpha = 1;
            }];
        }
        [self.view bringSubviewToFront:self.statusBarBlockView];
    }
    else {
        if (self.statusBarBlockView.superview) {
            [UIView animateWithDuration:0.2 animations:^{
                self.statusBarBlockView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.statusBarBlockView removeFromSuperview];
            }];
        }
    }
}

#pragma mark - life cycle

- (instancetype)initWithSumId:(NSString *)sumId {

    if (self = [super initWithSumId:sumId]) {
        
        _sum_navigationBarHidden = [SUMPreConfig sharedInstance].navigationBarHidden;
        _sum_statusBarHidden = [SUMPreConfig sharedInstance].statusBarHidden;
        _sum_isFullScreenLayout = [SUMPreConfig sharedInstance].isFullScreenLayout;
        _sum_statusBarStyle = [SUMPreConfig sharedInstance].statusBarStyle;
        _sum_supportedOrientation = [SUMPreConfig sharedInstance].supportedOrientation;
        _sum_preferredOrientation = (_sum_supportedOrientation & UIInterfaceOrientationMaskPortrait) ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskLandscapeLeft;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self updateStyle];
}

#pragma mark

- (NSUInteger)supportedInterfaceOrientations {
    
    return self.sum_supportedOrientation;
}

- (BOOL)prefersStatusBarHidden {
    
    return self.sum_statusBarHidden;
}

- (void)updateStyle {
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.bounces = NO;
    
    [self updatenNavigationBarStyle];
    [self updateStatusBarStyle];
    [self updateOrientation];
}

- (void)updatenNavigationBarStyle {
    [self.navigationController setNavigationBarHidden:self.sum_navigationBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.navigationController.navigationBar.barStyle == UIBarStyleDefault ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (void)updateStatusBarStyle {
    
    NSString *style = self.sum_statusBarStyle;
    if (!style) {
        [self.navigationController.navigationBar setBarStyle:[UINavigationBar appearance].barStyle];
    }
    else {
        if ([style isEqualToString:@"dark"]) {
            [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
        }
        else if ([style isEqualToString:@"light"]) {
            [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        }
    }
    
    UIEdgeInsets insets = self.webView.scrollView.contentInset;
    if (self.navigationController.navigationBar.translucent) {
        
        if (self.sum_navigationBarHidden) {
            insets.top = self.sum_isFullScreenLayout || self.sum_statusBarHidden ? 0 : 20;
        }
        else {
            insets.top = 44 + (self.sum_statusBarHidden ? 0 : 20);
        }
    }
    else {
        if (self.sum_navigationBarHidden) {
            insets.top = self.sum_isFullScreenLayout || self.sum_statusBarHidden ? 0 : 20;
        }
        else {
            insets.top = 0;
        }
    }
    self.webView.scrollView.contentInset = insets;
}

- (void)updateOrientation {
    NSInteger preferredOrientation = self.sum_preferredOrientation;
    NSInteger supportedOrientation = self.sum_supportedOrientation;
    
    self.sum_supportedOrientation = (supportedOrientation & preferredOrientation) == 0 ? preferredOrientation : supportedOrientation;
    // 横屏
    [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] setValue:@(self.sum_preferredOrientation) forKey:@"orientation"];
}

#pragma mark - Attributes

- (void)setAttribute:(id)value forAttributeName:(NSString *)attributeName {
    
    NSString *key = [attributeName lowercaseString];
    if (![[self effectiveAttributeNames] containsObject:key]) {
        return;
    }
    
    if ([key isEqualToString:@"screenorientation"]) {
        self.sum_preferredOrientation = [value isEqualToString:@"landscape"] ? UIInterfaceOrientationMaskLandscapeLeft : UIInterfaceOrientationMaskPortrait;
    }
    else if ([key isEqualToString:@"statusbarstyle"]) {
        self.sum_statusBarStyle = value;
    }
    else if ([key isEqualToString:@"statusbarappearance"]) {
        self.sum_statusBarHidden = ![value boolValue];
    }
    else if ([key isEqualToString:@"navigationbarappearance"]) {
        self.sum_navigationBarHidden = ![value boolValue];
    }
    else if ([key isEqualToString:@"fullscreen"]) {
        self.sum_isFullScreenLayout = [value boolValue];
    }
    else if ([key isEqualToString:@"statusbarbgcolor"]) {
        self.sum_statusBarBackgroundColor = [value isKindOfClass:[NSString class]] ? value : nil;
    }
    else if ([key isEqualToString:@"bgcolor"]) {
        UIColor *backgroundColor = [UIColor emm_colorWithHexString:value];
        if (backgroundColor) {
            self.backgroundColor = backgroundColor;
        }
    }
}

- (NSArray *)effectiveAttributeNames {
    return @[@"screenorientation", @"statusbarstyle", @"statusbarappearance", @"fullscreen", @"bgcolor", @"statusbarbgcolor", @"navigationbarappearance"];
}

#pragma mark - Window & Frame

- (void)openWindow:(SUMWindowViewController *)window animated:(BOOL)animated {

    [self.navigationController pushViewController:window animated:animated];
}

- (void)closeSelf:(BOOL)animated {
    
    [self.navigationController popViewControllerAnimated:animated];
}

#pragma mark - frame

- (void)addFrame:(SUMFrameViewController *)frame {

    if (frame == nil) {
        return;
    }    
    [self addChildViewController:frame];
    [self.webView.scrollView addSubview:frame.view];
    
    if (!_frames) {
        _frames = [NSMutableDictionary dictionary];
    }
    _frames[frame.sumId] = frame;
}

- (void)openFrame:(SUMFrameViewController *)frame params:(NSDictionary *)params opened:(BOOL)opened {
    
    NSDictionary *animation = params[@"animation"];
    SUMFrameAnimation *frameAnimation = [SUMFrameAnimation animationWithInfo:animation completion:nil];
    frame.animation  = frameAnimation;
    frame.positions  = params[@"position"];
    frame.pageParams = params[@"pageParam"];
    
    if (opened) {
        // 已打开过的
        frame.view.hidden = NO;
        [frame.view.superview bringSubviewToFront:frame.view];
        [frame setLayoutConstraintsWithPositions:frame.positions];
        [frame.view sum_performFrameAnimation:frame.animation];
    }
    else {
        NSString *startPage = params[@"url"];
        frame.wwwFolderName = self.wwwFolderName;
        frame.startPage = startPage;
        frame.window = self;
        [frame setAttributes:params];
        [[SUMPreRender sharedInstance] beginPreRenderingViewController:frame observer:self];
    }
}

- (void)closeFrame:(SUMFrameViewController *)frame {
    
    [frame.view removeFromSuperview];
    [frame removeFromParentViewController];
    [_frames removeObjectForKey:frame.sumId];
}

- (SUMFrameViewController *)frameWithId:(NSString *)sumId {
    
    return _frames[sumId];
}

#pragma mark - group

- (void)addGroup:(SUMGroupViewController *)group {
    
    [self addChildViewController:group];
    [self.webView.scrollView addSubview:group.view];
    if (!_groups) {
        _groups = [NSMutableDictionary dictionary];
    }
    _groups[group.sumId] = group;
}

- (void)openGroup:(SUMGroupViewController *)group params:(NSDictionary *)params {
    
    group.positions = params[@"position"];
    NSInteger index = [params[@"index"] integerValue];
    [group preRenderWithIndex:index observer:self];
}

- (void)closeGroup:(SUMGroupViewController *)group {
    
    [group.view removeFromSuperview];
    [group removeFromParentViewController];
    [_groups removeObjectForKey:group.sumId];
}

- (SUMGroupViewController *)groupWithId:(NSString *)sumId {
    
    return _groups[sumId];
}

#pragma mark - <SUMPreRenderDelegate>

- (void)preRender:(SUMPreRender *)preRender didViewControllerFinishedRender:(UIViewController *)viewController {

    if ([viewController isKindOfClass:[SUMFrameViewController class]]) {
        
        SUMFrameViewController *frame = (SUMFrameViewController *)viewController;
        [self addFrame:frame];
        [frame setLayoutConstraintsWithPositions:frame.positions];
        [frame.view sum_performFrameAnimation:frame.animation];
    }
    else if ([viewController isKindOfClass:[SUMGroupViewController class]]) {
    
        SUMGroupViewController *group = (SUMGroupViewController *)viewController;
        [self addGroup:group];
        [group setLayoutConstraintsWithPositions:group.positions];
    }
}

#pragma mark - <SUMAnimatedTransitionAvailable>

- (SUMAnimatedTransition *)animationControllerForOperation:(NSNumber *)operation {
    self.sum_transition.operation = operation.integerValue;
    return self.sum_transition;
}


@end
