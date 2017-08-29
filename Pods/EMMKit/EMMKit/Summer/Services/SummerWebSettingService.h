//
//  SummerWebSettingService.h
//  SummerDemo
//
//  Created by zm on 16/8/2.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SummerWebSettingService : NSObject

@property (nonatomic, strong) NSString *httpType;//http类型
@property (nonatomic, strong) NSString *serverUrl;//服务地址
@property (nonatomic, strong) NSString *appId;//应用id
@property (nonatomic, strong) NSString *action; //服务名称
@property(nonatomic,strong) NSString *mpVersion; //应用的版本
@property (nonatomic, strong) NSString *viewid;
@property (nonatomic, strong) NSString *serviceid;
@property (nonatomic, strong) NSString *contextmapping;
@property (nonatomic, strong) NSString *tp;//默认不加密,加密标识
@property (nonatomic, strong) NSString *funcode;
@property (nonatomic, strong) NSString *tabid;
@property (nonatomic, strong) NSString *funcid;
@property (nonatomic, strong) NSString *forelogin;
@property (nonatomic, strong) NSString *sessionid;
@property (nonatomic, strong) NSString *devid;
@property (nonatomic, strong) NSString *massotoken;
@property (nonatomic, strong) NSString *pushtoken;

@property (nonatomic, strong) NSString *user;//用户名
@property (nonatomic, strong) NSString *pass;//密码

@property (nonatomic, strong) NSString * token;//唯一token值
@property (nonatomic, strong) NSString * userid;//当前Userid
@property (nonatomic, strong) NSString * groupid;//当前groupid

@property (nonatomic, strong) NSString * host;//host
@property  (nonatomic, strong) NSString *port;
@property(nonatomic,strong) NSString * type;//nc or u8
@property (nonatomic, copy) NSDictionary * header;//nc or u8

@property (nonatomic, strong) NSMutableDictionary *params;


+ (instancetype)sharedInstance;
- (void)setDict:(NSDictionary *)dict ;

@end
