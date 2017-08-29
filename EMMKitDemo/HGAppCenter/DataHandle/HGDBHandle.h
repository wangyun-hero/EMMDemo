//
//  HGDBHandle.h
//  EMMKitDemo
//
//  Created by zm on 16/8/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@class FMDatabase;
@class FMResultSet;

@interface HGDBHandle : NSObject

@property (nonatomic,strong) FMDatabaseQueue* queue;

+(HGDBHandle *)sharedInstance;

- (void)creatTable;
- (BOOL)executeUpdate:(NSString *)strSql;
- (BOOL)executeUpdate:(NSString *)strSql withArgumentsInArray:(NSArray *)arguments;

@end
