//
//  EMMStorage.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMStorage.h"
#import "EMMApplicationContext.h"

@implementation EMMStorage
{
    NSURL *_configFile;
    NSMutableDictionary *_configContexts;
}

static NSString * const kConfigureFile = @"emm_storage_config.plist";

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EMMStorage *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMStorage alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *documentDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        _configFile = [documentDir URLByAppendingPathComponent:kConfigureFile];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_configFile.path]) {
            _configContexts = [NSMutableDictionary dictionaryWithContentsOfURL:_configFile];
        }
        if (!_configContexts) {
            _configContexts = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key toLocation:(EMMStorageLocation)location {
    
    if (location == EMMStorageLocationApplicationContext) {
        [[EMMApplicationContext defaultContext] setObject:value forKey:key];
    }
    else {
        _configContexts[key] = value;
        [_configContexts writeToURL:_configFile atomically:YES];
    }
}

- (id)valueForKey:(NSString *)key fromLocation:(EMMStorageLocation)location {
    
    if (location == EMMStorageLocationApplicationContext) {
        return [[EMMApplicationContext defaultContext] objectForKey:key];
    }
    else {
        return _configContexts[key];
    }
}

@end
