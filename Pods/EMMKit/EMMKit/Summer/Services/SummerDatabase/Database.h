//
//  Database.h
// 
//  数据库文件操作对象
//
//  Created by gct on 16/8/3.
//  Copyright © 2016年 yyuap. All rights reserved.
///

#import <Foundation/Foundation.h>

//
// Database
//
// sqlite数据库操作类
//
//
@interface Database : NSObject
//
// databaseWithFile:
//
// 指定数据库文件，获取 Database 对象
//
// returns 返回 Database 对象
//
+ (Database *)databaseWithFile:(NSString *) file;


- (id)initWithFile:(NSString *) file;

/**
 *	@brief	执行非查询sql
 *
 *	@param 	sql - sql语句
 */
- (BOOL)execute:(NSString *)sql;


/**
 *	@brief	执行查询sql
 *
 *	@param 	sql - sql语句
 *
 *  @return 返回查询的数据
 */
- (NSArray *)getRows:(NSString *)sql;

/**
 *	@brief	执行查询sql
 *
 *	@param 	sql - sql语句
 *          isSingleArray - 表示是否返回首行首列用在 count 等聚合函数里
 *
 *  @return 返回查询的数据
 */
- (NSArray *)getRows:(NSString *)sql isSingleArray:(BOOL)isSingleArray;


/**
 *	@brief	执行查询sql 返回首行首列；用在 count 等聚合函数里
 *
 *	@param 	sql - sql语句，语句中只有一个返回值
 *          
 *
 *  @return 返回查询的数据
 */
- (id)getScalar:(NSString *)sql;


/**
 *	@brief	防sql注入，字符串转义
 *
 *	@param 	sql - sql中的字符串
 *
 *
 *  @return 返回转义后的字符串
 */
- (NSString *)escapeString:(NSString *)sql;
/**
 *	@brief	判断表是否存在
 *
 *	@param 	name 表名字
 *
 *
 *  @return 返回转义后的字符串
 */
-(BOOL)checkName:(NSString *)name;

@end
