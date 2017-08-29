//
//  SummerSQLiteService.m
//  SummerDemo
//
//  Created by 振亚 姜 on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//
#define kumsqliteversionkey @"summersqliteversionkey_"

#import "SummerSQLiteService.h"
#import "Database.h"
#import "SqliteDatabase.h"
#import "NSString+Util.h"
#import "summerInvocation.h"

@implementation SummerSQLiteService

+ (void)load {
    
    if (self == [SummerSQLiteService self]) {
        [SummerServices registerService:@"sqlite" class:@"SummerSQLiteService"];
        [SummerServices registerService:@"UMSQLite" class:@"SummerSQLiteService"];  // 兼容旧 Summer
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerSQLiteService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerSQLiteService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self class];
}

+(NSString *)checkTable:(SummerInvocation *)invocation{
    
    @try {
        
        [invocation check:@"db"];
        
        NSString * db = invocation.params[@"db"];
        NSString * table = invocation.params[@"table"];
        
        if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:table])
        {
            return @"false";
        }
        if([NSString trim:db].length==0 || [NSString trim:table].length==0)
        {
            return @"false";
        }
        
        NSString * isFindDB = [SummerSQLiteService exist:invocation];
        
        if(![@"true" isEqualToString:isFindDB])
        {
            return @"false";
        }
        
        SqliteDatabase * sqliteDatabse = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        
        if([sqliteDatabse isExistTable:table fromDatabase:dbPath])
        {
            
            return @"true";
        }
        
    } @catch (NSException *exception) {
        return @"false";
    }
    
    return @"false";
}

+(NSString *)openDB:(SummerInvocation *)invocation{
    
    @try {
        [invocation check:@"db"];
        NSString * db = invocation.params[@"db"];
        if([NSString isEmptyOrNil:db])
        {
            return @"false";
        }
        if([NSString trim:db].length==0)
        {
            return @"false";
        }
        if(![db hasSuffix:@".sqlite"] && ![db hasSuffix:@".db"] && ![db hasSuffix:@".sqlite3"])
        {
            return @"false";
        }
        NSArray * notAllowChars = @[@"/",@",",@"@",@"-",@"*",@"$",@"#",@"^",@"&",@")",@"!",@"$",@"?",@"=",@"%",@"\\",@"}",@"{",@"[",@"]",@"+"];
        
        for (NSString * charItem in notAllowChars)
        {
            if([db containsString:charItem])
            {
                return @"false";
            }
        }
        
        SqliteDatabase * sqliteDatabase = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        if([sqliteDatabase openDatabase:dbPath])
        {
            return @"true";
        }
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"false";
    }
    return @"false";
}


/*
 *  @brief	删除一个数据库
 *
 *	@param 	 db         数据库的文件名
 *
 */
+(void)deleteDB:(SummerInvocation *)invocation
{
    @try {
        [invocation check:@"db"];
        NSString * db = invocation.params[@"db"];
        if([NSString isEmptyOrNil:db])
        {
            return;
        }
        if([NSString trim:db].length==0)
        {
            return;
        }
        NSString * isFindDB = [SummerSQLiteService exist:invocation];
        
        if([@"true" isEqualToString:isFindDB])
        {
            SqliteDatabase * sqliteDatabse =  [SqliteDatabase shareInstance];
            NSString *dbPath = [SqliteDatabase getDatabasePath:db];
            [sqliteDatabse deleteDatabase:dbPath];
            
        }
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return; //防止退出
    }
}
/*
 *  @brief	执行一句SQL，无返回值
 *	@param 	 db         数据库的文件名(初始化后，使用初始的db，不用再写db)
 *           sql            SQL
 *
 */
+(NSString *) execSql:(SummerInvocation *)invocation
{
//    [invocation check:@"callback"];
    NSString * callback = invocation.params[@"callback"];
    
    if(![NSString isEmptyOrNil:callback])
    {
        __block __weak NSString *isOk;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            isOk = [[self class] doExecuteUpdate:invocation];
            if(isOk==nil)
            {
                isOk = @"unkown error";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:isOk];
            });
        });
        return isOk;
    }else{
        return [[self class] doExecuteUpdate:invocation];
    }
    
}

