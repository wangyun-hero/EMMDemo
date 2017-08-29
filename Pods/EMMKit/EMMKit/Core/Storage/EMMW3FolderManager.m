//
//  EMMW3FolderManager.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMW3FolderManager.h"
#import "SSZipArchive.h"
#import <AFNetworking/AFNetworking.h>

@interface EMMW3FolderManager ()

@property (nonatomic, strong) NSMutableDictionary *wwwFolders;

@end

@implementation EMMW3FolderManager

// 存放 www 目录与 appid 映射关系到 UserDefault 中所用的 key
static NSString * const kUserDefaultKeyOfW3Folders = @"kUserDefaultKeyOfW3Folders";

// 在 Document文件夹中简历一个用于存放 www 应用的目录。
static NSString * const kW3ApplicationsDir = @"summer_applications";

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EMMW3FolderManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMW3FolderManager alloc] init];
    });
    return sSharedInstance;
}

- (NSDictionary *)wwwFolders {
    
    if (!_wwwFolders) {
        NSDictionary *wwwFolders = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kUserDefaultKeyOfW3Folders];
        _wwwFolders = wwwFolders ? [wwwFolders mutableCopy] : [NSMutableDictionary dictionary];
    }
    return [_wwwFolders copy];
}

/**
 *  获取 key 对应的 www 目录
 */
- (NSString *)absoluteW3FolderForKey:(NSString *)key {
    
    BOOL notNil = ![key isEqualToString:kMainW3FolderKey];
    return [self absoluteW3FolderForKey:key notNil:notNil];
}

/**
 *  获取 key 对应的 www 路径
 *
 *  @param notNil 如果返回为 nil 则转换成"<null>"
 *
 *  @return www 目录路径
 */
- (NSString *)absoluteW3FolderForKey:(NSString *)key notNil:(BOOL)notNil {
    
    NSDictionary *info = key ? (self.wwwFolders[key] ?: nil) : nil;
    NSString *wwwFolder = info[@"wwwFolder"];
    if (!wwwFolder) {
        return notNil ? @"<null>" : nil;
    }
    
    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *path = [documentDir stringByAppendingPathComponent:wwwFolder];
    path = [NSURL fileURLWithPath:path].absoluteString;
    if (!path) {
        return @"<null>";
    }
    return path;
}

/**
 *  获取 key 对应的 www 版本信息
 *  value : { path: ".../www", version: { versionCode: "1", versionName: "1.0.0" } }
 */
- (NSDictionary *)versionInfoForKey:(NSString *)key {
    
    if (!key) {
        return nil;
    }
    NSDictionary *info = self.wwwFolders[key];
    return info ? info[@"version"] : nil;
}

/**
 *  设置 key 对应的 www 信息
 */
- (void)setW3Folder:(id)value forKey:(NSString *)key {
    _wwwFolders[key] = value;
    [self synchronize];
}

- (void)synchronize {
    [[NSUserDefaults standardUserDefaults] setObject:self.wwwFolders forKey:kUserDefaultKeyOfW3Folders];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)downloadW3FolderWithURL:(NSString *)URLString
                            key:(NSString *)key
                        version:(NSString *)version
                    versionName:(NSString *)versionName
                    incremental:(BOOL)incremental
                       progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
                     completion:(void (^)(BOOL success, id result))completion {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"RSA2048CARoot"ofType:@"cer"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [securityPolicy setAllowInvalidCertificates:YES];
    [securityPolicy setPinnedCertificates:[NSSet setWithArray:@[certData]]];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = YES;
    [manager setSecurityPolicy:securityPolicy];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress){
        
        if (downloadProgressBlock) {
            downloadProgressBlock(downloadProgress);
        }
        
    }destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"hhhhhhh");
        if (error) {
            NSLog(@"下载 www 应用失败：%@", error.localizedDescription);
            completion(NO, error);
        }
        else {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSString *wwwFolder = [NSString stringWithFormat:@"%@/%@/%@", kW3ApplicationsDir, key, version];
            NSString *toDirectory = [[documentDir stringByAppendingPathComponent:wwwFolder]stringByAppendingString:@"/"];
            NSString *lastW3Folder = [self absoluteW3FolderForKey:key];
            NSError *zipError;
            if (incremental && !lastW3Folder) {
                
                NSString *mainW3Folder = [[NSBundle mainBundle] pathForResource:@"www" ofType:nil];
                lastW3Folder = [[toDirectory stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"temp"];
                NSError *e;
                [fileManager createDirectoryAtPath:lastW3Folder withIntermediateDirectories:YES attributes:nil error:&e];
                [fileManager copyItemAtPath:mainW3Folder
                                     toPath:[lastW3Folder stringByAppendingPathComponent:@"www"]
                                      error:&e];
            }
            BOOL zipSucceed = [[EMMW3FolderManager sharedInstance] unZip:filePath.path
                                                             toDirectory:toDirectory
                                                                   error:&zipError];
            if (zipSucceed) {
                if (incremental) {
                    [self rewriteCopyFromPath:toDirectory toPath:lastW3Folder];
                    [fileManager removeItemAtPath:toDirectory error:NULL];
                    [fileManager copyItemAtPath:lastW3Folder toPath:toDirectory error:NULL];
                }
                if ([fileManager fileExistsAtPath:lastW3Folder]) {
                    // 删除历史版本
                    [fileManager removeItemAtPath:lastW3Folder error:nil];
                }
                
                NSDictionary *info = @{
                                       @"wwwFolder": [wwwFolder stringByAppendingPathComponent:@"www"],
                                       @"version": @{ @"versionCode": version, @"versionName": versionName}
                                       };
                [self setW3Folder:info forKey:key];
                completion(YES, nil);
            }
            else {
                NSLog(@"解压 zip 包失败:%@", zipError.localizedDescription);
                [fileManager removeItemAtPath:toDirectory error:nil];
                completion(NO, zipError);
            };
        }
    }];
    [downloadTask resume];
}

