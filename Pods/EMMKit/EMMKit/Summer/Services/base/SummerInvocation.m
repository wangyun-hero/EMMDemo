//
//  SummerArgs.m
//  SummerExample
//
//  Created by Chenly on 16/6/20.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerInvocation.h"
#import "SUMViewController.h"
#import <objc/runtime.h>
#import <JavaScriptCore/JSContext.h>

@interface SummerInvocation ()

@property (nonatomic, assign) SEL selector;

@end

@implementation SummerInvocation

- (instancetype)initWithTarget:(id)target
                        method:(NSString *)method
                        params:(NSDictionary *)params
                      callback:(NSString *)callback
                        sender:(id)sender {
    
    if (self = [super init]) {
        
        _target = target;
        _method = [method copy];
        _params = [params copy];
        _callback = [callback copy];
        _sender = sender;
        if (method) {
            _selector = NSSelectorFromString([method stringByAppendingString:@":"]);
        }
    }
    return self;
}

+ (instancetype)invocationWithTarget:(id)target method:(NSString *)method params:(NSDictionary *)params callback:(NSString *)callback sender:(id)sender {
    
    return [[SummerInvocation alloc] initWithTarget:target method:method params:params callback:callback sender:sender];
}

- (void)check:(NSString *)key {
    NSAssert([self.params.allKeys containsObject:key], @"Not Found Parameter: %@", key);
}

- (id)invoke {
    
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    Method method;
    if (self.target == [self.target class]) {
        method = class_getClassMethod(self.target, self.selector);
    }
    else {
        method = class_getInstanceMethod([self.target class], self.selector);
    }
    if (method == NULL) {
        NSLog(@"Not Found Method: %@ Class: %@", NSStringFromSelector(self.selector), NSStringFromClass([self.target class]));
        return nil;
    }
    const char *type = method_getTypeEncoding(method);
    if (type[0] == 'v') {
        // 无返回值
        [self.target performSelector:self.selector withObject:self];
        return nil;
    }
    else {
        return [self.target performSelector:self.selector withObject:self];
    }
#pragma clang diagnostic pop
    
}

- (void)callbackWithObject:(id)obj {
    
    [self callbackWithObject:obj resultType:SummerInvocationResultTypeStringInBindfield];
}

- (void)callbackWithObject:(id)obj resultType:(SummerInvocationResultType)resultType {
    
    NSString *callback = (resultType == SummerInvocationResultTypeError || resultType == SummerInvocationResultTypeErrorOriginal) ? self.errorFunction : self.callback;
    if (callback) {
        if ([self.sender isKindOfClass:[SUMViewController class]]) {
            
            NSString *resultString = [obj isKindOfClass:[NSString class]] ? obj : @"";
            if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
                // 将 JSON 对象转化为 String
                resultString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:obj options:0 error:nil] encoding:NSUTF8StringEncoding];
            }
            else {
                resultString = obj;
            }
            
            // 返回绑定字段
            NSString *bindfield = self.bindfield ?: @"result";
            
            NSString *script;
            NSMutableDictionary *responseObj = [NSMutableDictionary dictionary];
            responseObj[bindfield] = resultString;
            
            switch (resultType) {
                case SummerInvocationResultTypeOriginal:
                case SummerInvocationResultTypeErrorOriginal:
                {
                    script = [callback stringByReplacingOccurrencesOfString:@"()" withString:[NSString stringWithFormat:@"(%@)", resultString]];
                }
                    break;
                case SummerInvocationResultTypeString:
                case SummerInvocationResultTypeError:
                {
                    NSString *responseString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObj options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    script = [callback stringByReplacingOccurrencesOfString:@"()" withString:[NSString stringWithFormat:@"(%@.%@)", responseString, bindfield]];
                }
                    break;
                case SummerInvocationResultTypeStringInBindfield:
                {
                    NSString *responseString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:responseObj options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
                    script = [callback stringByReplacingOccurrencesOfString:@"()" withString:[NSString stringWithFormat:@"(%@)", responseString]];
                }
                    break;
            }
            script = [NSString stringWithFormat:@"setTimeout( function() { %@ }, 0);", script];
            
            SUMViewController *summer = (SUMViewController *)self.sender;
            
            JSContext *webJSContext = [summer.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
            [webJSContext evaluateScript:script];
        }
    }
}

@end
