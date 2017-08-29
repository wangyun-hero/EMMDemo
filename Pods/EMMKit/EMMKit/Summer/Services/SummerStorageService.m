//
//  SummerStorageService.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerStorageService.h"
#import "SummerInvocation.h"
#import "EMMStorage.h"
#import "SUMViewController.h"

@implementation SummerStorageService
{
    NSMutableDictionary *_windowContexts;
}

+ (void)load {
    if (self == [SummerStorageService self]) {
        [SummerServices registerService:@"SummerStorage" class:@"SummerStorageService"];
    }
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerStorageService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerStorageService alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _windowContexts = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)writeApplicationContext:(SummerInvocation *)invocation {

    NSString *key = invocation.params[@"key"];
    NSDictionary *values = invocation.params[@"value"];
    if (!key || !values) {
        return;
    }
    
    [[EMMStorage sharedInstance] setValue:values forKey:key toLocation:EMMStorageLocationApplicationContext];
}

- (id)readApplicationContext:(SummerInvocation *)invocation {
    
    NSString *key = invocation.params[@"key"];
    return [[EMMStorage sharedInstance] valueForKey:key fromLocation:EMMStorageLocationApplicationContext];
}

- (void)writeConfigure:(SummerInvocation *)invocation {
    
    NSString *key = invocation.params[@"key"];
    NSDictionary *values = invocation.params[@"value"];
    if (!key || !values) {
        return;
    }
    [[EMMStorage sharedInstance] setValue:values forKey:key toLocation:EMMStorageLocationConfigure];
}

- (id)readConfigure:(SummerInvocation *)invocation {
    
    NSString *key = invocation.params[@"key"];
    return [[EMMStorage sharedInstance] valueForKey:key fromLocation:EMMStorageLocationConfigure];
}

- (void)writeWindowContext:(SummerInvocation *)invocation {
    
    NSString *key = invocation.params[@"key"];
    NSDictionary *values = invocation.params[@"value"];
    if (!key || !values) {
        return;
    }
    
    SUMViewController *summer = invocation.sender;
    _windowContexts[summer.sumId] = @{ key: values };
}

- (id)readWindowContext:(SummerInvocation *)invocation {
 
    NSString *key = invocation.params[@"key"];
    return _windowContexts[key];
}

@end
