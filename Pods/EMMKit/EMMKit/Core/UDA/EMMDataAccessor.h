//
//  EMMDataAccessor.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kEMMDataAccessorBundleProduction;
extern NSString * const kEMMDataAccessorBundleDemo;

@interface EMMDataAccessor : NSObject

@property (nonatomic, copy) NSString *module;
@property (nonatomic, copy) NSString *request;
@property (nonatomic, copy) NSDictionary *args;

// 设置默认 bundle
+ (void)setDefaultBundle:(NSString *)bundleName;
+ (NSString *)getDefaultBundle;

// 构造方法
+ (instancetype)dataAccessorWithModule:(NSString *)module request:(NSString *)request;
+ (instancetype)dataAccessorWithModule:(NSString *)module request:(NSString *)request bundle:(NSBundle *)bundle;
- (instancetype)initWithModule:(NSString *)module request:(NSString *)request args:(NSDictionary *)args;

/**
 *  获取数据(抽象方法，由子类实现)
 */
- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

@end
