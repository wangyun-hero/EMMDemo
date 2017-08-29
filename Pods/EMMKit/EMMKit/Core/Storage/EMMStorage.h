//
//  EMMStorage.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

// 存储位置
typedef NS_ENUM(NSUInteger, EMMStorageLocation) {
    EMMStorageLocationApplicationContext = 0,   // 全局上下文
    EMMStorageLocationConfigure,                // sum_appconfigure.plist 文件
};

@interface EMMStorage : NSObject

+ (instancetype)sharedInstance;

/**
 *  读写参数
 */
- (void)setValue:(id)value forKey:(NSString *)key toLocation:(EMMStorageLocation)location;
- (id)valueForKey:(NSString *)key fromLocation:(EMMStorageLocation)location;

@end
