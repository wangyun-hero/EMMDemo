//
//  SUMFrameAnimation.m
//  SummerDemo
//
//  Created by Chenly on 16/9/13.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMFrameAnimation.h"
#import "SUMWindowViewController.h"
#import "SUMFrameViewController.h"

@implementation SUMFrameAnimation

static NSTimeInterval const kDefaultDuration = 0.3;

- (instancetype)initWithInfo:(NSDictionary *)info completion:(void (^)(BOOL finished))completion {

    if (self = [super init]) {
        
        NSString *type = info[@"type"];
        if (!type || [type isEqualToString:@"none"]) {
            return nil;
        }        
        NSString *subtype = info[@"subType"];
        NSTimeInterval duration = info[@"duration"] ? [info[@"duration"] floatValue] / 1000.f : kDefaultDuration;
        NSDictionary *params = info[@"params"];
        
        _type       = type;
        _subtype    = subtype;
        _duration   = duration;
        _params     = params;
        _completion = completion;
    }
    return self;
}

+ (instancetype)animationWithInfo:(NSDictionary *)info completion:(void (^)(BOOL finished))completion {

    return [[self alloc] initWithInfo:info completion:completion];
}

- (id)copyWithZone:(NSZone *)zone {
    SUMFrameAnimation *copy = [[SUMFrameAnimation alloc] init];
    copy.type = self.type;
    copy.subtype = self.subtype;
    copy.params = self.params;
    copy.params = self.params;
    copy.completion = self.completion;
    return copy;
}

@end

@implementation UIView (SUMFrameAnimation)

- (void)sum_performFrameAnimation:(SUMFrameAnimation *)animation {

    if (!animation) {
        return;
    }
    if ([animation.type isEqualToString:@"movein"]) {
        [self sum_movein:animation];
    }
    else if ([animation.type isEqualToString:@"push"]) {
        [self sum_push:animation];
    }
    else if ([animation.type isEqualToString:@"fade"]) {
        [self sum_fade:animation];
    }
}

- (void)sum_movein:(SUMFrameAnimation *)animation {

    CGRect fromValue;
    CGRect toValue;
    
    if (animation.subtype) {
        
        UIView *superview = self.superview;
        NSString *subtype = animation.subtype;
        
        toValue = self.frame;
        fromValue = self.frame;
        if ([subtype isEqualToString:@"from_top"]) { fromValue.origin.y = -CGRectGetHeight(fromValue); }
        else if ([subtype isEqualToString:@"from_left"]) { fromValue.origin.x = -CGRectGetWidth(fromValue); }
        else if ([subtype isEqualToString:@"from_bottom"]) { fromValue.origin.y = [superview sum_rightSideFrame].size.height; }
        else if ([subtype isEqualToString:@"from_right"]) { fromValue.origin.x = [superview sum_leftSideFrame].size.width; }
        else {
            animation.completion(NO);
            return;
        };
    }
    else {
        CGFloat fromX = [animation.params[@"fromX"] floatValue];
        CGFloat fromY = [animation.params[@"fromY"] floatValue];
        CGFloat toX = [animation.params[@"toX"] floatValue];
        CGFloat toY = [animation.params[@"toY"] floatValue];
        
        fromValue = self.frame;
        fromValue.origin.x = fromX;
        fromValue.origin.y = fromY;
        toValue = self.frame;
        toValue.origin.x = toX;
        toValue.origin.y = toY;
    }
    
    self.frame = fromValue;
    [UIView animateWithDuration:animation.duration animations:^{
        self.frame = toValue;
    } completion:animation.completion];
}

- (void)sum_push:(SUMFrameAnimation *)animation {
    // 暂不支持
}

- (void)sum_fade:(SUMFrameAnimation *)animation {
    
    self.alpha = 0;
    [UIView animateWithDuration:animation.duration animations:^{
        self.alpha = 1.0;
    } completion:animation.completion];    
}

- (CGRect)sum_topSideFrame {
    
    CGRect rect = self.frame;
    rect.origin.y -= CGRectGetHeight(rect);
    return rect;
}

- (CGRect)sum_leftSideFrame {
    
    CGRect rect = self.frame;
    rect.origin.x -= CGRectGetWidth(rect);
    return rect;
}

- (CGRect)sum_bottomSideFrame {
    
    CGRect rect = self.frame;
    rect.origin.y += CGRectGetHeight(rect);
    return rect;
}

- (CGRect)sum_rightSideFrame {
    
    CGRect rect = self.frame;
    rect.origin.x += CGRectGetWidth(rect);
    return rect;
}

@end
