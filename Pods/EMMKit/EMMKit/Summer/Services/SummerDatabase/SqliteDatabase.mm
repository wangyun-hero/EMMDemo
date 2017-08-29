
//
//  SqliteDatabase.h
//  UMIOSControls
//
//  Created by jiangzy on 16/8/3.
//  Copyright © 2016年 yyuap. All rights reserved.
//

#import "SqliteDatabase.h"
#import "SparseDictionary.h"
#include <sqlite3.h>

@interface DBInfo : NSObject
@property(nonatomic,strong) NSString * dbPath;
@property(nonatomic,assign) sqlite3 * db;
@property(nonatomic,strong) NSString * dbName;
@property(nonatomic,assign) BOOL isOpened;
@property(nonatomic,assign) BOOL isOpenedTransaction;
-(instancetype) initWidthDBName:(NSString *) path forSQLite:(sqlite3 *) db;
@end
@implementation DBInfo
-(instancetype) initWidthDBName:(NSString *) path forSQLite:(sqlite3 *) db
{
    
    self = [super init];
    
    if(self)
    {
        
        _dbPath = path;
        _db = db;
        _dbName = [path lastPathComponent];
        _isOpened = NO;
        _isOpenedTransaction = NO;
        
    }
    return self;
}
@end


@interface SqliteDatabase()
-(instancetype) init;
@property(nonatomic,strong) NSMutableDictionary * sqliteDBInfos;
@property(nonatomic,strong) NSString * defaultDBPath;
-(void) createDefaultDatabase;
-(void) deleteDefaultDatabase;
@end
@implementation SqliteDatabase
-(instancetype) init
{
    self = [super init];
    
    if(self!=nil)
    {
        _sqliteDBInfos = [NSMutableDictionary dictionary];
        
        sqlite3_initialize();
        [self performSelector:@selector(createDefaultDatabase) withObject:nil];
        
    }
    return self;
}
-(void) createDefaultDatabase
{
    
    NSArray *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * dbPath = [path[0] stringByAppendingPathComponent:@"UMDatabaseStorages"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        
        NSError * error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    _defaultDBPath = [dbPath stringByAppendingPathComponent:@"default_local_db_storage.sqlite3"];
    [self openOrCreateDatabase:_defaultDBPath];
}

+(NSString *) getDatabasePath:(NSString *) dbName
{

    NSArray *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * dbPath = [path[0] stringByAppendingPathComponent:@"UMDatabaseStorages"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        
        NSError * error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dbPath withIntermediateDirectories:YES attributes:nil error:&error];
        
    }
    return [dbPath stringByAppendingPathComponent:dbName];

}
+(instancetype) shareInstance
{
    static SqliteDatabase * instance;
    static dispatch_once_t  onceToken = 0;
    
    dispatch_once(&onceToken, ^(void){
        
        instance = [[SqliteDatabase alloc] init];
        
    });
    
    return instance;
}

//- (BOOL)createDatabase:(NSString *) nsFile
//{
//    sqlite3 * db;
//    const char *filename = [nsFile  UTF8String];
//    
//    int rc = sqlite3_open_v2(filename, &db, SQLITE_OPEN_READWRITE |
//                             
//                             SQLITE_OPEN_CREATE, NULL );
//    
//    if (rc != SQLITE_OK)
//    {
//        NSLog(@"数据库创建失败");
//        return NO;
//    }
//    if(db!=NULL)
//    {
//        sqlite3_close(db);
//    }
//    NSLog(@"数据库创建成功,位置:%@",nsFile);
//    return YES;
//}

-(BOOL) openDatabase:(NSString *)dbPath {
    DBInfo* dbInfo = [self openOrCreateDatabase:dbPath];
    return dbInfo!=nil;
}

