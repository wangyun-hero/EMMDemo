//
//  XUpgrade.m
//  SummerDemo
//
//  Created by Chenly on 16/8/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "XUpgrade.h"
#import "SummerUpgrade.h"

@interface XUpgrade ()

@property (nonatomic, strong) SummerUpgrade *delegate;

@end

@implementation XUpgrade

- (SummerUpgrade *)delegate {
    
    if (!_delegate) {
        _delegate = [[SummerUpgrade alloc] init];
        _delegate.viewController = self.viewController;
        _delegate.commandDelegate = self.commandDelegate;
        [_delegate pluginInitialize];
    }
    return _delegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [SummerUpgrade instancesRespondToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    if ([CDVPlugin instancesRespondToSelector:aSelector]) {
        return self;
    }
    else {
        return self.delegate;
    }
}

@end
