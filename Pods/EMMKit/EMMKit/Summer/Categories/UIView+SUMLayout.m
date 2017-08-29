//
//  UIView+SUMLayout.m
//  SummerDemo
//
//  Created by Chenly on 16/9/13.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "UIView+SUMLayout.h"
#import <Masonry/Masonry.h>

@implementation UIView (SUMLayout)

- (void)setLayoutConstraintsWithPositions:(NSDictionary *)positions {
    
    UIView *superview = self.superview;
    if (positions) {
        
        CGFloat left   = positions[@"left"] ? [positions[@"left"] floatValue] : 0;
        CGFloat top    = positions[@"top"] ? [positions[@"top"] floatValue] : 0;
        
        BOOL hasRight = NO;
        CGFloat right = ({
            CGFloat floatValue;
            NSString *stringValue = positions[@"right"];
            if (stringValue) {
                floatValue = [stringValue floatValue];
                hasRight = YES;
            }
            floatValue;
        });
        
        BOOL hasBottom = NO;
        CGFloat bottom = ({
            CGFloat floatValue;
            NSString *stringValue = positions[@"bottom"];
            if (stringValue) {
                floatValue = [stringValue floatValue];
                hasBottom = YES;
            }
            floatValue;
        });
        
        // right 优先，如果没有 right 则取 width
        CGFloat width;
        if (!hasRight) {
            width = ({
                CGFloat floatValue;
                NSString *stringValue = positions[@"width"];
                if (stringValue) {
                    if ([stringValue isEqual:@"auto"]) {
                        hasRight = YES;
                        right = 0;
                    }
                    else {
                        floatValue = [stringValue floatValue];
                    }
                }
                floatValue;
            });
        }
        
        // 同 width
        CGFloat height;
        if (!hasBottom) {
            height = ({
                CGFloat floatValue;
                NSString *stringValue = positions[@"height"];
                if (stringValue) {
                    if ([stringValue isEqual:@"auto"]) {
                        hasBottom = YES;
                        bottom = 0;
                    }
                    else {
                        floatValue = [stringValue floatValue];
                    }
                }
                floatValue;
            });
        }
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(superview.mas_top).offset(top);
            make.left.equalTo(superview.mas_left).offset(left);
            
            CGFloat topInset = 0;
            if ([superview isKindOfClass:[UIScrollView class]]) {
                topInset = ((UIScrollView *)superview).contentInset.top;
            }
            if (hasBottom) {
                make.height.equalTo(superview).offset(-(bottom + top + topInset));
            }
            else {
                make.height.equalTo(@(height));
            }
            
            if (hasRight) {
                make.width.equalTo(superview).offset(-(right + left));
            }
            else {
                make.width.equalTo(@(width));
            }
        }];
    }
    else {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview);
            make.top.equalTo(superview);
            make.width.equalTo(superview);
            make.height.equalTo(superview);
        }];
    }
    [superview setNeedsLayout];
}

@end
