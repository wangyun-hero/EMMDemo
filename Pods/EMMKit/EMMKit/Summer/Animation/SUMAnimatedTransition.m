//
//  SummerAnimatedTransition.m
//  EMMKitDemo
//
//  Created by Chenly on 16/8/24.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SUMAnimatedTransition.h"
#import "SUMTransitionsDelegate.h"

#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@implementation SUMAnimatedTransition

static NSTimeInterval const kDefaultDuration = 0.3;

+ (BOOL)supportAnimationType:(NSString *)type {
    // 通过是否实现 <type>: 方法来判断是否支持该 type 动画
    if ([type isEqualToString:@"none"]) {
        // type = "none", 生成 SUMAnimatedTransition 实例，这样 Close 的时候才知道不用动画
        return YES;
    }
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", type]);
    return [self instancesRespondToSelector:selector];
}

- (instancetype)initWithInfo:(NSDictionary *)info
                   operation:(UINavigationControllerOperation)operation
                  completion:(void (^)(BOOL finished))completion {
    
    if (self = [super init]) {
        
        NSString *type = info[@"type"];
        NSString *subtype = info[@"subType"];
        NSTimeInterval duration = info[@"duration"] ? [info[@"duration"] floatValue] / 1000.f : kDefaultDuration;
        NSDictionary *params = info[@"params"];
        
        _type       = type;
        _subtype    = subtype;
        _duration   = duration;
        _params     = params;
        _operation  = operation;
        _completion = completion;
    }
    return self;
}

+ (instancetype)transitionWithInfo:(NSDictionary *)info
                         operation:(UINavigationControllerOperation)operation
                        completion:(void (^)(BOOL finished))completion {
    
    if ([self supportAnimationType:info[@"type"]]) {
        return [[self alloc] initWithInfo:info operation:operation completion:completion];
    }
    return nil;
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {

    return self.duration <= 0 ? kDefaultDuration : self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", self.type]);
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:transitionContext];
#pragma clang diagnostic pop
    }
}

- (void)fade:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    if (self.operation == UINavigationControllerOperationPush) {
        toViewController.view.alpha = 0;
    }
    else {
        fromViewController.view.alpha = 1;
        [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (self.operation == UINavigationControllerOperationPush) {
            toViewController.view.alpha = 1;
        }
        else {
            fromViewController.view.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}
    
- (void)movein:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect containerRect = fromViewController.view.frame;
    CGPoint offset = CGPointZero;
    if ([self.subtype isEqualToString:@"from_left"]) {
        offset.x = -CGRectGetWidth(containerRect);
    }
    else if ([self.subtype isEqualToString:@"from_top"]) {
        offset.y = -CGRectGetHeight(containerRect);
    }
    else if ([self.subtype isEqualToString:@"from_bottom"]) {
        offset.y = CGRectGetHeight(containerRect);
    }
    else {
        // 默认 from_right
        offset.x = CGRectGetWidth(containerRect);
    }
    
    if (self.operation == UINavigationControllerOperationPush) {
        toViewController.view.frame = CGRectOffset(containerRect, offset.x, offset.y);
    }
    else {
        [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (self.operation == UINavigationControllerOperationPush) {
            toViewController.view.frame = containerRect;
        }
        else {
            fromViewController.view.frame =  CGRectOffset(containerRect, offset.x, offset.y);
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)push:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect containerRect = fromViewController.view.frame;
    CGPoint offset = CGPointZero;
    if ([self.subtype isEqualToString:@"from_left"]) {
        offset.x = -CGRectGetWidth(containerRect);
    }
    else if ([self.subtype isEqualToString:@"from_top"]) {
        offset.y = -CGRectGetHeight(containerRect);
    }
    else if ([self.subtype isEqualToString:@"from_bottom"]) {
        offset.y = CGRectGetHeight(containerRect);
    }
    else {
        // 默认 from_right
        offset.x = CGRectGetWidth(containerRect);
    }
    
    if (self.operation == UINavigationControllerOperationPush) {
        toViewController.view.frame = CGRectOffset(containerRect, offset.x, offset.y);
    }
    else {
        toViewController.view.frame = CGRectOffset(containerRect, -offset.x, -offset.y);
        [[transitionContext containerView] bringSubviewToFront:fromViewController.view];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        
        if (self.operation == UINavigationControllerOperationPush) {
            
            fromViewController.view.frame = CGRectOffset(containerRect, -offset.x, -offset.y);
            toViewController.view.frame = containerRect;
        }
        else {
            fromViewController.view.frame = CGRectOffset(containerRect, offset.x, offset.y);
            toViewController.view.frame = containerRect;
            
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
