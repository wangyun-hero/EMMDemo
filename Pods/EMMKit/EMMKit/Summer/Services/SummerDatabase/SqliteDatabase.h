//
//  SqliteDatabase.h
//  UMIOSControls
//
//  Created by gct on 16/8/3.
//  Copyright © 2016年 yyuap. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SqliteDatabase : NSObject


+(instancetype) shareInstance;

//-(BOOL)createDatabase:(NSString *) dbPath;
/*
 *
 *初始化
 */
-(BOOL)openDatabase:(NSString *) dbPath;

/**
 * 打开默认数据库
 */
-(BOOL)openDefaultDatabase;

//开启事务
-(BOOL) beginTransaction:(NSString *) dbPath;
//提交事务
-(BOOL) commitTransaction:(NSString *) dbPath;
//回滚事务
-(BOOL) rollbackTransaction:(NSString *) dbPath;


//开启默认数据库事务
-(BOOL) beginTransaction;
//提交默认数据库事务
-(BOOL) commitTransaction;
//回滚默认数据库事务
-(BOOL) rollbackTransaction;

/**
 * @brief  执行非查询sql
 *
 * @param     sql - sql语句
 */
- (void)executeUpdate:(NSString *)sql fromDatabase:(NSString *) dbPath;

//默认数据库
- (void)executeUpdate:(NSString *)sql;

/**
 * @brief  执行查询sql
 *
 * @param     sql - sql语句
 *
 *  @return 返回查询的数据
 */
- (NSArray *)query:(NSString *) sql fromDatabase:(NSString *)dbPath;
//默认数据库
- (NSArray *)query:(NSString *) sql;
/**
 *
 * 关闭数据库
 */
- (void)closeAllDatabase;
/**
 *
 * 关闭指定的数据库
 */
-(void)closeDatabase:(NSString *)dbPath;

-(void) closeDefaultDatabase;

/**
 *
 *检查数据表是否存在
 */
-(BOOL)isExistTable:(NSString *)tableName fromDatabase:(NSString *) dbPath;

//默认数据库
-(BOOL)isExistTable:(NSString *)tableName;

/*
 *
 *删除数据库
 *
 */
-(void) deleteDatabase:(NSString *) dbPath;
/**
 *
 * 删除表
 *
 */
-(void) dropTable:(NSString *) tableName fromDatabase:(NSString *)dbPath;
//默认数据库
-(void) dropTable:(NSString *) tableName;

/**
 * 判断是否Base64字符串
 */
+(BOOL)isBase64String:(NSString *)src;

/**
 *
 *获取表字段信息
 */
-(NSArray *)fetchFieldsInfo:(NSString *) tableName fromDatabase:(NSString *)dbPath;

//默认数据库
-(NSArray *)fetchFieldsInfo:(NSString *) tableName;

/**
 *
 *获取表字段名称
 */
-(NSArray *)fetchFieldsName:(NSString *) tableName fromDatabase:(NSString *)dbPath;
//默认数据库
-(NSArray *)fetchFieldsName:(NSString *) tableName;
//获取受影响的函数
-(int) fetchNumberOfAffectedRows:(NSString *)dbPath;
//默认数据库
-(int) fetchNumberOfAffectedRows;
/**
 * 数据插入
 *{}----------普通字典
 */
- (void)insertTable:(NSString *)tableName tableData:(NSDictionary *) dict fromDatabase:(NSString *) dbPath;
//默认数据库
- (void)insertTable:(NSString *)tableName tableData:(NSDictionary *) dict;

/**
 * 批量插入
 */
- (void)insertTable:(NSString *)tableName fields:(NSArray *) fields values:(NSArray *) values fromDatabase:(NSString *) dbPath;

- (void)insertTable:(NSString *)tableName fields:(NSArray *) fields values:(NSArray *) values;

/****过滤特殊字符****/
+(NSString *)sqlEscape:(NSString *)source;


+(NSString *) getDatabasePath:(NSString *) dbName;

-(long) lastInsertId:(NSString *) dbName;
-(long) lastInsertId;

-(BOOL) dbIsOpened:(NSString *) nsFile;
-(BOOL) defaultDbIsOpened;

@end
