//
//  SummerSQLiteService.h
//  SummerDemo
//
//  Created by 振亚 姜 on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SummerServices.h"
@class SummerInvocation;

@interface SummerSQLiteService : NSObject<SummerServiceProtocol>

+ (id)instanceForServices;

/*
 *  @brief	初始化一个数据库，如果已经初始化过了，就忽略
 *
 *	@param 	 db         数据库的文件名
 *
 */
+(NSString *)openDB:(SummerInvocation *)invocation;



/*
 *  @brief	删除一个数据库
 *
 *	@param 	 db         数据库的文件名
 *
 */
+(void)deleteDB:(SummerInvocation *)invocation;


/*
 *  @brief	执行一句SQL，无返回值
 *
 *	@param 	 db         数据库的文件名(初始化后，使用初始的db，不用再写db)
 *           sql            SQL
 *
 */
+(NSString *)execSql:(SummerInvocation *)invocation;



+(NSString *)exist:(SummerInvocation *)invocation;

+(id)queryByPage:(SummerInvocation *)invocation;

/*
 *  @brief	执行一句SQL，有返回值，返回的结果转为JSON对象放到指定的Ctx路径
 *
 *	@param 	 db         数据库的文件名(初始化后，使用初始的db，不用再写db)
 *           sql            SQL
 pagesize：一页数据数，默认10（可选参数）
 start：起始索引，默认0（可选参数）
 *           content        返回的值绑到Ctx的路径
 *
 */
+(id)query:(SummerInvocation *)invocation;






+(NSString *)checkTable:(SummerInvocation *)invocation;

/**
 *  获取version
 *
 *  @param args {"db":"name"}
 *
 *  @return version
 */
+(NSString *)getVersion:(SummerInvocation *)invocation;

/**
 *  设置version
 *
 *  @param args {"db":"name","version":"1"}
 */
+(NSString *)setVersion:(SummerInvocation *)invocation;

//获取数据库路径
+(NSString *)getPath:(SummerInvocation *)invocation;

+(NSString*) getTableFieldsInfo:(SummerInvocation *)invocation;

-(NSString *) getLastInsertId:(SummerInvocation *)invocation;

+(NSString *) getAffectRowCount:(SummerInvocation *)invocation;


+(NSString *) getTableFields:(SummerInvocation *)invocation;

+(NSString *) rollback:(SummerInvocation *)invocation;

+(NSString *) commit:(SummerInvocation *)invocation;

+(NSString *) begin:(SummerInvocation *)invocation;

+(NSString *) closeDB:(SummerInvocation *)invocation;
+(id) queryTable:(SummerInvocation *)invocation;

+(BOOL)isBase64String:(NSString *)src;

@end
