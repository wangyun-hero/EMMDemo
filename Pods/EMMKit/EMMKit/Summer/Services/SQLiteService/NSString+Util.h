//
//  NSString+Util.h
//  UMContainer
//
//  Created by dingheng on 13-12-11.
//  Copyright (c) 2013年 UFIDA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)
/*
 函数描述：字符串筛选,去掉不需要的特殊字符串
 参数描述：target         原字符串
 replacement   需要替换的字符串
 options       默认传2:NSLiteralSearch,区分大小写
 _replaceArray 需要排除的Array
 返回值： 筛选完的String
 备注:   使用方法:replaceOccurrencesOfString:@"1(2*3" withString:@"" options:2 replaceArray:[NSArray arrayWithObjects:@"(",@"*", nil]
 输出:123
 */
+ (NSString *)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options replaceArray:(NSArray *)_replaceArray;

+(NSString *)randFileName;

+ (NSString*)encodeURL:(NSString *)string;
+ (NSString*)decodeURL:(NSString *)string;


/**
 *  字符串是否有效
 *
 *  @return 是否有效
 */
-(BOOL)isValidString;
+(BOOL) isEmptyOrNil:(NSString *)str;
+(NSString *) trim:(NSString *)str;
@end
