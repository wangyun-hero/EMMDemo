//
//  SummerWebSettingService.m
//  SummerDemo
//
//  Created by zm on 16/8/2.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerWebSettingService.h"
#import <objc/runtime.h>


@implementation SummerWebSettingService

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerWebSettingService *webSettingSharedInstance;
    dispatch_once(&onceToken, ^{
        webSettingSharedInstance = [[SummerWebSettingService alloc] init];
    });
    return webSettingSharedInstance;
}

- (void)setDict:(NSDictionary *)dict {
    if(dict.count &&dict ){
        Class c = self.class;
        while (c &&c != [NSObject class]) {
            
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList(c, &outCount);
            for (int i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                
                // 成员变量名转为属性名（去掉下划线 _ ）
                key = [key substringFromIndex:1];
                // 取出字典的值
                for(NSString *dicKey in [dict allKeys]){
                    if([key isEqualToString:dicKey]){
                        id value = dict[key];
                        if(value == nil) {
                            continue;
                        }
                        
                        [self setValue:value forKeyPath:key];
                        
                    }
                }
               
            }
            free(ivars);
            c = [c superclass];
        }
    }
}
@end
