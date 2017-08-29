//
//  EMMAppItem.h
//  SummerDemo
//
//  Created by Chenly on 2017/2/24.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMAppModel : NSObject

@property (nonatomic, copy) NSString *applicationId;    // 唯一标识 appid
@property (nonatomic, copy) NSString *title;            // 名称
@property (nonatomic, copy) NSString *iconurl;          // 图标
@property (nonatomic, copy) NSString *introduction;     // 描述
@property (nonatomic, copy) NSString *scop_type;        // 类型 1:web
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *URL_Scheme;
@property (nonatomic, copy) NSString *appgroupname;     // 分类名称
@property (nonatomic, copy) NSString *appgroupcode;     // 分类id
@property (nonatomic, copy) NSString *appinfoexport;    // userInfo
@property (nonatomic, copy) NSString *classname;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *webzipurl;        // zip 包下载地址

@property (nonatomic, assign) BOOL active;          // 活跃的（已添加到桌面）
@property (nonatomic, assign) BOOL installed;       // 已安装
@property (nonatomic, readonly) BOOL needUpdate;    // 有新版本
@property (nonatomic, copy) NSString *lastVersion;  // 最新版本

// database
@property (nonatomic, readonly, class) NSString *db_tableName;
@property (nonatomic, readonly, class) NSString *db_sqlForCreateTable;
- (NSString *)db_sqlForInsert;
- (NSString *)db_sqlForUpdateProperty:(NSString *)propertyName;
- (NSString *)db_sqlForUpdateProperties:(NSArray *)properties;

@end
