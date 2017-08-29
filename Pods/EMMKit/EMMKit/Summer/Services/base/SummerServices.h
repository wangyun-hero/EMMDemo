//
//  SummerServices.h
//  SummerExample
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SummerServiceProtocol <NSObject>

@required
+ (id)instanceForServices;

@end

@interface SummerServices : NSObject

+ (void)registerService:(NSString *)serviceName class:(NSString *)className;
+ (Class)classForService:(NSString *)serviceName;

@end
