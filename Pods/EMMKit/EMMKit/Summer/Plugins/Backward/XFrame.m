//
//  XFrame.m
//  SummerDemo
//
//  Created by Chenly on 16/8/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "XFrame.h"
#import "SummerFrame.h"

@interface XFrame ()

@property (nonatomic, strong) SummerFrame *delegate;

@end

@implementation XFrame

- (SummerFrame *)delegate {

    if (!_delegate) {
        _delegate = [[SummerFrame alloc] init];
        _delegate.viewController = self.viewController;
        _delegate.commandDelegate = self.commandDelegate;
        [_delegate pluginInitialize];
    }
    return _delegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [SummerFrame instancesRespondToSelector:aSelector];
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
