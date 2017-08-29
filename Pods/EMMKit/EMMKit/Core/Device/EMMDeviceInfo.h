//
//  EMMDeviceInfo.h
//  EMMFoundationDemo
//
//  Created by Chenly on 16/6/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMDeviceInfo : NSObject

+ (instancetype)currentDeviceInfo;

- (NSString *)UUID;
- (NSString *)SSID;

@end
