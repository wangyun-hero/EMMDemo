//
//  EMMAppsManager.m
//  SummerDemo
//
//  Created by Chenly on 2017/2/24.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import "EMMAppsManager.h"
#import "EMMAPIs.h"
#import "EMMAppModel.h"
#import "EMMW3FolderManager.h"

#import <YYModel/YYModel.h>
#import <FMDB/FMDB.h>

@interface EMMAppsManager ()

@property (nonatomic, copy, readwrite) NSArray *apps;
@property (nonatomic, copy, readwrite) NSArray *localApps;

@property (nonatomic, assign) BOOL needLoadLocalApps;

@property (nonatomic, readonly) FMDatabase *database;

@end

@implementation EMMAppsManager

@synthesize localApps = _localApps;

+ (instancetype)sharedInstance {
    static EMMAppsManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EMMAppsManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _needLoadLocalApps = YES;
        [self initializeDatabase];
    }
    return self;
}

- (void)initializeDatabase {
    
    if ([self.database open]) {
        
        NSString *query = [NSString stringWithFormat:@"select count(*) from sqlite_master where type='table' and name='%@';", [EMMAppModel db_tableName]];
        FMResultSet *resultSet = [self.database executeQuery:query];
        if (!resultSet.next || [resultSet intForColumnIndex:0] == 0) {
            BOOL result = [self.database executeUpdate:[EMMAppModel db_sqlForCreateTable]];
            NSAssert(result, @"Sqlite 创建表失败");
        }
        [self.database close];
    }
}

#pragma mark - getter & setter

- (FMDatabase *)database {

    static FMDatabase *database;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *dbPath = [documentDir stringByAppendingPathComponent:@"emm_apps.sqlite"];
        database = [FMDatabase databaseWithPath:dbPath];
    });
    return database;
}

- (NSArray *)localApps {
    
    if (self.needLoadLocalApps) {
        self.needLoadLocalApps = NO;
        
        [self.database open];
        NSString *query = [NSString stringWithFormat:@"select * from %@", [EMMAppModel db_tableName]];
        FMResultSet *resultSet = [self.database executeQuery:query];
        NSMutableArray *apps = [NSMutableArray array];
        while ([resultSet next]) {
            if (resultSet.columnCount == 0) {
                continue;
            }
            EMMAppModel *app = [EMMAppModel yy_modelWithDictionary:resultSet.resultDictionary];
            [apps addObject:app];
        }
        [self.database close];
        _localApps = apps.count > 0 ? [apps copy] : nil;
    }
    return _localApps;
}

#pragma mark - public

- (void)fetchApps:(void(^)(NSArray<NSDictionary *> *apps, NSError *error))completion {
    
    [[EMMAPIs sharedInstance] fetchApps:^(NSArray<EMMAppModel *> *apps, NSError *error) {
        
        if (error) {
            if (completion) {
                completion(nil, error);
            }
            return;
        }
        
        self.apps = apps;
        if (!self.localApps) {
            self.localApps = apps;
            if ([self.database open]) {
                for (EMMAppModel *app in apps) {
                    [self.database executeUpdate:[app db_sqlForInsert]];
                }
                [self.database close];
            }
        }
        else {
            // 更新本地内容（除已安装应用的当前版本号）
            for (EMMAppModel *app in apps) {
                [self.localApps enumerateObjectsUsingBlock:^(EMMAppModel *localApp, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([app.applicationId isEqualToString:localApp.applicationId]) {
                        
                        if (localApp.installed) {
                            app.lastVersion = app.version;
                            app.version = localApp.version;
                            app.installed = YES;
                        }
                        app.active = localApp.active;
                        *stop = YES;
                    }
                }];
            }
            self.localApps = apps;
            if ([self.database open]) {
                // 清空数据库
                NSString *sql = [NSString stringWithFormat:@"delete * from %@", [EMMAppModel db_tableName]];
                [self.database executeUpdate:sql];
                // 新插入应用列表
                for (EMMAppModel *app in apps) {
                    [self.database executeUpdate:[app db_sqlForInsert]];
                }
                [self.database close];
            }
        }
        completion([apps yy_modelToJSONObject], nil);
    }];
}