+(NSString *) doExecuteUpdate:(SummerInvocation *)invocation
{
    @try {
        
        @synchronized ([SummerSQLiteService class])
        {
            [invocation check:@"db"];
            [invocation check:@"sql"];
            
            NSString * db = invocation.params[@"db"];
            NSString * sql = invocation.params[@"sql"];
            
            if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:sql])
            {
                return @"db cannot be empty!";
            }
            if([NSString trim:db].length==0 || [NSString trim:sql].length==0)
            {
                return @"db cannot be empty!";
            }
            
            BOOL isBase64Str = [[self class] isBase64String:sql];
            
            if(isBase64Str)
            {
                NSData * base64Data = [[NSData alloc] initWithBase64EncodedString:sql options:NSDataBase64DecodingIgnoreUnknownCharacters];
                sql = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
            }
            
            NSString * dbPath = [SqliteDatabase getDatabasePath:db];
            SqliteDatabase * sqliteDatabase = [SqliteDatabase shareInstance];
            [sqliteDatabase executeUpdate:sql fromDatabase:dbPath];
            
//            XEventArgs *arg = [[XEventArgs alloc] init];
//            [arg putValue:db forKey:@"db"];
//            [arg putValue:@"0" forKey:@"version"];
            SummerInvocation *siv = [[SummerInvocation alloc] init];
            siv.params = [[NSDictionary alloc] initWithObjectsAndKeys:db,@"db",@"0",@"version", nil];            if([SummerSQLiteService getVersion:siv] == nil || [[SummerSQLiteService getVersion:siv] isEqualToString:@""])
            {
                [SummerSQLiteService setVersion:siv];
            }
        }
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"false";
    }
    return @"true";
    
}

/*
 * @brief	是否存在该数据库
 *
 * @param 	 db         数据库的文件名(初始化后，使用初始的db，不用再写db)
 *
 */
+(NSString *) exist:(SummerInvocation *)invocation
{
    [invocation check:@"db"];
    NSString * db = invocation.params[@"db"];
    
    if([NSString isEmptyOrNil:db])
    {
        return @"false";
    }
    
    db = [db stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(db.length==0 )
    {
        return @"false";
    }
    
    if(![db hasSuffix:@".sqlite"] && ![db hasSuffix:@".db"] && ![db hasSuffix:@".sqlite3"])
    {
        return @"false";
    }
    
    db = [db stringByReplacingOccurrencesOfString:@"/" withString:@""]; //替换掉 “/”，防止目录被删除
    
    NSString * dbPath = [SqliteDatabase getDatabasePath:db];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManager fileExistsAtPath:dbPath isDirectory:&isDir];
    
    if (isExist)
    {
        NSLog(@"数据库%@已被创建",db);
        return @"true";
    }
    else {
        NSLog(@"数据库%@未被创建",db);
        return @"false";
    }
}

+ (BOOL)isBase64String:(NSString *)src {
    
    if([NSString isEmptyOrNil:src] || (src.length % 4 != 0)) {
        return NO;
    }
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:src options:0];
    if (!decodedData) {
        return NO;
    }
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return (decodedString != nil);
}

/*
 *  @brief	执行一句SQL，有返回值，返回的结果转为JSON对象放到指定的Ctx路径
 *
 *	@param 	 db         数据库的文件名(初始化后，使用初始的db，不用再写db)
 *           sql            SQL
 *           content        返回的值绑到Ctx的路径
 *
 */
+(id)query:(SummerInvocation *)invocation
{
    NSString * callback = invocation.params[@"callback"];
    if(![NSString isEmptyOrNil:callback])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString * result = [SummerSQLiteService doQuery:invocation];
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:result];
            });
            
        });
        return @"[]";
    }else{
        
        return [SummerSQLiteService doQuery:invocation];
    }
    
}

