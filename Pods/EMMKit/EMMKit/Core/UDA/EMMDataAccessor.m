//
//  EMMDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMDataAccessor.h"
#import "NSBundle+EMMModule.h"
#import "EMMHTTPDataAccessor.h"

NSString * const kEMMDataAccessorBundleProduction = @"emm_uda_production";
NSString * const kEMMDataAccessorBundleDemo = @"emm_uda_demo";

@implementation EMMDataAccessor

+ (void)load {
    [self setDefaultBundle:kEMMDataAccessorBundleProduction];
}

static NSString * kDefaultBundleName;

// 设置默认 bundle
+ (void)setDefaultBundle:(NSString *)bundleName {
    kDefaultBundleName = bundleName;
}

+ (NSString *)getDefaultBundle{
    return  kDefaultBundleName;
}

+ (instancetype)dataAccessorWithModule:(NSString *)module request:(NSString *)request {
    
    return [self dataAccessorWithModule:module request:request bundle:nil];
}

+ (instancetype)dataAccessorWithModule:(NSString *)module request:(NSString *)request bundle:(NSBundle *)bundle {
    
    if (!bundle) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:kDefaultBundleName ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    NSDictionary *accessorInfo = [self accessorInfoForModule:module request:request bundle:bundle];
    Class class = [self accessorClassWithAccessorInfo:accessorInfo];
    NSAssert(class, @"未找到指定的 Data Accessor Class: %@ - %@", module, request);
    NSDictionary *args = accessorInfo[@"args"];
    return [[class alloc] initWithModule:module request:request args:args];
}

- (instancetype)initWithModule:(NSString *)module request:(NSString *)request args:(NSDictionary *)args {
    
    if (self = [super init]) {
        _module = [module copy];
        _request = [request copy];
        _args = [args copy];
    }
    return self;
}

/**
 *  查找 module.json 中 request 方法对应的 Accessor 信息
 */
+ (NSDictionary *)accessorInfoForModule:(NSString *)module request:(NSString *)request bundle:(NSBundle *)bundle {
    
    // 缓存：key = module 用于缓存配置文件内容
    static NSMutableDictionary *accessorsCache;
    if (!accessorsCache) {
        accessorsCache = [NSMutableDictionary dictionary];
    }
    
    // 缓存： { module: accessors }
    NSDictionary *accessors = accessorsCache[module];
    if (!accessors) {
        // 先从 emm_[module].bundle 中寻找 json 文件，找不到再到 mainBundle 下找。
        NSString *filePath = [bundle pathForResource:module ofType:@"json"];
        if (!filePath) {
            filePath = [[NSBundle mainBundle] pathForResource:module ofType:@"json"];
        }
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        accessors = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSAssert(accessors, @"未找到指定的 Data Accessor 文件: %@.json", module);
        accessorsCache[module] = accessors;
    }
    
    NSDictionary *accessor = accessors[request];
    NSAssert(accessor, @"未找到指定的 Data Accessor: %@ - %@", module, request);
    
    return accessor;
}

+ (Class)accessorClassWithAccessorInfo:(NSDictionary *)accessorInfo {
    
    NSString *className = [accessorInfo valueForKeyPath:@"ios.class"];
    if (!className) {
        NSString *type = accessorInfo[@"type"];
        if ([type isEqualToString:@"File"]) {
            className = @"EMMFileDataAccessor";
        }
        else if ([type isEqualToString:@"HTTP"]) {
            className = @"EMMHTTPDataAccessor";
        }
    }
    return (className != nil) ? NSClassFromString(className) : nil;
}

#pragma mark -

/**
 *  获取数据(抽象方法，由子类实现)
 */
- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSAssert(NO, @"State method should never be called in the actual dummy class");
}

@end
