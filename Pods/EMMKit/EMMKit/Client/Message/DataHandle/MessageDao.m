//
//  MessageDao.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "MessageDao.h"
#import "FMDatabase.h"
#import "MessageDBHandle.h"
#import "MessageModel.h"
#import "FMDatabaseQueue.h"
#import "MessageDateHandle.h"

@implementation MessageDao

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
        _dbHelper = [MessageDBHandle getSharedInstance];
    }
    return self;
}

- (void)addMessage:(MessageModel *)model{
    NSString *sql =[NSString stringWithFormat:@"INSERT INTO %@(userId,messageName,messageInfo,messageDate,messageImage,messageUrl,appId,isRead) VALUES ('%@','%@','%@','%@','%@','%@','%@','%ld')",@"messageinfo",model.userId,model.messageName ,model.messageInfo,model.messageDate,model.messageImage,model.messageUrl,model.appId,(long)model.isRead];
    [_dbHelper executeUpdate:sql];
}

- (void)delMessage:(MessageModel *)model{
    BOOL isExist = [self isExistMessageId:model.messageId];
    NSString *username = [self getUserId];
    if (isExist){
        NSString *sql =[NSString stringWithFormat:@"delete from %@ where messageId = %ld and userId = %@",@"messageinfo",model.messageId,username];
        [_dbHelper executeUpdate:sql];
    }
}

- (void)delAllMessage{
    NSString *sql =@"delete from messageinfo";
    [_dbHelper executeUpdate:sql];
}

- (void)updateMessage:(MessageModel *)model{
    BOOL isExist = [self isExistMessageId:model.messageId];
    NSString *username = [self getUserId];
    if (isExist){
        NSString *sql =[NSString stringWithFormat:@"update messageinfo set isRead='%ld' where messageId='%ld' and userId = '%@'",(long)model.isRead,(long)model.messageId,username];
        [_dbHelper executeUpdate:sql];
    }
    
}

- (NSInteger)getUnReadMessageCount{
    NSString *username = [self getUserId];
    NSString *sql = [NSString stringWithFormat:@"select * from messageinfo where isRead='1 ' and userId = '%@'",username];
    __block NSMutableArray *messageArray = [NSMutableArray new];
    [_dbHelper.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                MessageModel *messageModel = [[MessageModel alloc] init];
                messageModel.userId = [set stringForColumn:@"userId"];
                messageModel.messageId =[set intForColumn:@"messageId"];
                messageModel.messageName = [set stringForColumn:@"messageName"];
                messageModel.messageInfo = [set stringForColumn:@"messageInfo"];
                messageModel.messageDate = [MessageDateHandle conversionFromDate:[set stringForColumn:@"messageDate"]];
                messageModel.messageImage = [set stringForColumn:@"messageImage"];
                messageModel.messageUrl = [set stringForColumn:@"messageUrl"];
                messageModel.appId = [set stringForColumn:@"appId"];
                messageModel.isRead = [set intForColumn:@"isRead"];
                [messageArray addObject:messageModel];
            }
            [set close];
        }
        [db close];
        
    }];
    return [messageArray count];
}

- (NSInteger)getUnReadMessageCountWithAppId:(NSString *)appid{
    NSString *username = [self getUserId];
    NSString *sql = [NSString stringWithFormat:@"select * from messageinfo where isRead='1' and appId = '%@' and userId = '%@'",appid,username];
    __block NSMutableArray *messageArray = [NSMutableArray new];
    [_dbHelper.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                MessageModel *messageModel = [[MessageModel alloc] init];
                messageModel.userId = [set stringForColumn:@"userId"];
                messageModel.messageId =[set intForColumn:@"messageId"];
                messageModel.messageName = [set stringForColumn:@"messageName"];
                messageModel.messageInfo = [set stringForColumn:@"messageInfo"];
                messageModel.messageDate = [MessageDateHandle conversionFromDate:[set stringForColumn:@"messageDate"]];
                messageModel.messageImage = [set stringForColumn:@"messageImage"];
                messageModel.messageUrl = [set stringForColumn:@"messageUrl"];
                messageModel.appId = [set stringForColumn:@"appId"];
                messageModel.isRead = [set intForColumn:@"isRead"];
                [messageArray addObject:messageModel];
            }
            [set close];
        }
        [db close];
        
    }];
    return [messageArray count];
}


- (NSMutableArray *)getMessages{
    NSString *username = [self getUserId];
    NSString *sql = [NSString stringWithFormat:@"select *from %@ where userId = '%@' order by messageDate desc;",@"messageinfo",username];
    __block NSMutableArray *messageArray = [NSMutableArray new];
    [_dbHelper.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                MessageModel *messageModel = [[MessageModel alloc] init];
                messageModel.userId = [set stringForColumn:@"userId"];
                messageModel.messageId =[set intForColumn:@"messageId"];
                messageModel.messageName = [set stringForColumn:@"messageName"];
                messageModel.messageInfo = [set stringForColumn:@"messageInfo"];
                //                messageModel.messageDate = [set stringForColumn:@"messageDate"];
                messageModel.messageDate = [set stringForColumn:@"messageDate"];
                messageModel.messageImage = [set stringForColumn:@"messageImage"];
                messageModel.messageUrl = [set stringForColumn:@"messageUrl"];
                messageModel.appId = [set stringForColumn:@"appId"];
                messageModel.isRead = [set intForColumn:@"isRead"];
                [messageArray addObject:messageModel];
            }
            [set close];
        }
        [db close];
        
    }];
    return [messageArray copy];
}

- (NSArray *)getMessagesWithAppId:(NSString *)appid{
    NSString *username = [self getUserId];
    NSString *sql = [NSString stringWithFormat:@"select *from %@ where appId = %@ and userId = '%@'  order by messageDate desc;",@"messageinfo",appid,username];
    __block NSMutableArray *messageArray = [NSMutableArray new];
    [_dbHelper.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            while ([set next])
            {
                MessageModel *messageModel = [[MessageModel alloc] init];
                messageModel.userId = [set stringForColumn:@"userId"];
                messageModel.messageId =[set intForColumn:@"messageId"];
                messageModel.messageName = [set stringForColumn:@"messageName"];
                messageModel.messageInfo = [set stringForColumn:@"messageInfo"];
                messageModel.messageDate = [set stringForColumn:@"messageDate"];
                messageModel.messageImage = [set stringForColumn:@"messageImage"];
                messageModel.messageUrl = [set stringForColumn:@"messageUrl"];
                messageModel.appId = [set stringForColumn:@"appId"];
                messageModel.isRead = [set intForColumn:@"isRead"];
                [messageArray addObject:messageModel];
            }
            [set close];
        }
        [db close];
        
    }];
    return [messageArray copy];
}

- (BOOL)isExistMessageId:(NSInteger)messageId{
    NSString *username = [self getUserId];
    NSString *sql = [NSString stringWithFormat:
                     @"select count(*) from messageinfo where messageId ='%ld' and userId = '%@';",
                     (long)messageId,username];
    // executeQuery 主要用在select
    __block BOOL result = NO;
    [_dbHelper.queue inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet *set = [db executeQuery:sql];
            // set明显只有一条记录
            if (set)
            {
                [set next];
                // 返回第0列
                int c = [set intForColumnIndex:0];
                [set close];
                if(c > 0){
                    result = YES;
                }
            }
        }
        [db close];
    }];
    return result;
    
}

- (NSString *)getUserId{
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (!username || [username isEqualToString:@""]) {
        username = @"guest";
    }
    return username;
}


@end
