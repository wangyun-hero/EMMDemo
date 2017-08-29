//
//  存储全局上下文信息
//  YYPApplicationContext.m
//  EMMClient
//
//  Created by 熊悦阅 on 16/6/16.
//  Copyright © 2016年 熊悦阅. All rights reserved.
//

#import "EMMApplicationContext.h"

@implementation EMMApplicationContext
{
    NSMutableDictionary <NSString *, NSString *> *_ctx;
}

+ (instancetype)defaultContext {
    static dispatch_once_t onceToken;
    static EMMApplicationContext *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMApplicationContext alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _ctx = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    return _ctx[key];
}

- (void)setObject:(id)value forKey:(NSString *)key {
    _ctx[key] = value;
}

- (NSString *)parserText:(NSString *)text {

    __block NSString *resultString = text;
    NSError *error;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"\\$\\{[^\\}]+\\}" options:0 error:&error];
    [expression enumerateMatchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (!result) {
            return;
        }
        NSString *searchedString = [text substringWithRange:result.range];
        NSString *key = [searchedString substringWithRange:NSMakeRange(2, searchedString.length - 3)];
        NSString *value = [self objectForKey:key] ?: @"";
        if (value.length > 0) {
            NSString *lastString = [value substringFromIndex:value.length - 1];
            if([lastString isEqualToString:@"/"]){
                value = [value substringToIndex:value.length - 1];
            }
        }
        resultString = [resultString stringByReplacingOccurrencesOfString:searchedString withString:value];
    }];
    return resultString;
}

@end
