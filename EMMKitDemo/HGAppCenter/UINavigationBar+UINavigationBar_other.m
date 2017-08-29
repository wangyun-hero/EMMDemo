//
//  UINavigationBar+UINavigationBar_other.m
//  EMMKitDemo
//
//  Created by 王云 on 2017/7/9.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "UINavigationBar+UINavigationBar_other.h"

@implementation UINavigationBar (UINavigationBar_other)

-(void)getnavBarColor:(UIColor *)color
{
    UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 64)];
    backView.backgroundColor = color;
    [self setValue:backView forKey:@"backgroundView"];
}

@end
