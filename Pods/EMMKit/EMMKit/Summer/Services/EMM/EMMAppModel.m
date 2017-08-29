//
//  EMMAppItem.m
//  SummerDemo
//
//  Created by Chenly on 2017/2/24.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import "EMMAppModel.h"
#import <YYModel/YYModel.h>

@implementation EMMAppModel

#pragma mark - YYModel

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    NSString *version = dic[@"version"];
    NSString *lastVersion = dic[@"lastVersion"];
    if (![version isKindOfClass:[NSString class]]) {
        _version = dic[@"webversion"];
    }
    if (![lastVersion isKindOfClass:[NSString class]]) {
        _lastVersion = _version;
    }
    _installed = [dic[@"installed"] boolValue];    
    return YES;
}

- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    
    if (self.lastVersion.length == 0) {
        dic[@"lastVersion"] = self.version;
    }
    return YES;
}

#pragma mark - database

+ (NSString *)db_tableName {
    return @"emm_apps";
}

+ (NSString *)db_sqlForCreateTable {

    NSString *sql = [NSString stringWithFormat:@"create table if not exists %@  ("
                     "applicationId varchar(128) primary key not null, "
                     "title varchar(128),"
                     "iconurl text,"
                     "introduction text,"
                     "scop_type varchar(128),"
                     "version varchar(128),"
                     "scheme varchar(128),"
                     "appgroupname varchar(128),"
                     "appgroupcode varchar(128),"
                     "appinfoexport text,"
                     "classname varchar(128),"
                     "url text,"
                     "webzipurl text,"
                     "lastVersion varchar(128),"
                     "active varchar(128),"
                     "installed varchar(128)"
                     ");", self.db_tableName];
    return sql;
}

- (NSString *)db_sqlForInsert {
    
    NSDictionary *dictionary = [self yy_modelToJSONObject];
    NSMutableString *keys = [NSMutableString string];
    NSMutableString *values = [NSMutableString string];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
        
        if (keys.length) {
            [keys appendString:@","];
        }
        if (values.length) {
            [values appendString:@","];
        }
        [keys appendString:key];
        [values appendFormat:@"'%@'", value];
    }];
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values (%@)", [self.class db_tableName], keys, values];
    return sql;
}

- (NSString *)db_sqlForUpdateProperty:(NSString *)propertyName {
    return [self db_sqlForUpdateProperties:@[propertyName]];
}

- (NSString *)db_sqlForUpdateProperties:(NSArray *)properties {
    
    NSDictionary *dictionary = [self yy_modelToJSONObject];
    NSMutableString *str = [NSMutableString string];
    for (NSString *property in properties) {
        
        if (str.length) {
            [str appendString:@","];
        }
        NSString *value = dictionary[property];
        [str appendFormat:@"%@ = '%@'", property, value];
    }
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where applicationId = '%@'", [self.class db_tableName], str, self.applicationId];
    return sql;
}

@end
