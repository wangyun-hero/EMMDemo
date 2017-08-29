//
//  NSBundle+EMMModule.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (EMMModule)

+ (instancetype)emm_bundleWithModule:(NSString *)module;
- (instancetype)emm_initWithModule:(NSString *)module;

@end

@interface UIImage (EMMModule)

+ (UIImage *)emm_imageNamed:(NSString *)name inModule:(NSString *)module;

@end