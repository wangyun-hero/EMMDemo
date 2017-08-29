//
//  XStorage.m
//  SummerDemo
//
//  Created by Chenly on 16/8/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "XStorage.h"
#import "SummerStorage.h"

@interface XStorage ()

@property (nonatomic, strong) SummerStorage *delegate;

@end

@implementation XStorage

- (SummerStorage *)delegate {
    
    if (!_delegate) {
        _delegate = [[SummerStorage alloc] init];
        _delegate.viewController = self.viewController;
        _delegate.commandDelegate = self.commandDelegate;
        [_delegate pluginInitialize];
    }
    return _delegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [SummerStorage instancesRespondToSelector:aSelector];
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
