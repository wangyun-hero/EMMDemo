//
//  MessageDao.h
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageDBHandle;
@class MessageModel;

@interface MessageDao : NSObject

@property(nonatomic, strong) MessageDBHandle *dbHelper;

+ (id)sharedInstance;

- (void)addMessage:(MessageModel *)model;
- (void)delMessage:(MessageModel *)model;
- (void)delAllMessage;
- (void)updateMessage:(MessageModel *)model;

- (NSMutableArray *)getMessages;
- (NSArray *)getMessagesWithAppId:(NSString *)appid;
//查询所有未读消息数
- (NSInteger)getUnReadMessageCount;
//根据appid查询未读消息数
- (NSInteger)getUnReadMessageCountWithAppId:(NSString *)appid;

- (BOOL)isExistMessageId:(NSInteger)messageId;
@end
