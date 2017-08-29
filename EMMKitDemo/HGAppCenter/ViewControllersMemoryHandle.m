//
//  ViewControllersMemoryHandle.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/7.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "ViewControllersMemoryHandle.h"
@interface ViewControllersMemoryHandle()

@property (nonatomic, strong) NSMutableDictionary *memorys;// appId:viewControllers
@end

@implementation ViewControllersMemoryHandle

+ (ViewControllersMemoryHandle *)sharedInstance{
    static dispatch_once_t once = 0;
    __strong static id _shareObject = nil;
    dispatch_once(&once, ^{
        _shareObject = [[self alloc] init];
    });
    return _shareObject;
}

- (instancetype) init{
    self = [super init];
    if(self){
        self.memorys = [NSMutableDictionary new];
    }
    return self;
}

- (void)setViewControllers:(NSArray *)viewControllers key:(NSString *)appId{
    [self.memorys setValue:viewControllers forKey:appId];
}

- (NSArray *)getViewControllers:(NSString *)appId{
    NSArray *viewControllers = [NSArray arrayWithArray:[self.memorys valueForKey:appId]];
    return viewControllers;
}

- (void)removeViewControllesr:(NSString *)appId{
    [self.memorys removeObjectForKey:appId];
}

@end
