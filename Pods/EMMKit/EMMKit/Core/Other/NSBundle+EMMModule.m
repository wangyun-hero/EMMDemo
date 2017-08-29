//
//  NSBundle+EMMModule.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "NSBundle+EMMModule.h"

@implementation NSBundle (EMMModule)

+ (instancetype)emm_bundleWithModule:(NSString *)module {
    
    return [[self alloc] emm_initWithModule:module];
}

- (instancetype)emm_initWithModule:(NSString *)module {

    NSString *path = [[NSBundle mainBundle] pathForResource:[@"emm_" stringByAppendingString:module] ofType:@"bundle"];
    return [self initWithPath:path];
}

@end

@implementation UIImage (EMMModule)

+ (UIImage *)emm_imageNamed:(NSString *)name inModule:(NSString *)module {
    
    return [UIImage imageNamed:name inBundle:[NSBundle emm_bundleWithModule:module] compatibleWithTraitCollection:nil];
}

@end