//
//  SummerServices.m
//  SummerExample
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerServices.h"

@implementation SummerServices

static NSMutableDictionary *summerServices;

+ (void)registerService:(NSString *)serviceName class:(NSString *)className {
    
    if (!summerServices) {
        summerServices = [NSMutableDictionary dictionary];
    }
    summerServices[serviceName] = className;
}

+ (Class)classForService:(NSString *)serviceName {
    
    NSString *className = summerServices[serviceName] ?: serviceName;
    return NSClassFromString(className);
}

@end
