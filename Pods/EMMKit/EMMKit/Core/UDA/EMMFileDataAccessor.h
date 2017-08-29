//
//  EMMFileDataAccessor.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMDataAccessor.h"

@interface EMMFileDataAccessor : EMMDataAccessor

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *filePath;

/**
 params: {
 "filename": "file.json" // or "filePath": "file://xx/file.json"(优先)
 }
 */
- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

@end
