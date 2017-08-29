//
//  EMMFileDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMFileDataAccessor.h"

@implementation EMMFileDataAccessor

- (instancetype)initWithModule:(NSString *)module request:(NSString *)request args:(NSDictionary *)args {
    
    if (self = [super initWithModule:module request:request args:args]) {
        
        _filePath = args[@"filePath"];
        _filename = args[@"filename"];
    }
    return self;
}

- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *filePath = params[@"filePath"] ?: self.filePath;
    NSString *filename = params[@"filename"] ?: self.filename;
    
    if (!filePath || filePath.length == 0) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"emm_demo_results" ofType:@"bundle"]];
        filePath = [bundle pathForResource:filename ofType:nil];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSString *errorMessage = [NSString stringWithFormat:@"未找到文件: %@", filename ?: filePath];
        NSError *error = [NSError errorWithDomain:errorMessage code:0 userInfo:params];
        failure(error);
        return;
    }
    
    id result;
    // 仅支持 plist 和 json（其它后缀都按 json 处理）
    if ([filePath.pathExtension isEqualToString:@"plist"]) {
        
        result = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    else {
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    
    if (result) {
        success(result);
    }
    else {
        NSString *errorMessage = [NSString stringWithFormat:@"文件解析失败: %@", filename ?: filePath];
        NSError *error = [NSError errorWithDomain:errorMessage code:0 userInfo:params];
        failure(error);
    }
}

@end
