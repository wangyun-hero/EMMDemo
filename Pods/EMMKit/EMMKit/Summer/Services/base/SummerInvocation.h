//
//  SummerArgs.h
//  SummerExample
//
//  Created by Chenly on 16/6/20.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SummerInvocationResultType) {
    SummerInvocationResultTypeOriginal,             // 原始对象
    SummerInvocationResultTypeString,               // 将对象转为字符串
    SummerInvocationResultTypeStringInBindfield,    // 将对象转为字符串后放在 bindfield 字段中（默认）
    SummerInvocationResultTypeError,                // 回调 error 字段中的 function（字符串）
    SummerInvocationResultTypeErrorOriginal,        // 回调 error 字段中的 function（JSON 对象）
};

@interface SummerInvocation : NSObject

@property (nonatomic, weak) id sender;  // Summer 调用本地服务时，sender == viewController
@property (nonatomic, weak) id target;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, copy) NSString *callback;
@property (nonatomic, copy) NSString *errorFunction;
@property (nonatomic, copy) NSString *bindfield;    // 绑定字段，异步回调时，将返回值赋值给该字段，缺省为 result
@property (nonatomic, assign) BOOL expired; // 过期的，不执行 callback

+ (instancetype)invocationWithTarget:(id)target method:(NSString *)method params:(NSDictionary *)params callback:(NSString *)callback sender:(id)sender;
- (instancetype)initWithTarget:(id)target method:(NSString *)method params:(NSDictionary *)params callback:(NSString *)callback sender:(id)sender;

- (void)check:(NSString *)key;
- (id)invoke;
- (void)callbackWithObject:(id)obj resultType:(SummerInvocationResultType)resultType;
- (void)callbackWithObject:(id)obj;

@end
