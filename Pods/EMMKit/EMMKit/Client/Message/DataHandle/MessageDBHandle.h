//
//  MessageDBHandle.h
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMDatabaseQueue;
@class FMDatabase;
@class FMResultSet;

@interface MessageDBHandle : NSObject
@property (nonatomic,strong) FMDatabaseQueue *queue;

+(MessageDBHandle *)getSharedInstance;

- (void)initTable;
- (BOOL)executeUpdate:(NSString *)strSql;
- (BOOL)executeUpdate:(NSString *)strSql withArgumentsInArray:(NSArray *)arguments;

@end
