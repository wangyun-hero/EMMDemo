//
//  EMMAppsManager.h
//  SummerDemo
//
//  Created by Chenly on 2017/2/24.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMAppsManager : NSObject

@property (nonatomic, copy, readonly) NSArray *apps;
@property (nonatomic, copy, readonly) NSArray *localApps;

+ (instancetype)sharedInstance;

- (void)fetchApps:(void(^)(NSArray<NSDictionary *> *apps, NSError *error))completion;
- (NSArray<NSDictionary *> *)getLocalApps;

- (void)installAppWithId:(NSString *)appid
                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
              completion:(void (^)(BOOL success, id result))completion;

- (void)upgradeAppWithId:(NSString *)appid
                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
              completion:(void (^)(BOOL success, id result))completion;

- (BOOL)uninstallAppWithId:(NSString *)appid error:(NSError **)error;

- (id)paramsForLaunchingAppWithId:(NSString *)appid;

@end
