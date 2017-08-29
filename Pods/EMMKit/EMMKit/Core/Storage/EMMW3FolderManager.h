//
//  EMMW3FolderManager.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMainW3FolderKey [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]

@interface EMMW3FolderManager : NSObject

@property (nonatomic, readonly) NSDictionary *wwwFolders;

+ (instancetype)sharedInstance;

/**
 *  解压一个 zip 文件到指定目录下
 */
- (BOOL)unZip:(NSString *)zipFile toDirectory:(NSString *)toDirectory error:(NSError **)error;

- (NSString *)absoluteW3FolderForKey:(NSString *)key;
/**
 *  获取 key 对应的 www 路径
 *
 *  @param notNil YES:如果返回为 nil 则转换成"<null>"
 */
- (NSString *)absoluteW3FolderForKey:(NSString *)key notNil:(BOOL)notNil;

/**
 *  获取 key 对应的 www 版本信息
 */
- (NSDictionary *)versionInfoForKey:(NSString *)key;

/**
 *  下载一个 www 应用，key = appid;
 */
- (void)downloadW3FolderWithURL:(NSString *)URLString
                            key:(NSString *)key
                        version:(NSString *)version
                    versionName:(NSString *)versionName
                    incremental:(BOOL)incremental
                       progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                     completion:(void (^)(BOOL success, id result))completion;

/**
 删除key下所有文件夹
 
 @param key
 @return
 */
- (BOOL) removeW3Folder:(NSString *)key;

@end

@interface NSString (EMMW3FolderManager)

/**
 *  获取 www 文件夹在 Document 目录下的完整路径
 */
+ (NSString *)pathInDocumentDirWithW3FolderName:(NSString *)folderName;

@end
