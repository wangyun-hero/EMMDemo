//
//  HGAppDao.m
//  EMMKitDemo
//
//  Created by zm on 16/8/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGAppDao.h"
#import <FMDatabase.h>
static NSString *appCenterTable = @"hg_app";

@implementation HGAppDao

+ (id) sharedInstance
{
    static id _s;
    if (_s == nil)
    {
        _s = [[[self class] alloc] init];
    }
    return _s;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _dbHandle = [HGDBHandle sharedInstance];
    }
    return self;
}

- (BOOL) addApp:(HGAppModel *)model{
    NSString *sql;
    if([self isExitApp:model.applicationId]){
        // 已存在，更新基本信息
        sql = [NSString stringWithFormat:@"update %@  set title = '%@',iconurl = '%@',introduction = '%@',scop_type = '%@',version = '%@',scheme = '%@',appgroupname = '%@',appgroupcode = '%@',appinfoexport = '%@',classname = '%@',url = '%@',webzipurl = '%@',www_size = '%@' where username = '%@' and applicationId = '%@'",appCenterTable,model.title,model.iconurl,model.introduction,model.scop_type,model.version,model.URL_Scheme,model.appgroupname,model.appgroupcode,model.appinfoexport,model.classname,model.url,model.webZipUrl,model.www_size,[self getCurrentUserName],model.applicationId];
    }
    else{
        // 不存在 插入一条
        sql = [NSString stringWithFormat:@"INSERT INTO %@ (applicationId,username,title,iconurl,introduction,scop_type,version,scheme,appgroupname,appgroupcode,appinfoexport,classname,url,webzipurl,www_localVersion,orderNum,www_size) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%ld','%@')",appCenterTable,model.applicationId,[self getCurrentUserName],model.title,model.iconurl,model.introduction,model.scop_type,model.version,model.URL_Scheme,model.appgroupname,model.appgroupcode,model.appinfoexport,model.classname,model.url,model.webZipUrl,@"0",(long)model.orderNum,model.www_size];
    }
    return [_dbHandle executeUpdate:sql];
}

- (BOOL) isExitApp:(NSString *)appId{
    NSString *sql = [NSString stringWithFormat:@"select *from %@ where username = '%@' and applicationId ='%@'",appCenterTable,[self getCurrentUserName],appId];
    __block BOOL isExit = NO;
    [_dbHandle.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            if (set)
            {
                [set next];
                // 返回第0列
                int c = [set intForColumnIndex:0];
                [set close];
                if(c > 0){
                    isExit = YES;
                }
            }
        }
        [db close];
    }];
    return isExit;
}

- (NSArray *)searchApps:(NSString *)key value:(NSString *)value{
    __block  NSMutableArray *searchApps = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where username = '%@' and %@ like '%%%@%%'",appCenterTable,[self getCurrentUserName],key,value];
    if([key isEqualToString:@"applicationId"]){
        sql = [NSString stringWithFormat:@"select * from %@ where username = '%@' and %@ = '%@'",appCenterTable,[self getCurrentUserName],key,value];
    }
    [_dbHandle.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                HGAppModel *model = [[HGAppModel alloc] init];
                model.applicationId = [set stringForColumn:@"applicationId"];
                model.title = [set stringForColumn:@"title"];
                model.iconurl = [set stringForColumn:@"iconurl"];
                model.introduction = [set stringForColumn:@"introduction"];
                model.scop_type = [set stringForColumn:@"scop_type"];
                model.version = [set stringForColumn:@"version"];
                model.URL_Scheme = [set stringForColumn:@"scheme"];
                model.appgroupcode = [set stringForColumn:@"appgroupcode"];
                model.appgroupname = [set stringForColumn:@"appgroupname"];
                model.appinfoexport = [set stringForColumn:@"appinfoexport"];
                model.classname = [set stringForColumn:@"classname"];
                model.url = [set stringForColumn:@"url"];
                model.webZipUrl = [set stringForColumn:@"webzipurl"];
                model.www_localVersion = [set stringForColumn:@"www_localVersion"];
                model.orderNum = [set intForColumn:@"orderNum"];
                model.www_size = [set stringForColumn:@"www_size"];
                [searchApps addObject:model];
            }
            [set close];
        }
        [db close];
        
    }];
    return [searchApps copy];
}
- (BOOL) deleteApp:(NSString *)appId{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where username = '%@' and applicationId = '%@' ",appCenterTable,[self getCurrentUserName],appId];
    return [_dbHandle executeUpdate:sql];
}

- (BOOL) deleteAllApps{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where username = '%@'" ,appCenterTable,[self getCurrentUserName]];
    return [_dbHandle executeUpdate:sql];
}

