//
//  SummerFileService.h
//  SummerDemo
//
//  Created by Chenly on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SummerServices.h"

@class SummerInvocation;

@interface SummerFileService : NSObject <SummerServiceProtocol>

- (id)write:(SummerInvocation *)invocation;
- (id)read:(SummerInvocation *)invocation;

- (void)download:(SummerInvocation *)invocation;
- (void)upload:(SummerInvocation *)invocation;

- (void)open:(SummerInvocation *)invocation;
- (id)getFileInfo:(SummerInvocation *)invocation;

- (id)exists:(SummerInvocation *)invocation;
- (void)remove:(SummerInvocation *)invocation;

@end
