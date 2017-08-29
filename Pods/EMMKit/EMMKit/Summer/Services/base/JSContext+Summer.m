//
//  JSContext+Summer.m
//  SummerDemo
//
//  Created by Chenly on 16/8/22.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "JSContext+Summer.h"
#import <objc/runtime.h>

@implementation JSContext (Summer)

static char senderKey;

- (id)sender {
    return objc_getAssociatedObject(self, &senderKey);
}

- (void)setSender:(id)sender {
    objc_setAssociatedObject(self, &senderKey, sender, OBJC_ASSOCIATION_ASSIGN);
}

@end
