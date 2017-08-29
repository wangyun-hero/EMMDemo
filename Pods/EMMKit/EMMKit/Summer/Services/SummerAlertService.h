//
//  SummerAlertService.h
//  EMMKitDemo
//
//  Created by Chenly on 16/8/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SummerServices.h"

@class SummerInvocation;

@interface SummerAlertService : NSObject <SummerServiceProtocol>

- (void)showLoadingBar:(SummerInvocation *)invocation;
- (void)hideLoadingBar:(SummerInvocation *)invocation;

@end
