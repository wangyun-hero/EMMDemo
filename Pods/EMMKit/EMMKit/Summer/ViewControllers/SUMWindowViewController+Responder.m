//
//  SUMWindowViewController+Responder.m
//  SummerDemo
//
//  Created by zm on 2017/3/4.
//  Copyright © 2017年 Yonyou. All rights reserved.
//

#import "SUMWindowViewController+Responder.h"

@implementation SUMWindowViewController (Responder)


- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(self.responderDelegate && [self.responderDelegate respondsToSelector:@selector(motionBegan:withEvent:)]){
        [self.responderDelegate motionBegan:motion withEvent:event];
    }
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(self.responderDelegate && [self.responderDelegate respondsToSelector:@selector(motionEnded:withEvent:)]){
        [self.responderDelegate motionEnded:motion withEvent:event];
    }
}
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if(self.responderDelegate && [self.responderDelegate respondsToSelector:@selector(motionCancelled:withEvent:)]){
        [self.responderDelegate motionCancelled:motion withEvent:event];
    }
}

@end
