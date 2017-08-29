//
//  MessageDBHandle.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "MessageDBHandle.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

@implementation MessageDBHandle

+(MessageDBHandle *)getSharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _shareObject = nil;
    dispatch_once(&pred, ^{
        _shareObject = [[self alloc] init];
    });
    return _shareObject;
    
}

- (id)init
{
    self = [super init];
    if(self){
        NSString *wirtableDBPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Portal_Message.db"];
        NSLog(@"dbPath:%@",wirtableDBPath);
        _queue = [FMDatabaseQueue databaseQueueWithPath:wirtableDBPath];
    }
    return self;
}

- (void)initTable
{
    [_queue inDatabase:^(FMDatabase *_db) {
        if([_db open]){
            
            // 创建消息数据库
            NSString *sqlMessage = @"create table if not exists messageinfo ("
            " messageId integer primary key autoincrement not null, "//id
            " userId varchar(64), " //用户id
            " messageName varchar(64), " //消息标题
            " messageInfo text, " //消息内容
            " messageDate varchar(64), " //消息时间
            " messageImage varchar(128), "   // 消息图片
            " messageUrl varchar(1024), " //预留字段
            " appId varchar(128), "
            " isRead integer, "
            " extension4 varchar(128), "
            " extension5 varchar(128) "
            ");";
            [_db executeUpdate:sqlMessage];

        }
    }];
}

- (BOOL)executeUpdate:(NSString *)strSql
{
    __block  BOOL isSuccess = YES;
    
    [_queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            [db executeUpdate:strSql];
            
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                isSuccess = NO;
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
            [db executeUpdate:strSql withArgumentsInArray:arguments];
            
            if ([db hadError])
            {
                NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
                isSuccess = NO;
            }
        }
        [db close];
    }];
    
    return isSuccess;
    
}

@end
