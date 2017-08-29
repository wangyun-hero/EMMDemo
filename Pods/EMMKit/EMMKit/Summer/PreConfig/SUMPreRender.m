//
//  SUMPreRender.m
//  SummerDemo
//
//  Created by Chenly on 16/9/14.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMPreRender.h"
#import <objc/runtime.h>

@interface SUMPreRender ()

@property (nonatomic, strong) UIWindow *window;

@end

@implementation SUMPreRender
{
    NSMutableArray *_viewControllers;
    NSMutableDictionary *_observers;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SUMPreRender *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SUMPreRender alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _viewControllers = [NSMutableArray array];
        _observers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)beginPreRenderingViewController:(UIViewController *)viewController observer:(id<SUMPreRenderDelegate>)observer {

    if (!viewController) {
        return;
    }
    
    [_viewControllers addObject:viewController];
    [self.window.rootViewController addChildViewController:viewController];
    [self.window.rootViewController.view addSubview:viewController.view];
    [self setObserver:observer forViewController:viewController];
}

- (void)finishPreRenderingViewController:(UIViewController *)viewController {

    if (![_viewControllers containsObject:viewController]) {
        return;
    }
    
    [_viewControllers removeObject:viewController];
    [viewController removeFromParentViewController];
    [viewController.view removeFromSuperview];
    viewController.beenPreRendered = YES;
    
    NSValue *key = [NSValue valueWithNonretainedObject:viewController];
    id<SUMPreRenderDelegate> observer = _observers[key];
    if (observer) {
        [observer preRender:self didViewControllerFinishedRender:viewController];
        [_observers removeObjectForKey:key];
    }
}

#pragma mark - observer

- (void)setObserver:(id<SUMPreRenderDelegate>)observer forViewController:(UIViewController *)viewController {

    if (!observer & !viewController) {
        return;
    }
    
    NSValue *key = [NSValue valueWithNonretainedObject:viewController];
    _observers[key] = observer;
}

- (void)removeObserverForViewController:(UIViewController *)viewController {

    NSValue *key = [NSValue valueWithNonretainedObject:viewController];
    _observers[key] = nil;
}

#pragma mark - getter & setter

- (UIWindow *)window {

    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.windowLevel = 0;
        _window.rootViewController = [[UIViewController alloc] init];
    }
    return _window;
}

@end

#pragma mark - UIViewController.beenPreRendered

@implementation UIViewController (SUMPreRender)

- (BOOL)beenPreRendered {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(beenPreRendered));
    return number.boolValue;
}

- (void)setBeenPreRendered:(BOOL)beenPreRendered {

    objc_setAssociatedObject(self, @selector(beenPreRendered), @(beenPreRendered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