- (NSArray *)getApps:(NSString *)appgroupcode{
    __block  NSMutableArray *apps = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where username = '%@'and  appgroupcode = '%@'",appCenterTable,[self getCurrentUserName],appgroupcode];
    [_dbHandle.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                HGAppModel *model = [[HGAppModel alloc] init];
                model.applicationId = [set stringForColumn:@"applicationId"];
                model.title = [set stringForColumn:@"title"];
                model.iconurl = [set stringForColumn:@"iconurl"];
                model.introduction = [set stringForColumn:@"introduction"];
                model.scop_type = [set stringForColumn:@"scop_type"];
                model.version = [set stringForColumn:@"version"];
                model.URL_Scheme = [set stringForColumn:@"scheme"];
                model.appgroupcode = [set stringForColumn:@"appgroupcode"];
                model.appgroupname = [set stringForColumn:@"appgroupname"];
                model.appinfoexport = [set stringForColumn:@"appinfoexport"];
                model.classname = [set stringForColumn:@"classname"];
                model.url = [set stringForColumn:@"url"];
                model.webZipUrl = [set stringForColumn:@"webzipurl"];
                model.www_localVersion = [set stringForColumn:@"www_localVersion"];
                model.orderNum = [set intForColumn:@"orderNum"];
                model.www_size = [set stringForColumn:@"www_size"];
                
                [apps addObject:model];
            }
            [set close];
        }
        [db close];
        
    }];
//    // 排序 已下载的放在前面
    NSMutableArray *downloads = [NSMutableArray new];
    NSMutableArray *noDownloads = [NSMutableArray new];
    for(HGAppModel *model in apps){
        if([model.www_localVersion isEqualToString:@"0"]){
            // 没下载过
            [noDownloads addObject:model];
        }
        else{
            [downloads addObject:model];
        }
    }
    
    apps = [NSMutableArray arrayWithArray:downloads];
    [apps addObjectsFromArray:noDownloads];
    
    return [apps copy];
}

- (HGAppModel *) getApp:(NSString *)appId{
    __block HGAppModel *model = [[HGAppModel alloc] init];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where username = '%@' and applicationId = '%@'  ",appCenterTable,[self getCurrentUserName],appId];
    [_dbHandle.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                model.applicationId = [set stringForColumn:@"applicationId"];
                model.title = [set stringForColumn:@"title"];
                model.iconurl = [set stringForColumn:@"iconurl"];
                model.introduction = [set stringForColumn:@"introduction"];
                model.scop_type = [set stringForColumn:@"scop_type"];
                model.version = [set stringForColumn:@"version"];
                model.URL_Scheme = [set stringForColumn:@"scheme"];
                model.appgroupcode = [set stringForColumn:@"appgroupcode"];
                model.appgroupname = [set stringForColumn:@"appgroupname"];
                model.appinfoexport = [set stringForColumn:@"appinfoexport"];
                model.classname = [set stringForColumn:@"classname"];
                model.url = [set stringForColumn:@"url"];
                model.webZipUrl = [set stringForColumn:@"webzipurl"];
                model.www_localVersion = [set stringForColumn:@"www_localVersion"];
                model.orderNum = [set intForColumn:@"orderNum"];
                model.www_size = [set stringForColumn:@"www_size"];
            }
            [set close];
        }
        [db close];
        
    }];
    return model;
    
}

- (NSString *)getLocalVersion:(NSString *)appId{
    __block NSString *localVersion = @"";
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where username = '%@' and applicationId = '%@'",appCenterTable,[self getCurrentUserName],appId];
    [_dbHandle.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                localVersion = [set stringForColumn:@"www_localVersion"];
            }
            [set close];
        }
        [db close];
        
    }];
    
    return localVersion;

}

- (BOOL)isNeedDownload:(NSString *)appId{
    BOOL isNeedDownload = NO;
    NSArray *versions = [self searchApps:@"applicationId" value:appId];
    HGAppModel *model = [versions firstObject];
    NSString *version = model.version;
    NSString *localVersion = model.www_localVersion;
    if([version compare:localVersion]){
        isNeedDownload = YES;
    }
    return isNeedDownload;
}

- (BOOL)updatewww_localVersion:(NSString *)version appId:(NSString *)appId{
    NSString *sql = [NSString stringWithFormat:@"update %@ set www_localVersion ='%@' where username = '%@' and applicationId = '%@'",appCenterTable,version,[self getCurrentUserName], appId];
    return [_dbHandle executeUpdate:sql];
}


- (NSArray *)getApps{
    __block  NSMutableArray *apps = [NSMutableArray new];
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where username = '%@'",appCenterTable,[self getCurrentUserName]];
    [_dbHandle.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                HGAppModel *model = [[HGAppModel alloc] init];
                model.applicationId = [set stringForColumn:@"applicationId"];
                model.title = [set stringForColumn:@"title"];
                model.iconurl = [set stringForColumn:@"iconurl"];
                model.introduction = [set stringForColumn:@"introduction"];
                model.scop_type = [set stringForColumn:@"scop_type"];
                model.version = [set stringForColumn:@"version"];
                model.URL_Scheme = [set stringForColumn:@"scheme"];
                model.appgroupcode = [set stringForColumn:@"appgroupcode"];
                model.appgroupname = [set stringForColumn:@"appgroupname"];
                model.appinfoexport = [set stringForColumn:@"appinfoexport"];
                model.classname = [set stringForColumn:@"classname"];
                model.url = [set stringForColumn:@"url"];
                model.webZipUrl = [set stringForColumn:@"webzipurl"];
                model.www_localVersion = [set stringForColumn:@"www_localVersion"];
                model.orderNum = [set intForColumn:@"orderNum"];
                model.www_size = [set stringForColumn:@"www_size"];
                
                [apps addObject:model];
            }
            [set close];
        }
        [db close];
        
    }];
    return [apps copy];
}

/**
 获取当前用户名
 
 @return
 */
- (NSString *)getCurrentUserName{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    username = username.length?username:@"guest";
    return username;
}





@end