+(NSString *) doQuery:(SummerInvocation *)invocation
{
    
    @try
    {
        [invocation check:@"db"];
        [invocation check:@"sql"];
        
        
        NSString * db   = invocation.params[@"db"];
        NSString * sql  = invocation.params[@"sql"];
        int startIndex  = [invocation.params[@"startIndex"] intValue];
        int endIndex    = [invocation.params[@"endIndex"] intValue];
        
        if(endIndex-startIndex<=0)
        {
            endIndex = (int)NSIntegerMax;
        }
        if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:sql])
        {
            return @"[]";
        }
        if([NSString trim:db].length==0 || [NSString trim:sql].length==0)
        {
            return @"[]";
        }
        
        if(sql!=nil && sql.length>4)
        {
            BOOL isBase64Str = [[self class] isBase64String:sql];
            
            if(isBase64Str)
            {
                NSData * base64Data = [[NSData alloc] initWithBase64EncodedString:sql options:NSDataBase64DecodingIgnoreUnknownCharacters];
                sql = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
            }
        }
        
        SqliteDatabase * dataBase =[SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        NSArray * resultset = [dataBase query:sql fromDatabase:dbPath];
        
        if(resultset&&[resultset isKindOfClass:[NSArray class]])
        {
            if(resultset.count<endIndex)
            {
                endIndex = (int)resultset.count - 1;
            }
            int len = endIndex - startIndex + 1;
            NSArray * subResult =  [resultset subarrayWithRange:NSMakeRange(startIndex, abs(len))];
            if(subResult!=nil)
            {
                NSData *data = [NSJSONSerialization dataWithJSONObject:subResult options:0 error:nil];
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
        
    }
    @catch(NSException *e)
    {
        NSLog(@"e=%@",e);
        return @"[]";
    }
    return @"[]";
    
}



+(id)queryByPage:(SummerInvocation *)invocation{
    
    NSString * callback = invocation.params[@"callback"];
    
    if(![NSString isEmptyOrNil:callback])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString * result = [SummerSQLiteService doQueryPage:invocation];
//            [args putValue:result forKey:@"queryResult"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:result];
            });
            
        });
        return @"[]";
    }else{
        
        return [SummerSQLiteService doQueryPage:invocation];
    }
    
    
}

+(NSString *) doQueryPage:(SummerInvocation *)invocation
{
    @try{
        @synchronized ([SummerSQLiteService class])
        {
            
            NSString * db = invocation.params[@"db"];
            NSString * sql = invocation.params[@"sql"];
            NSString * pageIndex = invocation.params[@"pageIndex"];
            NSString * pageSize = invocation.params[@"pageSize"];
            
            if([pageSize integerValue]==0)
            {
                
                pageSize = [NSString stringWithFormat:@"%ld",NSIntegerMax];
            }
            if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:sql])
            {
                return @"[]";
            }
            if([NSString trim:db].length==0 || [NSString trim:sql].length==0)
            {
                return @"[]";
            }
            
            if(sql!=nil && sql.length>4)
            {
                BOOL isBase64Str = [[self class] isBase64String:sql];
                
                if(isBase64Str)
                {
                    NSData * base64Data = [[NSData alloc] initWithBase64EncodedString:sql options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    sql = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
                }
            }
            
            if ([sql hasSuffix:@";"]) {
                sql = [sql stringByReplacingOccurrencesOfString:@";" withString:@""];
            }
            
            sql = [NSString stringWithFormat:@"%@ limit %@ offset %@ * %@;",sql,pageSize,pageIndex,pageSize];
            
            SqliteDatabase * sqliteDB =  [SqliteDatabase shareInstance];
            NSString * dbPath = [SqliteDatabase getDatabasePath:db];
            
            NSArray * resultSet = [sqliteDB query:sql fromDatabase:dbPath];
            
            if(resultSet!=nil)
            {
                NSData *data = [NSJSONSerialization dataWithJSONObject:resultSet options:0 error:nil];
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
    }@catch(NSException * e){
        NSLog(@"exception=%@",e);
        return @"[]";
    }
    
    return  @"[]";
    
}

+(id) queryTable:(SummerInvocation *)invocation
{
    
    NSString * callback = invocation.params[@"callback"];
    
    if(![NSString isEmptyOrNil:callback])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString * result = [SummerSQLiteService doQueryTable:invocation];
//            [args putValue:result forKey:@"queryResult"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:result];
            });
            
        });
        return @"[]";
    }else{
        
        return [SummerSQLiteService doQueryTable:invocation];
    }
    
}

