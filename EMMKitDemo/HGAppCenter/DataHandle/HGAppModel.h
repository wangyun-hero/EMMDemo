//
//  HGAppModel.h
//  EMMKitDemo
//
//  Created by zm on 16/7/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGAppModel : NSObject

//app唯一标识app_key
@property (nonatomic, strong) NSString *applicationId;
//应用名称name
@property (nonatomic, strong) NSString *title;
//应用图标地址iconUrl
@property (nonatomic, strong) NSString *iconurl;
//应用描述introduction
@property (nonatomic, strong) NSString *introduction;
//应用类型 1==web、3、4、5、6
@property (nonatomic, strong) NSString *scop_type;
//版本号version
@property (nonatomic, strong) NSString *version;
// url_scheme
@property (nonatomic, strong) NSString *URL_Scheme;
// 分类名称
@property (nonatomic, strong) NSString *appgroupname;
// 分类id
@property (nonatomic, strong) NSString *appgroupcode;
// 订阅信息
@property (nonatomic, strong) NSString *appinfoexport;

@property (nonatomic, strong) NSString *classname;
// 跳转url
@property (nonatomic, strong) NSString *url;
// web下载www.zip url
@property (nonatomic, strong) NSString *webZipUrl;
//www版本号
@property (nonatomic, strong) NSString *www_localVersion;
// 排序字段 
@property (nonatomic) NSInteger orderNum;

@property (nonatomic, strong) NSString *www_size;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
