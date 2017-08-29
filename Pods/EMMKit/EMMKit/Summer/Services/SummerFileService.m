//
//  SummerFileService.m
//  SummerDemo
//
//  Created by Chenly on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerFileService.h"
#import "SummerInvocation.h"
#import <AFNetworking/AFNetworking.h>
#import "UIAlertController+EMM.h"
#import <QuickLook/QuickLook.h>

@interface SummerFileService () <QLPreviewControllerDataSource>

@property (nonatomic, copy) NSString *filePath;

@end

@implementation SummerFileService

+ (void)load {
    if (self == [SummerFileService self]) {
        [SummerServices registerService:@"UMFile" class:@"SummerFileService"];    // 文件操作
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerFileService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerFileService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

#pragma mark - 文件操作

- (NSURL *)documentsDirectoryURL {

    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                  inDomain:NSUserDomainMask
                                         appropriateForURL:nil
                                                    create:NO
                                                     error:nil];
}

- (NSString *)fullPathWithPath:(NSString *)path {

    NSURL *filePath = nil;
    if ([path hasPrefix:[self documentsDirectoryURL].path]) {
        
        filePath = [NSURL fileURLWithPath:path];
    }
    else {
        filePath = [[self documentsDirectoryURL] URLByAppendingPathComponent:path];
    }
    return filePath.path;
}

#pragma mark -

- (id)write:(SummerInvocation *)invocation {

    NSString *path = invocation.params[@"path"];
    NSString *content = invocation.params[@"content"];
    NSString *filePath = [self fullPathWithPath:path];
    BOOL succeed = [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    id result = @(succeed);
    [invocation callbackWithObject:result];
    return result;
}

- (id)read:(SummerInvocation *)invocation {
    
    NSString *path = invocation.params[@"path"];
    NSString *filePath = [self fullPathWithPath:path];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    id result = content;
    [invocation callbackWithObject:result];
    return result;
}

- (void)download:(SummerInvocation *)invocation {
    
    NSString *urlString = invocation.params[@"url"];
    NSString *locate = invocation.params[@"locate"];
    NSString *filename = invocation.params[@"filename"];
    NSString *override = invocation.params[@"override"];
    if ([override isKindOfClass:[NSNumber class]]) {
        override = [override boolValue] ? @"true" : @"false";
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"url"] = urlString;
    result[@"filename"] = filename;
    result[@"filepath"] = locate;
    result[@"isfinish"] = @(NO);
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {

        static BOOL resting = NO;
        
        float completed = downloadProgress.completedUnitCount;
        float total = downloadProgress.totalUnitCount;
        if (resting && completed < total) {
            return;
        }
        else {
            result[@"fileSize"] = @(total);
            result[@"percent"] = @(completed * 100 / total);
            dispatch_async(dispatch_get_main_queue(), ^{
                [invocation callbackWithObject:result resultType:SummerInvocationResultTypeOriginal];
            });
            resting = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resting = NO;
            });
        }
        
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (!error) {
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            NSURL *toURL = [documentsDirectoryURL URLByAppendingPathComponent:[locate stringByAppendingPathComponent:filename]];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:toURL.path] && ![override isEqualToString:@"true"]) {
                
                result[@"error"] = @"已存在该文件";
            }
            else {
                
                if (![[NSFileManager defaultManager] createDirectoryAtPath:[toURL.path stringByDeletingLastPathComponent]
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&error])
                {
                    return;
                }
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:toURL.path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:toURL.path error:nil];
                }
                if ([[NSFileManager defaultManager] moveItemAtURL:filePath toURL:toURL error:&error]) {
                    result[@"percent"] = @(100);
                    result[@"isfinish"] = @(YES);
                    result[@"savePath"] = toURL.path;
                }
            }
        }
        if (error) {
            result[@"error"] = error.localizedDescription;
        }
        [invocation callbackWithObject:result resultType:SummerInvocationResultTypeOriginal];
    }];
    [downloadTask resume];
}

- (void)upload:(SummerInvocation *)invocation {
    
    NSString *urlString = invocation.params[@"url"];
    NSString *path = invocation.params[@"filename"];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURL *URL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    NSURL *filePath = [NSURL fileURLWithPath:path];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:filePath progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            [invocation callbackWithObject:@{@"error": error.localizedDescription}];
        } else {
            [invocation callbackWithObject:responseObject];
        }
    }];
    [uploadTask resume];
}

- (id)getFileInfo:(SummerInvocation *)invocation {
    
    NSString *path = invocation.params[@"path"];
    NSString *filePath = [self fullPathWithPath:path];
    
    NSError *error;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
    if (error) {
        return nil;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *date = [df stringFromDate:fileAttributes.fileModificationDate];
    
    NSDictionary *info = @{
                           @"size": @(fileAttributes.fileSize),
                           @"modifiedTime": date,
                           @"path": filePath
                           };
    return info;
}

- (void)open:(SummerInvocation *)invocation {
    
    NSString *path = invocation.params[@"filepath"];
    NSString *filePath = [self fullPathWithPath:path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        self.filePath = filePath;
        
        QLPreviewController *qlViewController = [[QLPreviewController alloc] init];
        qlViewController.dataSource = self;
        [invocation.sender presentViewController:qlViewController animated:YES completion:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"未找到文件：%@", path];
        [UIAlertController showAlertWithTitle:@"提示" message:message];
    }
}

- (id)exists:(SummerInvocation *)invocation {
    
    NSString *path = invocation.params[@"path"];
    NSString *file = invocation.params[@"file"];
    if (path.length * file.length == 0) {
        return @"false";
    }
    
    NSString *filePath = [self fullPathWithPath:[path stringByAppendingPathComponent:file]];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath] ? @"true" : @"false";
}

- (void)remove:(SummerInvocation *)invocation {

    NSString *path = invocation.params[@"path"];
    NSString *file = invocation.params[@"file"];
    NSString *filePath = [self fullPathWithPath:[path stringByAppendingPathComponent:file]];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[@"path"] = path;
    result[@"file"] = file;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {

        NSError *error;
        if ([[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]) {
            result[@"delStatus"] = @"1";
            result[@"status"] = @"success";
        }
        else {
            result[@"delStatus"] = @"0";
            result[@"status"] = error.localizedDescription;
        }
    }
    else {
        NSString *message = [NSString stringWithFormat:@"未找到文件：%@", path];
        result[@"delStatus"] = @"0";
        result[@"status"] = message;
    }
    [invocation callbackWithObject:result resultType:SummerInvocationResultTypeOriginal];
}

#pragma mark <QLPreviewControllerDataSource>

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {    
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    
    return [NSURL fileURLWithPath:self.filePath];
}

@end