-(BOOL) dbIsOpened:(NSString *) nsFile
{
    DBInfo * dbInfo = _sqliteDBInfos[[nsFile lastPathComponent]];
    if(dbInfo!=nil && dbInfo.isOpened && dbInfo.db!=NULL)
    {
        return YES;
    }
    
    return false;
}

-(BOOL) defaultDbIsOpened
{
    return [self dbIsOpened:_defaultDBPath];
}

-(DBInfo*) openOrCreateDatabase:(NSString *) nsFile
{
    sqlite3 * db;
    DBInfo * dbInfo = _sqliteDBInfos[[nsFile lastPathComponent]];
    if(dbInfo!=nil && dbInfo.isOpened && dbInfo.db!=NULL)
    {
        sqlite3_close(dbInfo.db);
        dbInfo.db = NULL;
        dbInfo.isOpened = NO;
        NSLog(@"重新打开数据库");
    }
    
    const char *filename = [nsFile  UTF8String];
    
    int rc = sqlite3_open_v2(filename, &db, SQLITE_OPEN_READWRITE |
                             
                             SQLITE_OPEN_CREATE, NULL );
    
    if (rc != SQLITE_OK) {
        if(db!=NULL)
        {
            sqlite3_close(db);
        }
        NSLog(@"数据库打开失败");
        return nil;
    }
    if(dbInfo==nil)
    {
        dbInfo = [[DBInfo alloc] initWidthDBName:nsFile forSQLite:db];
    }else{
        dbInfo.db = db;
    }
    [_sqliteDBInfos setObject:dbInfo forKey:[nsFile lastPathComponent]];
    dbInfo.isOpened = YES;
    
    return dbInfo;
}
-(BOOL) openDefaultDatabase
{
    return [self openOrCreateDatabase:_defaultDBPath]!=nil;
}
-(BOOL) beginTransaction:(NSString *) dbPath
{
    
    DBInfo * dbInfo = [self getDBInfoByDBPath:dbPath];
    char *errorMsg;
    NSException *exception = nil;
    
    if(dbInfo.isOpenedTransaction)
    {
        NSLog(@"事务已经开启，无需重复开启！");
        return YES;
    }
    
    if (sqlite3_exec(dbInfo.db, "BEGIN", NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        if (errorMsg != NULL)
        {
            
            sqlite3_free(errorMsg);
            NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",errorMsg] stringByAppendingString:@"Begin Transaction"];
            exception = [NSException exceptionWithName:@"ExectueError" reason:msg userInfo:nil];
            @throw exception;
        }
        NSLog(@"事务开启失败");
        return NO;
        
    }
    NSLog(@"事务成功开启");
    dbInfo.isOpenedTransaction = YES;
    return YES;
}
-(BOOL) beginTransaction
{
    return [self beginTransaction:_defaultDBPath];
}
-(BOOL) commitTransaction:(NSString *) dbPath
{
    DBInfo * dbInfo = [self getDBInfoByDBPath:dbPath];
    char *errorMsg;
    NSException *exception = nil;

    if(!dbInfo.isOpenedTransaction)
    {
        NSLog(@"数据库未开启事务，无需Commit");
        return YES;//事务操作未开启
    }
    
    if (sqlite3_exec(dbInfo.db, "COMMIT", NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        if (errorMsg != NULL)
        {
            
            sqlite3_free(errorMsg);
            NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",errorMsg] stringByAppendingString:@"COMMIT Transaction"];
            exception = [NSException exceptionWithName:@"ExectueError" reason:msg userInfo:nil];
            @throw exception;
        }
        NSLog(@"数据库Commit失败");
        return NO;
        
    }
    NSLog(@"数据库Commit成功");
    dbInfo.isOpenedTransaction = NO;
    return YES;
}
-(BOOL) commitTransaction
{
    return [self commitTransaction:_defaultDBPath];
}
-(BOOL) rollbackTransaction:(NSString *) dbPath
{
    DBInfo * dbInfo = [self getDBInfoByDBPath:dbPath];
    char *errorMsg;
    NSException *exception = nil;
    
    if(!dbInfo.isOpenedTransaction)
    {
        NSLog(@"数据库未开启事务，无需回滚");
        return YES;//事务操作未开启
    }
    
    if (sqlite3_exec(dbInfo.db, "ROLLBACK", NULL, NULL, &errorMsg)!=SQLITE_OK)
    {
        if (errorMsg != NULL)
        {
            
            sqlite3_free(errorMsg);
            NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",errorMsg] stringByAppendingString:@"COMMIT Transaction"];
            exception = [NSException exceptionWithName:@"ExectueError" reason:msg userInfo:nil];
            @throw exception;
        }
        NSLog(@"数据库事务回滚失败");
        return NO;
        
    }
    NSLog(@"数据库事务回滚成功");
    dbInfo.isOpenedTransaction = NO;
    return YES;
}
-(BOOL) rollbackTransaction
{
    return [self rollbackTransaction:_defaultDBPath];
}
/**
 *@brief执行非查询sql
 *
 *@param sql - sql语句
 */
- (void)executeUpdate:(NSString *)sql fromDatabase:(NSString *) dbPath {
    
    @synchronized(self) {
        char *errMsg;
        NSException *exception = nil;
        DBInfo * dbInfo =  [self getDBInfoByDBPath:dbPath];
        
        if(sqlite3_exec(dbInfo.db, [sql UTF8String],NULL,NULL,&errMsg) != SQLITE_OK) {
            if (errMsg != NULL) {
                NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",errMsg] stringByAppendingString:sql];
                exception = [NSException exceptionWithName:@"ExectueError" reason:msg userInfo:nil];
                sqlite3_free(errMsg);
                @throw exception;
            }
        }
        NSLog(@"执行成功:%@",sql);
    }
}


- (void)executeUpdate:(NSString *)sql
{
    [self executeUpdate:sql fromDatabase:_defaultDBPath];
}


- (void)insertTable:(NSString *)tableName tableData:(NSDictionary *) dict fromDatabase:(NSString *) dbPath {
    
    if(dict==nil || dict.count==0)
    {
        return;
    }
    @synchronized(self)
    {
        NSException *exception = nil;
        
        DBInfo * dbInfo =  [self getDBInfoByDBPath:dbPath];
        
        NSArray * columns = [self fetchFieldsName:tableName fromDatabase:dbPath];
        SparseDictionary * keyValueEntry = [SparseDictionary initWidthDictionary:dict];
        //防止字典排序，使用无序的SparseDictionary
        
        for (NSString *key in keyValueEntry.keys)
        {
            if([columns indexOfObject:key]==NSNotFound)
            {
                
                exception = [NSException exceptionWithName:@"ErrorFields" reason:[@"不存在的字段>>" stringByAppendingString:key] userInfo:nil];
                @throw exception;
            }
        }
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO %@( ",tableName];
        
        
        NSString *values = @" values (";
        for(NSString * key in  keyValueEntry.keys)
        {
            if(![key isEqualToString:dict.allKeys.lastObject])
            {
                sql  = [sql stringByAppendingString:[NSString stringWithFormat:@" '%@' ,",key]];
                values  = [values stringByAppendingString:@" ? ,"];
            }else{
                sql  = [sql stringByAppendingString:[NSString stringWithFormat:@" '%@' ) ",key]];
                values  = [values stringByAppendingString:@" ? );"];
            }
        }
        sql = [NSString stringWithFormat:@"%@ %@",sql,values];
        
        sqlite3_stmt *stmt;
        
        if (sqlite3_prepare_v2(dbInfo.db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            
            NSArray * fieldsInfos = [self fetchFieldsInfo:tableName fromDatabase:dbPath];
            [self bindToStatement:stmt values:keyValueEntry useFieldsInfo:fieldsInfos forDepth:0];
            
            
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                const char * errorMSG = sqlite3_errmsg(dbInfo.db);
                int errorCode = sqlite3_errcode(dbInfo.db);
                
                NSString *msg = [[NSString stringWithFormat:@"errorCode=%d,error=%s\nSQL=",errorCode,errorMSG] stringByAppendingString:sql];
                exception = [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
                sqlite3_free(&errorMSG);
            }
        }else{
            NSLog(@"插入数据错误");
            const char * errorMSG = sqlite3_errmsg(dbInfo.db);
            int errorCode = sqlite3_errcode(dbInfo.db);
            
            NSString *msg = [[NSString stringWithFormat:@"errorCode=%d,error=%s\nSQL=",errorCode,errorMSG] stringByAppendingString:sql];
            exception = [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
            sqlite3_free(&errorMSG);
        }
        if(stmt!=NULL) {
            sqlite3_finalize(stmt);
        }
        
        if(exception!=nil) {
            @throw exception;
        }
    }
}
/**
 * 批量插入
 *
 * NSArray<NSString> fields 是一维数组,为了防止错误插入，这里filed不允许默认空缺
 * NSArray<NSArray> values 是二维数组,并且每一维数组的长度必须相同，否则可能引起致命错误
 *
 */
- (void)insertTable:(NSString *)tableName fields:(NSArray *) fields values:(NSArray *) values fromDatabase:(NSString *) dbPath
{
    if(fields == nil || fields.count==0 ||  values==nil || values.count==0)
    {
        return;
    }
    
    @synchronized(self)
    {
        NSException *exception = nil;
        
        DBInfo * dbInfo = [self getDBInfoByDBPath:dbPath];
        NSArray * columns = [self fetchFieldsName:tableName fromDatabase:dbPath];
        for (NSString *key in fields)
        {
            if([columns indexOfObject:key]==NSNotFound)
            {
                
                exception = [NSException exceptionWithName:@"ErrorFields" reason:[@"不存在的字段>>" stringByAppendingString:key] userInfo:nil];
                @throw exception;
            }
        }
        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO %@( ",tableName];
        NSString * valueStr = @" values";
        
        
        for (NSString *key in fields) {
            
            if(![key isEqualToString:fields.lastObject])
            {
                sql  = [sql stringByAppendingString:[NSString stringWithFormat:@" '%@' ,",key]];
            }else{
                sql  = [sql stringByAppendingString:[NSString stringWithFormat:@" '%@' )",key]];
                
            }
        }
        
        NSMutableArray * dataArrayDict = [NSMutableArray array];
        SparseDictionary * keyValueSparseDict = nil;
        
        for (int i=0;i<values.count;i++)
        {
            valueStr = [valueStr stringByAppendingString:@" ("];
            keyValueSparseDict = [[SparseDictionary alloc] init];
            for (int j=0;j<fields.count;j++)
            {
                if(j<fields.count-1)
                {
                    valueStr = [valueStr stringByAppendingString:@" ?,"];
                }else{
                    valueStr = [valueStr stringByAppendingString:@" ? "];
                }
                
                [keyValueSparseDict putValue:values[i][j] Key:fields[j]];
            }
            valueStr = [valueStr stringByAppendingString:@")"];
            
            if(i<values.count-1)
            {
                valueStr = [valueStr stringByAppendingString:@","];
            }else{
                
                valueStr = [valueStr stringByAppendingString:@";"];
            }
            
            [dataArrayDict addObject:keyValueSparseDict];
        }
        
        sql = [NSString stringWithFormat:@" %@ %@",sql,valueStr];
        
        sqlite3_stmt *stmt;
        
        if (sqlite3_prepare_v2(dbInfo.db, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK) {
            
            
            NSArray * fieldsInfos = [self fetchFieldsInfo:tableName fromDatabase:dbPath];
            int k = 0;
            for (SparseDictionary * dict in dataArrayDict)
            {
                [self bindToStatement:stmt values:dict useFieldsInfo:fieldsInfos forDepth:k];
                k++;
            }
            
            if (sqlite3_step(stmt) != SQLITE_DONE) {
                
                NSLog(@"插入数据错误");
                const char * errorMSG = sqlite3_errmsg(dbInfo.db);
                int errorCode = sqlite3_errcode(dbInfo.db);
                
                NSString *msg = [[NSString stringWithFormat:@"errorCode=%d,error=%s\nSQL=",errorCode,errorMSG] stringByAppendingString:sql];
                exception = [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
                sqlite3_free(&errorMSG);
            }
        }else{
            
            NSLog(@"插入数据错误");
            const char * errorMSG = sqlite3_errmsg(dbInfo.db);
            int errorCode = sqlite3_errcode(dbInfo.db);
            
            NSString *msg = [[NSString stringWithFormat:@"errorCode=%d,error=%s\nSQL=",errorCode,errorMSG] stringByAppendingString:sql];
            exception = [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
            sqlite3_free(&errorMSG);
        }
        if(stmt!=NULL)
        {
            sqlite3_finalize(stmt);
        }
        
        if(exception!=nil)
        {
            
            @throw exception;
        }
        
        
    }
}
-(NSArray *) sortKeyForSQL:(NSArray *) values fields:(NSArray *) fields
{
    if(values==nil || fields==nil)
    {
        return fields;
    }
    NSMutableDictionary * tempSortDict = [NSMutableDictionary dictionaryWithObjects:values forKeys:fields];
    return tempSortDict.allKeys;//进行字典排序，防止key=value与sql语句不对称问题
}
- (void)insertTable:(NSString *)tableName fields:(NSArray *) fields values:(NSArray *) values
{
    [self insertTable:tableName fields:fields values:values fromDatabase:_defaultDBPath];
}
- (void)insertTable:(NSString *) tableName tableData:(NSDictionary *) dict
{
    [self insertTable:tableName tableData:dict fromDatabase:_defaultDBPath];
}
-(void) bindToStatement:(sqlite3_stmt *)stmt values:(SparseDictionary *) dict useFieldsInfo:(NSArray *) filedsInfo forDepth:(int)depIndex
{
    
    if(filedsInfo==nil || dict==nil)
    {
        return;
    }
    NSMutableDictionary *fieldInfoDict = [NSMutableDictionary dictionary];
    
    for (NSDictionary * fieldInfo in filedsInfo) {
        
        fieldInfoDict[fieldInfo[@"name"]] = fieldInfo;
    }
    
    for( int i=0;i< [dict size];i++)
    {
        NSString * key  = [(NSString *)dict.keys[i] lowercaseString];
        int index = (int)(i+(depIndex*[dict size]))+1; //数据库索引从1开始
        
        NSString * fieldType = [fieldInfoDict[key][@"type"] lowercaseString];
        
        NSLog(@"bindIndex=%d,key=%@,value=%@,type=%@",index,key,[dict getValueOfKey:key],fieldType);
        
        if([@"integer" isEqualToString:fieldType]||[@"int" isEqualToString:fieldType]||[@"biginteger" isEqualToString:fieldType] || [fieldType hasPrefix:@"int("])
        {
            sqlite3_bind_int(stmt, index, [(NSString *)[dict getValueOfKey:key] intValue]);
            
        }
        else if([@"float" isEqualToString:fieldType]||[@"double" isEqualToString:fieldType]|| [@"real" isEqualToString:fieldType]|| [@"decimal" isEqualToString:fieldType])
        {
            sqlite3_bind_double(stmt, index, [(NSString *)[dict getValueOfKey:key] floatValue]);
            
        }
        else if([@"blob" isEqualToString:fieldType] )
        {   NSData * data = (NSData *)[dict getValueOfKey:key];
            sqlite3_bind_blob(stmt, index, data.bytes, (int)data.length, SQLITE_STATIC);
        }
        else if([@"varchar" isEqualToString:fieldType]||[@"text" isEqualToString:fieldType] || [fieldType hasPrefix:@"varchar("])
        {
            NSString * nsSqlText  = (NSString *)[dict getValueOfKey:key];
            const char* sqlText = [nsSqlText UTF8String];
            sqlite3_bind_text(stmt,index, sqlText,-1, SQLITE_STATIC);
            
        }else{
            sqlite3_value *p = (__bridge sqlite3_value *)[dict getValueOfKey:key];
            sqlite3_bind_value(stmt, index,p);
            
        }
        
        
    }
    
}
-(NSArray *)fetchFieldsName:(NSString *) tableName fromDatabase:(NSString *)dbPath
{
    NSArray * tableFieldsInfo = [self fetchFieldsInfo:tableName fromDatabase:dbPath];
    NSMutableArray * tableNameArray = [NSMutableArray array];
    if(tableFieldsInfo!=nil)
    {
        [tableFieldsInfo enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:[NSDictionary class]])
            {
                
                [tableNameArray addObject:[obj objectForKey:@"name"]];
            }
        }];
    }
    
    return tableNameArray;
}
-(NSArray *)fetchFieldsName:(NSString *) tableName
{
    
    return [self fetchFieldsName:tableName fromDatabase:_defaultDBPath];
}
-(NSArray *)fetchFieldsInfo:(NSString *) tableName fromDatabase:(NSString *)dbPath
{
    NSString * sql = [NSString stringWithFormat:@"PRAGMA TABLE_INFO('%@')",tableName];
    NSLog(@"SQL-Lang:%@",sql);
    NSMutableArray *table  = [NSMutableArray array];
    @synchronized(self)
    {
        sqlite3_stmt *stmt;
        
        NSException *exception = nil;
        
        DBInfo * dbInfo =  [self getDBInfoByDBPath:dbPath];
        
        if(sqlite3_prepare_v2(dbInfo.db,[sql UTF8String],-1,&stmt,nil) == SQLITE_OK)
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                @autoreleasepool {
                    int col = sqlite3_column_count(stmt);
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
            sqlite3_finalize(stmt);
        }
        else
        {
            
            NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",sqlite3_errmsg(dbInfo.db)] stringByAppendingString:sql];
            exception = [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
            @throw exception;
        }
        
    }
    return table;
}
-(NSArray *)fetchFieldsInfo:(NSString *) tableName
{
    return [self fetchFieldsInfo:tableName fromDatabase:_defaultDBPath];
}

/**
    根据dbPath打开数据库，如果已经打开则直接返回，如果没有打开则打开
    尽可能保障dbInfo的可用性，实在无法保障时，抛出异常
 */
- (DBInfo*) getDBInfoByDBPath:(NSString*)dbPath {
    DBInfo * dbInfo =  _sqliteDBInfos[[dbPath lastPathComponent]];
    
    if(dbInfo==nil || !dbInfo.isOpened)
    {
        dbInfo = [self openOrCreateDatabase:dbPath];
    }
    
    if(dbInfo==nil)
    {
        NSString * exName = [NSString stringWithFormat:@"NotFound"];
        NSException* exception = [NSException exceptionWithName:exName reason:@"数据库不存在" userInfo:nil];
        @throw exception;
    }
    return dbInfo;
}
/**
 *@brief执行查询sql
 *@param sql - sql语句
 *  @return 返回查询的数据
 */
- (NSArray *)query:(NSString *) sql fromDatabase:(NSString *)dbPath;{
    NSMutableArray *table  = [NSMutableArray array];
    
    @synchronized(self) {
        if(sql==nil || sql.length==0) {
            @throw [NSException exceptionWithName:@"EmptySQL" reason:@"sql语句不能为null" userInfo:nil];
        }else {
            NSLog(@"SQL-Lang:%@",sql);
        }
        
        sqlite3_stmt *stmt;
        DBInfo * dbInfo =  [self getDBInfoByDBPath:dbPath];
        if(sqlite3_prepare_v2(dbInfo.db,[sql UTF8String],-1,&stmt,nil) == SQLITE_OK) {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                @autoreleasepool {
                    int col = sqlite3_column_count(stmt);
                    NSMutableDictionary *row = [NSMutableDictionary dictionary];
                    for (int i=0; i<col; i++)
                    {
                        id k = [NSString stringWithCString:sqlite3_column_name(stmt,i) encoding:NSUTF8StringEncoding];
                        id v = [self reloadData:stmt column:i];
                        if(v==nil)
                        {
                            v = [self reloadData:stmt column:i];
                        }
                        if(k==nil)
                        {
                            k = [NSString stringWithFormat:@"null_col_%d",i];
                        }
                        [row setObject:v forKey:k];
                    }
                    
                    [table addObject:row];
                }
            }
            sqlite3_finalize(stmt);
           
        } else {
            NSString *msg = [[NSString stringWithFormat:@"error=%s\nSQL=",sqlite3_errmsg(dbInfo.db)] stringByAppendingString:sql];
            @throw [NSException exceptionWithName:@"执行sql错误" reason:msg userInfo:nil];
        }
    }
    return table;
}
- (NSArray *)query:(NSString *) sql
{
    return [self query:sql fromDatabase:_defaultDBPath];
}
/**
 *
 * 按照表类型获取数据
 *
 */
- (id)reloadData:(sqlite3_stmt *)stmt column:(int)column
{
    id object;
    switch (sqlite3_column_type(stmt,column))
    {
        case SQLITE_INTEGER:
        { object = [NSNumber numberWithInt:sqlite3_column_int(stmt,column)];
            if(object==nil)
            {
                object = [NSNumber numberWithInt:0];
            }
        }
            break;
        case SQLITE_FLOAT:
        {
            object = [NSNumber numberWithDouble:sqlite3_column_double(stmt,column)];
            if(object==nil)
            {
                object = [NSNumber numberWithDouble:0.0];
            }
        }
            break;
        case SQLITE_BLOB:
        {
            object = [NSData dataWithBytes:sqlite3_column_blob(stmt,column) length:sqlite3_column_bytes(stmt,column)];
            if(object==nil)
            {
                object = [NSNull null];
            }
        }
            break;
        case SQLITE_NULL:
            object = [NSString stringWithFormat:@""];
            break;
        case SQLITE_TEXT:
        {
            char * value = (char *) sqlite3_column_text(stmt,column);
            if(value!=NULL)
            {
                object = [NSString stringWithUTF8String:value];
            }
            if(object==nil)
            {
                object = @"";
            }
        }
            break;
        default:
            sqlite3_value * value = sqlite3_column_value(stmt, column);
            NSObject *  objValue = (__bridge_transfer id)value;//将c对象转为OC对象
            object = objValue;
            break;
    }
    return object;
}
- (void)closeAllDatabase
{
    NSArray * keys = [_sqliteDBInfos.allKeys copy];
    for(int i=0;keys!=nil &&i<keys.count;i++)
    {
        [self closeDatabase:keys[i]];
    }
}
-(void)closeDatabase:(NSString *)dbPath;
{
    
    DBInfo * dbInfo  =  _sqliteDBInfos[[dbPath lastPathComponent]];
    if(dbInfo!=nil && dbInfo.isOpened && dbInfo.db!=NULL)
    {
        sqlite3_close(dbInfo.db);
        dbInfo.isOpened = NO;
        dbInfo.isOpenedTransaction = NO;
        dbInfo.db = NULL;
    }
}
-(void) closeDefaultDatabase
{
    [self closeDatabase:_defaultDBPath];
}
-(void)dealloc
{
    [self closeAllDatabase];
    [_sqliteDBInfos removeAllObjects];
}
/**
 *@brief判断表是否存在
 *@param name 表名字
 *  @return  返回转义后的字符串
 */
-(BOOL)isExistTable:(NSString *)tableName fromDatabase:(NSString *) dbPath;
{
    char *err;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",tableName];
    
    const char *sql_stmt = [sql UTF8String];
    
    DBInfo * dbInfo =  _sqliteDBInfos[[dbPath lastPathComponent]];
    
    if(dbInfo==nil)
    {
        return NO;
    }
    
    if(sqlite3_exec(dbInfo.db, sql_stmt, NULL, NULL, &err) == 1){
        return YES;
        
    }else{
        return NO;
    }
}
-(BOOL)isExistTable:(NSString *)tableName
{
    return [self isExistTable:tableName fromDatabase:_defaultDBPath];
}
-(void) dropTable:(NSString *) tableName fromDatabase:(NSString *)dbPath
{
    NSString * sql = [@"DROP TABLE IF EXISTS " stringByAppendingString:tableName];
    [self executeUpdate:sql fromDatabase:dbPath];
}
-(void) dropTable:(NSString *) tableName
{
    return [self dropTable:tableName fromDatabase:_defaultDBPath];
}
-(void) deleteDatabase:(NSString *) dbPath{
    
    [self closeDatabase:dbPath];
    
    [_sqliteDBInfos removeObjectForKey:[dbPath lastPathComponent]];

    if(![[NSFileManager defaultManager]fileExistsAtPath:dbPath])
    {
        return;
    }
    
    if ([[NSFileManager defaultManager]removeItemAtPath:dbPath error:nil]) {
        
        NSLog( @"remove: %@", [NSString stringWithFormat:@"%@", dbPath]);
    }
    
}
-(void) deleteDefaultDatabase
{
    return [self deleteDatabase:_defaultDBPath];
}
+(BOOL)isBase64String:(NSString *)src
{
    if(src==nil || src.length==0)
    {
        return NO;
    }
    
    if(src.length%4!=0)
    {
        return NO;
    }
    NSString *decodedString = nil;
    @try {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:src options:0];
        if(decodedData!=nil)
        {
            decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        }
        if(decodedString==nil)
        {
            @throw  [[NSException alloc] initWithName:@"Base64DecodeException" reason:@"Base64Decode 解码失败!" userInfo:nil];
        }
    }
    @catch(NSException *exception)
    {
        NSLog(@"exception=%@",exception);
        return NO;
    }
    return YES;
    
}
-(int) fetchNumberOfAffectedRows:(NSString *)dbPath
{
    DBInfo * dbInfo =  [self getDBInfoByDBPath:dbPath];
    
    return sqlite3_changes(dbInfo.db);
}
-(int) fetchNumberOfAffectedRows
{
    return [self fetchNumberOfAffectedRows:_defaultDBPath];
}
+(NSString *)sqlEscape:(NSString *)source
{
    
    if(source==nil || source.length==0)
    {
        return source;
    }
       NSDictionary * exludeDict = @{       @"\0":@"",
                                            @"\'":@"\\'",
                                            @"\"":@"\\\"",
                                            @"\n":@" ",
                                            @"/":@"\\/",
                                            @"\t":@" ",
                                            @"\r":@" ",
                                            @"%":@"\\%",
                                            @"\b":@" ",
                                            @"_":@"\\_"
                                            };
    
    for (NSString * key in exludeDict.allKeys)
    {
        if([source containsString:key])
        {
            source = [source stringByReplacingOccurrencesOfString:key withString:exludeDict[key]];
        }
    }
    
    return source;
    
}
-(long) lastInsertId
{
    return [self lastInsertId:_defaultDBPath];
}

-(long) lastInsertId:(NSString *) dbPath
{
    DBInfo * dbInfo =  [self getDBInfoByDBPath:dbPath];
    
    return sqlite3_last_insert_rowid(dbInfo.db);
}

@end
