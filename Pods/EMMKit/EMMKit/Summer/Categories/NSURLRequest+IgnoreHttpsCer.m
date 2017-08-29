//
//  NSURLRequest+IgnoreHttpsCer.m
//  SummerDemo
//
//  Created by Chenly on 2016/12/26.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "NSURLRequest+IgnoreHttpsCer.h"
#import "EMMCerManager.h"
#import <Aspects/Aspects.h>
#import <objc/runtime.h>

@implementation NSURLRequest (IgnoreHttpsCer)

+ (void)load {
    
    Class metaClass = object_getClass([NSURLRequest class]);
    SEL sel = NSSelectorFromString(@"allowsAnyHTTPSCertificateForHost:");
    [metaClass aspect_hookSelector:sel withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> info, NSString *host) {
        
        BOOL allowsAnyHTTPSCertificate = YES;
        [[info originalInvocation] setReturnValue:&allowsAnyHTTPSCertificate];
        
    } error:NULL];
}

@end
