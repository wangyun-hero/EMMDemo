//
//  UINavigationController+SUMTransitions.m
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "UINavigationController+SUMTransitions.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@interface SUMTransitionsPrivateObj : NSObject <UINavigationControllerDelegate>

@property (nonatomic, weak) id<UINavigationControllerDelegate> originalDelegate;

@end

@implementation SUMTransitionsPrivateObj

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    UIViewController *vc = operation == UINavigationControllerOperationPush ? toVC : fromVC;
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([vc respondsToSelector:@selector(animationControllerForOperation:)]) {
        return [vc performSelector:@selector(animationControllerForOperation:) withObject:@(operation)];
    }
#pragma clang diagnostic pop
    return nil;
}
    
@end

@interface UINavigationController (SUMTransitionsPrivateObj)

@property (nonatomic, strong) SUMTransitionsPrivateObj *sum_delegate;
    
@end

@implementation UINavigationController (SUMTransitions)

@dynamic shouldTakeOverDelegate;

+ (void)load {

    [self aspect_hookSelector:@selector(setDelegate:) withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo, id<UINavigationControllerDelegate> delegate) {
        
        UINavigationController *instance = aspectInfo.instance;
        NSInvocation *invocation = aspectInfo.originalInvocation;
        if (instance.shouldTakeOverDelegate) {
            instance.sum_delegate.originalDelegate = delegate;
        }
        else {
            [invocation invoke];
        }
    } error:NULL];
}

- (void)setShouldTakeOverDelegate:(BOOL)shouldTakeOverDelegate {
    
    if (shouldTakeOverDelegate) {
        SUMTransitionsPrivateObj *delegateObj = [[SUMTransitionsPrivateObj alloc] init];
        delegateObj.originalDelegate = self.delegate;
        self.sum_delegate = delegateObj;
        self.delegate = delegateObj;
    }
    else {
        self.sum_delegate = nil;
    }
    
    objc_setAssociatedObject(self, @selector(shouldTakeOverDelegate), @(shouldTakeOverDelegate), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)shouldTakeOverDelegate {
    
    NSNumber *number = objc_getAssociatedObject(self, @selector(shouldTakeOverDelegate));
    return number.boolValue;
}

- (SUMTransitionsPrivateObj *)sum_delegate {
    return objc_getAssociatedObject(self, @selector(sum_delegate));
}

- (void)setSum_delegate:(SUMTransitionsPrivateObj *)sum_delegate {
    objc_setAssociatedObject(self, @selector(sum_delegate), sum_delegate, OBJC_ASSOCIATION_RETAIN);
}

@end