- (NSArray<NSDictionary *> *)getLocalApps {
    return [self.localApps yy_modelToJSONObject];
}

- (void)installAppWithId:(NSString *)appid
                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
              completion:(void (^)(BOOL success, id result))completion {

    for (EMMAppModel *app in self.localApps) {
        if ([app.applicationId isEqualToString:appid]) {
            
            if (app.installed) {
                if (completion) {
                    completion(NO, @"该应用已安装");
                }
                return;
            }
            
            [[EMMW3FolderManager sharedInstance] downloadW3FolderWithURL:app.webzipurl key:appid version:app.version versionName:app.version incremental:NO progress:downloadProgressBlock completion:^(BOOL success, id result) {
                
                if (success) {
                    app.installed = YES;
                    app.version = app.lastVersion;
                    // 更新数据库
                    if ([self.database open]) {
                        [self.database executeUpdate:[app db_sqlForUpdateProperties:@[@"version", @"installed"]]];
                        [self.database close];
                    }
                }
                if (completion) {
                    completion(success, result);
                }
            }];
            return;
        }
    }
    if (completion) {
        completion(NO, @"未找到该应用");
    }
}

- (void)upgradeAppWithId:(NSString *)appid
                progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
              completion:(void (^)(BOOL success, id result))completion {

    for (EMMAppModel *app in self.localApps) {
        if ([app.applicationId isEqualToString:appid]) {
            
            if (!app.installed) {
                if (completion) {
                    completion(NO, @"未安装该应用");
                }
                return;
            }
            else if([app.version compare:app.lastVersion] != NSOrderedAscending) {
                if (completion) {
                    completion(NO, [NSString stringWithFormat:@"该应用无需更新，appid:%@, version:%@", appid, app.version]);
                }
                return;
            }
            
            [[EMMW3FolderManager sharedInstance] downloadW3FolderWithURL:app.webzipurl key:appid version:app.version versionName:app.version incremental:NO progress:downloadProgressBlock completion:^(BOOL success, id result) {
                
                if (success) {
                    app.installed = YES;
                    app.version = app.lastVersion;
                    // 更新数据库
                    if ([self.database open]) {
                        [self.database executeUpdate:[app db_sqlForUpdateProperties:@[@"version", @"installed"]]];
                        [self.database close];
                    }
                }
                if (completion) {
                    completion(success, result);
                }
            }];
            return;
        }
    }
    if (completion) {
        completion(NO, @"未找到该应用");
    }
}

- (BOOL)uninstallAppWithId:(NSString *)appid error:(NSError **)error {
    
    for (EMMAppModel *app in self.localApps) {
        if ([app.applicationId isEqualToString:appid]) {
            
            if (!app.installed) {
                *error = [NSError errorWithDomain:@"未安装该应用" code:0 userInfo:nil];
                return NO;
            }
            if ([[EMMW3FolderManager sharedInstance] removeW3Folder:appid]) {
                app.installed = NO;
                app.version = app.lastVersion;
                // 更新数据库
                if ([self.database open]) {
                    [self.database executeUpdate:[app db_sqlForUpdateProperties:@[@"version", @"installed"]]];
                    [self.database close];
                }
                return YES;
            }
            else {
                *error = [NSError errorWithDomain:@"卸载失败，未知原因" code:0 userInfo:nil];
                return NO;
            }
        }
    }
    *error = [NSError errorWithDomain:@"未找到该应用" code:0 userInfo:nil];
    return NO;
}

- (id)paramsForLaunchingAppWithId:(NSString *)appid {

    for (EMMAppModel *app in self.localApps) {
        if ([app.applicationId isEqualToString:appid]) {
            
            if (app.installed) {
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                NSString *wwwFolderName = [[EMMW3FolderManager sharedInstance] absoluteW3FolderForKey:appid];
                NSString *startPage = nil;
                NSString *configFile = nil;
                if (wwwFolderName) {
                    params[@"wwwFolderName"] = wwwFolderName;
                }
                if (startPage) {
                    params[@"startPage"] = startPage;
                }
                if (configFile) {
                    params[@"configFile"] = configFile;
                }
                return [params copy];
            }
            else {
                return @"未安装该应用";
            }
        }
    }
    return @"未找到该应用";
}

@end
