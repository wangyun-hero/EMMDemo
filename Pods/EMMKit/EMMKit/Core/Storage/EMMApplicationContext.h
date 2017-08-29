//
//  YYPApplicationContext.h
//  EMMClient
//
//  Created by 熊悦阅 on 16/6/16.
//  Copyright © 2016年 熊悦阅. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  全局上下文
 */
@interface EMMApplicationContext : NSObject

+ (instancetype)defaultContext;

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;

/**
 *  将对应字符串中的变量取值替换，如：存在值 url_xxx = "html/index" 则 www/${url_xxx} -> www/html/index
 */
- (NSString *)parserText:(NSString *)text;

@end
