//
//  EMMAnimation.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/1.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMAnimation.h"

@implementation EMMAnimation

+ (void)addAnimationToWindowWithduration:(float)duration fromDirection:(NSString *)direction target:(id)target {
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    if ([direction isEqualToString:@"left"]) {
        transition.subtype = kCATransitionFromLeft;
    }else if ([direction isEqualToString:@"right"]){
        transition.subtype = kCATransitionFromRight;
    }
    else if ([direction isEqualToString:@"top"]){
        transition.subtype = kCATransitionFromTop;
    }else if ([direction isEqualToString:@"bottom"]){
        transition.subtype = kCATransitionFromBottom;
    }else{
        transition.subtype = kCATransitionFromRight;
    }
    transition.delegate = target;
    [[UIApplication sharedApplication].keyWindow.layer addAnimation:transition forKey:nil];
}

@end
