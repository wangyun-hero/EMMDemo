//
//  EMMVersionManager.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/25.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMVersionManager : NSObject

@property (nonatomic, readonly) NSString *version;

+ (instancetype)sharedInstance;
- (void)checkVersion;
- (void)checkVersionInAppStore;

@end
