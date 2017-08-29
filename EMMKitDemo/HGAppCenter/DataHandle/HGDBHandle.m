//
//  HGDBHandle.m
//  EMMKitDemo
//
//  Created by zm on 16/8/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGDBHandle.h"
#import <FMDatabase.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@implementation HGDBHandle

+ (HGDBHandle *)sharedInstance{
    static dispatch_once_t once = 0;
    __strong static id _shareObject = nil;
    dispatch_once(&once, ^{
        _shareObject = [[self alloc] init];
    });
    return _shareObject;
}

- (instancetype)init{
    self = [super init];
    if(self){
        NSString *wirtableDBPath = [DOCUMENTS_FOLDER stringByAppendingPathComponent:@"HGEMM.db"];
        NSLog(@"dbPath:%@",wirtableDBPath);
        _queue = [FMDatabaseQueue databaseQueueWithPath:wirtableDBPath];
        [self creatTable];
    }
    return self;
}

- (void)creatTable{
    [_queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            NSString *sqlName = @"hg_app";
            NSString *sql = [NSString stringWithFormat:@"create table if not exists %@  ("
                             " id integer primary key autoincrement not null, "
                             " applicationId varchar(128), " // appkey
                             " username varchar(128)," //用户名
                             " title varchar(128), " //应用名称
                             " iconurl varchar(1024), " // 应用icon
                             " introduction text, "
                             " scop_type varchar(128)," //应用类型
                             " version varchar(128),"   // 应用版本号
                             " scheme varchar(128)," //
                             " appgroupname varchar(128), " // 分组名称
                             " appgroupcode varchar(128)," // 分组code
                             " appinfoexport text,"
                             " classname varchar(1024),"
                             " url varchar(1024)," // ios下载url/web打开url
                             " webzipurl varchar(1024)," //web下载www包地址
                             " www_localVersion varchar(128)," // www本地版本
                             " orderNum INTEGER(128)," //排序字段
                             " www_size varchar(128)" //www压缩包大小
                             ");",sqlName];
            [db executeUpdate:sql];
        }
        [db close];
    }];
    
}

- (BOOL)executeUpdate:(NSString *)strSql
{
    __block  BOOL isSuccess = YES;
    
    [_queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            [db beginTransaction]; // 使用事务 提高速度
            BOOL isRollBack = NO;
            @try {
            [db executeUpdate:strSql];
            
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                isSuccess = NO;
            }
            }
            @catch (NSException *exception) {
                isRollBack = YES;
                [db rollback];
            }
            @finally {
                if (!isRollBack) {
                    [db commit];
                }
            }
        }
        [db close];
    }];
    
    return isSuccess;
    
    
}

- (BOOL)executeUpdate:(NSString *)strSql withArgumentsInArray:(NSArray *)arguments
{
    __block  BOOL isSuccess = YES;
    
    [_queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            [db beginTransaction]; // 使用事务 提高速度
            BOOL isRollBack = NO;
            @try {
                
                [db executeUpdate:strSql withArgumentsInArray:arguments];
                
                if ([db hadError])
                {
                    NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                    isSuccess = NO;
                }
            }
            @catch (NSException *exception) {
                isRollBack = YES;
                [db rollback];
            }
            @finally {
                if (!isRollBack) {
                    [db commit];
                }
            }
        }
        [db close];
    }];
    
    return isSuccess;
    
}

@end
