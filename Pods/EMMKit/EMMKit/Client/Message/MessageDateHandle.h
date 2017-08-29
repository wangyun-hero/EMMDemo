//
//  MessageDateHandle.h
//  EMMKitDemo
//
//  Created by zm on 16/9/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageDateHandle : NSObject

// 获取当前日期时间 yyyy/MM/dd-HH:mm
+ (NSString *)getCurrentDate;

// 按照微信规则处理日期
+ (NSString *)conversionFromDate:(NSString *)messageDate;

// 消息主页显示时间处理
+ (NSString *)mainShowTime:(NSString *)date;

// 消息详情页显示时间处理
+ (NSString *)detailShowTime:(NSString *)date;

@end
