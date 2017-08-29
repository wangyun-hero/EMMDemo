//
//  EMMAPIs.h
//  SummerDemo
//
//  Created by Chenly on 2017/2/24.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMMAppModel;

@interface EMMAPIs : NSObject

+ (instancetype)sharedInstance;

- (void)fetchApps:(void(^)(NSArray<EMMAppModel *> *apps, NSError *error))completion;

@end