/**
 *  解压
 */
- (BOOL)unZip:(NSString *)zipFile toDirectory:(NSString *)toDirectory error:(NSError **)error {
    
    if(![SSZipArchive unzipFileAtPath:zipFile toDestination:toDirectory]) return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:toDirectory error:error];
    
    [fileManager removeItemAtPath:zipFile error:error];
    if (![fileContents containsObject:@"www"]) {
        *error = [NSError errorWithDomain:@"Not found www folder!" code:0 userInfo:@{@"fileContents": fileContents, @"localizedDescription": @"zip 包中不包含 www 文件夹"}];
        return NO;
    }
    
    // 将 ioscordovasupportjs 中替换到 www 目录下
    NSString *wwwFolder = [toDirectory stringByAppendingPathComponent:@"www"];
    [self dealWithCordovaFilesWithW3Folder:wwwFolder];
    
    return *error == nil;
}

- (void)dealWithCordovaFilesWithW3Folder:(NSString *)wwwFolder {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fromDir = [wwwFolder stringByAppendingPathComponent:@"ioscordovasupportjs"];
    
    NSError *error;
    BOOL isDirectory;
    if ([fileManager fileExistsAtPath:fromDir isDirectory:&isDirectory] && isDirectory) {
        
        NSString *toDir = wwwFolder;
        NSArray *files = [fileManager contentsOfDirectoryAtPath:fromDir error:&error];
        for (NSString *file in files) {
            
            NSString *fromPath = [fromDir stringByAppendingPathComponent:file];
            NSString *toPath = [toDir stringByAppendingPathComponent:file];
            
            if ([fileManager fileExistsAtPath:toPath]) {
                [fileManager removeItemAtPath:toPath error:&error];
            }
            [fileManager moveItemAtPath:fromPath toPath:toPath error:&error];
        }
        [fileManager removeItemAtPath:fromDir error:&error];
    }
}

- (BOOL)removeW3Folder:(NSString *)key {
    NSString *www = [self absoluteW3FolderForKey:key];
    NSArray *documents = [www componentsSeparatedByString:key];
    if(documents.count){
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        documents = [[documents firstObject] componentsSeparatedByString:@"file://"];
        NSString *path = [[documents lastObject] stringByAppendingString:key];
        path =  [path stringByAppendingString:@"/"];
        
        BOOL isSuccess = [fileManager removeItemAtPath:path error:&error];
        if(isSuccess){
            [_wwwFolders removeObjectForKey:key];
            [self synchronize];
        }
        return isSuccess;
    }
    return NO;
}

#pragma mark - private method

- (void)rewriteCopyFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL exists = [fileManager fileExistsAtPath:fromPath isDirectory:&isDirectory];
    if (!exists) {
        return;
    }
    if (isDirectory) {
        NSArray *files = [fileManager contentsOfDirectoryAtPath:fromPath error:NULL];
        for (NSString *file in files) {
            [self rewriteCopyFromPath:[fromPath stringByAppendingPathComponent:file]
                               toPath:[toPath stringByAppendingPathComponent:file]];
        }
    }
    else {
        if ([fileManager fileExistsAtPath:toPath]) {
            [fileManager removeItemAtPath:toPath error:NULL];
        }
        [fileManager copyItemAtPath:fromPath toPath:toPath error:NULL];
    }
}

@end


@implementation NSString (EMMW3FolderManager)

+ (NSString *)pathInDocumentDirWithW3FolderName:(NSString *)folderName {
    
    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [documentDir stringByAppendingPathComponent:folderName];
}

@end
