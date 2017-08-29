//
//  EMMLocationService.h
//  EMMKitDemo
//
//  Created by Chenly on 16/6/22.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

@interface EMMLocationService : NSObject

@property (nonatomic, assign) BOOL isOpen;

+ (instancetype)sharedInstance;

- (void)beginLocationService;
- (void)stopLocationService;

@end
