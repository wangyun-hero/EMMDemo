//
//  HGAppDao.h
//  EMMKitDemo
//
//  Created by zm on 16/8/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGAppModel.h"
#import "HGDBHandle.h"

@interface HGAppDao : NSObject

@property(nonatomic, strong)  HGDBHandle*dbHandle;

+ (id)sharedInstance;

/**
 向数据库增加一个应用

 @param model
 @return
 */
- (BOOL) addApp:(HGAppModel *)model;

/**
 搜索应用

 @param key 搜索的数据库字段，如title
 @param value 搜索的值，模糊查询
 @return
 */
- (NSArray *)searchApps:(NSString *)key value:(NSString *)value;

/**
 根据applicationId删除应用

 @param appId
 @return
 */
- (BOOL) deleteApp:(NSString *)appId;

/**
 清空数据库

 @return
 */
- (BOOL) deleteAllApps;
/**
 根据applicationId获取一个应用

 @param appId
 @return
 */
- (HGAppModel *) getApp:(NSString *)appId;

/**
 按照分组获取应用，按照排序字段，已下载的排在前面

 @return
 */
- (NSArray *)getApps:(NSString *)appgroupcode;

/**
 获取应用的本地已下载的版本号

 @param appId
 @return 
 */
- (NSString *)getLocalVersion:(NSString *)appId;

/**
 判断是否需要下载更新

 @param appId
 @return 
 */
- (BOOL)isNeedDownload:(NSString *)appId;

/**
 更新本地www版本号

 @param version
 @param appId
 @return
 */
- (BOOL)updatewww_localVersion:(NSString *)version appId:(NSString *)appId;

- (NSArray *)getApps;


@end