+(NSString *)doQueryTable:(SummerInvocation *)invocation
{
    
    @try {
        
        @synchronized ([SummerSQLiteService class])
        {

            NSString * db = invocation.params[@"db"];
            NSString * table = invocation.params[@"table"];
            NSString * pageIndex = invocation.params[@"pageIndex"];
            NSString * pageSize = invocation.params[@"pageSize"];
            NSString * condition = invocation.params[@"condition"];
            NSString * fields = invocation.params[@"fields"];
            
            if([pageSize integerValue]==0)
            {
                
                pageSize = @"10";
            }
            
            if([pageIndex integerValue]==0)
            {
                pageIndex = @"0";
            }
            
            
            if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:table])
            {
                return @"[]";
            }
            if([NSString trim:db].length==0 || [NSString trim:table].length==0)
            {
                return @"[]";
            }
            
            NSString * sql = @"SELECT ";
            
            if([NSString isEmptyOrNil:fields] || [NSString trim:fields].length==0)
            {
                sql = [sql stringByAppendingString:@" * "];
            }else{
                NSArray * fieldArr = [NSJSONSerialization JSONObjectWithData:[sql dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                sql = [sql stringByAppendingString:[fieldArr componentsJoinedByString:@","]];
            }
            sql = [sql stringByAppendingString:@" where 1=1 "];
            
            if(![NSString isEmptyOrNil:condition]&&[NSString trim:condition].length!=0)
            {
                
                BOOL isBase64Str = [[self class] isBase64String:condition];
                
                if(isBase64Str)
                {
                    NSData * base64Data = [[NSData alloc] initWithBase64EncodedString:sql options:NSDataBase64DecodingIgnoreUnknownCharacters];
                    condition = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
                }
                
                sql = [sql stringByAppendingString:condition];
            }
            
            NSString * limit = [NSString stringWithFormat:@" limit %@ ,%@ ;",pageIndex,pageSize];
            sql = [sql stringByAppendingString:limit];
            
            SqliteDatabase * sqliteDB =  [SqliteDatabase shareInstance];
            NSString * dbPath = [SqliteDatabase getDatabasePath:db];
            
            NSArray * resultSet = [sqliteDB query:sql fromDatabase:dbPath];
            
            if(resultSet!=nil)
            {
                NSData *data = [NSJSONSerialization dataWithJSONObject:resultSet options:0 error:nil];
                return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            
        }
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"[]";
    }
    
    return @"[]";
    
    
}

+(NSString *) closeDB:(SummerInvocation *)invocation
{
    @try {
        
        
        NSString * db = invocation.params[@"db"];
        if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length==0)
        {
            return @"false";
        }
        
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        [sqliteDB closeDatabase:dbPath];
        
    } @catch (NSException *exception) {
        return @"false";
    }
    
    return @"false";
    
}


+(NSString *) begin:(SummerInvocation *)invocation
{
    
    @try {
        
        NSString * db = invocation.params[@"db"];
        if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length==0)
        {
            return @"false";
        }
        
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        [sqliteDB beginTransaction:dbPath];
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"false";
    }
    
    return @"true";
    
}

+(NSString *) commit:(SummerInvocation *)invocation
{
    
    @try {
        
        NSString * db = invocation.params[@"db"];
        if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length==0)
        {
            return @"false";
        }
        
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        [sqliteDB commitTransaction:dbPath];
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"false";
    }
    
    return @"true";
    
}

