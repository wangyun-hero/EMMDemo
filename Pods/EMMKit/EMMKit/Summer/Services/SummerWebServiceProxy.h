//
//  SummerWebServiceProxy.h
//  SummerDemo
//
//  Created by zm on 16/8/3.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SummerWebServiceProxy : NSObject


+ (void)requestNetMethod:(NSString *)method urlString:(NSString *)urlString requestBody:(NSData *)requestBody timeout:(CGFloat)timeout completionHandler:(void (^)(id result, BOOL succeed))completionHandler;

+ (void)requestNetMethod:(NSString *)method urlString:(NSString *)urlString requestBody:(NSData *)requestBody timeout:(CGFloat)timeout header:(NSDictionary *)header completionHandler:(void (^)(id result, BOOL succeed))completionHandler;

+ (BOOL)isNetReachable;
@end




