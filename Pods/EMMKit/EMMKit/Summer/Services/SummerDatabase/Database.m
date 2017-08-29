//
//  Database.m
//
//
//  Created by gct on 16/8/3.
//  Copyright © 2016年 yyuap. All rights reserved.
//
#import "Database.h"
#include <sqlite3.h>

@interface Database (PrivateMethods)

//
// sharedInstance
//
// 获取一个单例实例 Database 对象
//
// returns 返回 Database 对象
//
+ (Database *)sharedInstance;

//打开数据
- (BOOL)open;

-(BOOL) create;

//关闭数据
- (void)close;

//读取某一列的数据
- (id)reloadData:(sqlite3_stmt *)stmt column:(int)column;

@end

static Database *sharedDatabase = nil;

@implementation Database
{
@private
    sqlite3 *data;
    NSString *filePath;//当前db文件路径
}

+ (Database *)sharedInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [[self alloc] init];
    });
    
    return  sharedDatabase;
}

+ (Database *)databaseWithFile:(NSString *) file {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDatabase = [[self alloc] initWithFile:file];
        
    });
    sharedDatabase->filePath = file;
    [sharedDatabase open];
    
    return  sharedDatabase;
}

/*
 * 内部测试初始化
 */
- (id)init{
    self = [super init];
    if (self)
    {
        data = nil;
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0];
        filePath = [[NSString alloc] initWithString:[path stringByAppendingPathComponent:@"data.sqlite3"]];
        
        [self create];
    }
    return self;
}

/*
 * 初始化文件
 */
- (id)initWithFile:(NSString *) file{
    self = [super init];
    if (self) {
        data = nil;
        filePath = [[NSString alloc] initWithString:file];
    }
    return self;
}

- (BOOL)open
{
    if(sqlite3_open([filePath UTF8String], &data) != SQLITE_OK)
    {
        sqlite3_close(data);
#ifdef DEBUG
        NSString *msg = [NSString stringWithFormat:@"%s",sqlite3_errmsg(data)];
        NSException *exception = [NSException exceptionWithName:@"数据库打开错误" reason:msg userInfo:nil];
        @throw exception;
#endif
        return NO;
    }
    return YES;
}

-(BOOL) create
{

    if(sqlite3_open([filePath UTF8String], &data) != SQLITE_OK)
    {
        sqlite3_close(data);

        return NO;
    }
    if(data!=NULL)
    {
      sqlite3_close(data);
    }
    return YES;
    
}


- (void)close
{
    if (data != nil)
    {
        sqlite3_close(data);
        data = nil;
    }
}

- (id)reloadData:(sqlite3_stmt *)stmt column:(int)column{
    id object;
    switch (sqlite3_column_type(stmt,column))
    {
        case SQLITE_INTEGER:
            object = [NSNumber numberWithInt:sqlite3_column_int(stmt,column)];
            break;
        case SQLITE_FLOAT:
            object = [NSNumber numberWithDouble:sqlite3_column_double(stmt,column)];
            break;
        case SQLITE_BLOB:
            object = [NSData dataWithBytes:sqlite3_column_blob(stmt,column) length:sqlite3_column_bytes(stmt,column)];
            break;
        case SQLITE_NULL:
            object = [NSString stringWithFormat:@""];
            break;
        case SQLITE_TEXT:
            object = [NSString stringWithUTF8String:(char *) sqlite3_column_text(stmt,column)];
            break;
        default:
            object = [NSString stringWithFormat:@"提取错误"];
            break;
    }
    return object;
}

- (BOOL)execute:(NSString *) sql
{
    BOOL resultStatus = YES;
    @synchronized(self)
    {
        char *errMsg;
        //CLog(@"Database:%@",sql);
        [self open];
        if(sqlite3_exec(data, [sql UTF8String],NULL,NULL,&errMsg) != SQLITE_OK) {
            if (errMsg != NULL) {
//                NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",errMsg] stringByAppendingString:sql];
                sqlite3_free(errMsg);
                resultStatus = NO;
            }
        }else{
            resultStatus = YES;
            NSLog(@"SQL 执行成功！");
        }
        [self close];

    }
    
    return resultStatus;
}

- (NSArray *)getRows:(NSString *) sql
{
    return [self getRows:sql isSingleArray:FALSE];
}

- (NSArray *)getRows:(NSString *)sql isSingleArray:(BOOL)isSingleArray{
    NSMutableArray *table = nil;
    @synchronized(self)
    {
        sqlite3_stmt *stmt;
        NSException *exception = nil;
        table = [NSMutableArray array];
        [self open];
        if(sqlite3_prepare(data,[sql UTF8String],-1,&stmt,nil) == SQLITE_OK)
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                @autoreleasepool {
                    int col = sqlite3_column_count(stmt);
                    if (isSingleArray && col == 1)
                    {
                        [table addObject:[self reloadData:stmt column:0]];
                    }
                    else
                    {
                        NSMutableDictionary *row = [NSMutableDictionary dictionary];
                        for (int i=0; i<col; i++)
                        {
                            id k = [NSString stringWithCString:sqlite3_column_name(stmt,i) encoding:NSUTF8StringEncoding];
                            id v = [self reloadData:stmt column:i];
                            [row setObject:v forKey:k];
                        }
                        [table addObject:row];
                    }
                }
            }
            sqlite3_finalize(stmt);
        }
        else
        {
            NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",sqlite3_errmsg(data)] stringByAppendingString:sql];
            exception = [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
        }
        [self close];
        
#ifdef DEBUG
        if (exception != nil) {
            //@throw exception;
        }
#endif
    }
    return table;
}

- (id)getScalar:(NSString *)sql{
    NSArray *array = [self getRows:sql isSingleArray:TRUE];
    if ([array count]>0)
    {
        return [array objectAtIndex:0];
    }
    else{
        return [NSNumber numberWithInt:0];
    }
}

- (id)escapeString:(id)sql
{
    if ([sql isKindOfClass:[NSString class]])
    {
        return [sql stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    }
    else
    {
        return sql;
    }
}

-(BOOL)checkName:(NSString *)name{
    
    char *err;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",name];
    
    const char *sql_stmt = [sql UTF8String];
    [self open];
    if(sqlite3_exec(data, sql_stmt, NULL, NULL, &err) == 1){
        
        return YES;
        
    }else{
        
        return NO;
        
    }
    
}

- (void)dealloc {
    [self close];
}
@end