+(NSString *) rollback:(SummerInvocation *)invocation
{
    
    @try {
        
        NSString * db = invocation.params[@"db"];
        if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length==0)
        {
            return @"false";
        }
        
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        [sqliteDB rollbackTransaction:dbPath];
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"false";
    }
    
    return @"true";
    
}
+(NSString *) getTableFields:(SummerInvocation *)invocation
{
    
    NSString * db = invocation.params[@"db"];
    NSString * table = invocation.params[@"table"];
    
    if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:table])
    {
        return @"[]";
    }
    if([NSString trim:db].length==0 || [NSString trim:table].length==0)
    {
        return @"[]";
    }
    
    @try {
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        NSArray * tableInfo =  [sqliteDB fetchFieldsName:table fromDatabase:dbPath];
        if(tableInfo!=nil)
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:tableInfo options:0 error:nil];
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        
        return @"[]";
    }
    return @"[]";
}

+(NSString *) getAffectRowCount:(SummerInvocation *)invocation
{
    @try {

        NSString * db = invocation.params[@"db"];
        
        if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length==0)
        {
            return @"[]";
        }
        
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        int changesRowNumber =  [sqliteDB fetchNumberOfAffectedRows:dbPath];
        
        return [NSString stringWithFormat:@"%d",changesRowNumber];
        
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"0";
    }
    return @"0";
    
    
}

-(NSString *) getLastInsertId:(SummerInvocation *)invocation
{
    
    @try {
        
        NSString * db = invocation.params[@"db"];
        
        if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length)
        {
            return @"[]";
        }
        
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        long changesRowNumber =  [sqliteDB lastInsertId:dbPath];
        
        return [NSString stringWithFormat:@"%ld",changesRowNumber];
        
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        return @"0";
    }
    return @"0";
    
}

+(NSString*) getTableFieldsInfo:(SummerInvocation *)invocation
{

    NSString * db = invocation.params[@"db"];
    NSString * table = invocation.params[@"table"];
    
    if([NSString isEmptyOrNil:db] || [NSString isEmptyOrNil:table])
    {
        return @"[]";
    }
    if([NSString trim:db].length==0 || [NSString trim:table].length==0)
    {
        return @"[]";
    }
    
    @try {
        SqliteDatabase * sqliteDB = [SqliteDatabase shareInstance];
        NSString * dbPath = [SqliteDatabase getDatabasePath:db];
        NSArray * tableInfo =  [sqliteDB fetchFieldsName:table fromDatabase:dbPath];
        if(tableInfo!=nil)
        {
            NSData *data = [NSJSONSerialization dataWithJSONObject:tableInfo options:0 error:nil];
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"exception=%@",exception);
        
        return @"[]";
    }
    return @"[]";
}



+(NSString *)getDBPath:(NSString *)dbName
{
    
    NSString * dbPath = [SqliteDatabase getDatabasePath:dbName];
    
    if([NSString isEmptyOrNil:dbPath])
    {
        return @"";
    }
    return dbPath;
}

+(NSString *) getPath:(SummerInvocation *)invocation
{
    
    NSString * db = invocation.params[@"db"];
    if([NSString isEmptyOrNil:db] ||  [NSString trim:db].length==0)
    {
        return @"";
    }
    NSString * dbPath =  [[self class] getDBPath:db];
    
    if([@"true" isEqualToString:[self exist:invocation]])
    {
        return dbPath;
    }
    
    return @"";
}

+(NSString *)getVersion:(SummerInvocation *)invocation
{
    NSString *db = invocation.params[@"db"];
    NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",kumsqliteversionkey,db]];
    return version;
}

+(NSString *)setVersion:(SummerInvocation *)invocation
{
    NSString *db = invocation.params[@"db"];
    NSString *version = invocation.params[@"version"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:[NSString stringWithFormat:@"%@%@",kumsqliteversionkey,db]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return @"success";
}


@end
