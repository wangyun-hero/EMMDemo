//
//  XService.m
//  SummerDemo
//
//  Created by Chenly on 16/8/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "XService.h"
#import "SummerAsyncServices.h"

@interface XService ()

@property (nonatomic, strong) SummerAsyncServices *delegate;

@end

@implementation XService

- (SummerAsyncServices *)delegate {
    
    if (!_delegate) {
        _delegate = [[SummerAsyncServices alloc] init];
        _delegate.viewController = self.viewController;
        _delegate.commandDelegate = self.commandDelegate;
        [_delegate pluginInitialize];
    }
    return _delegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [SummerAsyncServices instancesRespondToSelector:aSelector];
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
