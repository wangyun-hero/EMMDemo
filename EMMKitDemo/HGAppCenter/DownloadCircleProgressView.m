//
//  DownloadCircleProgressView.m
//  EMMKitDemo
//
//  Created by zm on 16/9/23.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "DownloadCircleProgressView.h"

#define CircleMargin 3
#define ColorMaker(r, g, b, a) [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]

@implementation DownloadCircleProgressView

- (instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 17;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if(self.circleProgressStyle == CircleProgressStyleDefault){
        [self initDefaultStyle:rect];
    }
    else if(self.circleProgressStyle == CircleProgressStyleDownloading){
        [self creatDownloadStyle:rect];
    }
    else{
        [[UIColor clearColor] set];
    }
}

- (void)initDefaultStyle:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    // 斜边长
    CGFloat radius = hypot(rect.size.width * 0.5,rect.size.height*0.5);
    
    [ColorMaker(240, 240, 240, 0.7) set];
    CGContextSetLineWidth(ctx, 1);
    CGContextAddArc(ctx, xCenter, yCenter, radius, 0, M_PI * 2, 1);
    
    CGContextFillPath(ctx);
}

- (void)creatDownloadStyle:(CGRect)rect{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    // 斜边长
    CGFloat hypotenuse = hypot(rect.size.width * 0.5,rect.size.height*0.5);
    
    // 进程圆半径
    CGFloat radius = hypotenuse *0.4;
    
    // 背景遮罩
//    if(self.progressValue>=  1.0){
//        [[UIColor clearColor] set];
//    }
//    else{
        [ColorMaker(0, 0, 0, 0.7) set];
//    }
    CGFloat lineW = hypotenuse*1.1;
    CGContextSetLineWidth(ctx, lineW);
    CGContextAddArc(ctx, xCenter, yCenter, hypotenuse, 0, M_PI * 2, 1);
    CGContextStrokePath(ctx);
    
    // 进程圆
//    if(self.progressValue>= 1.0){
//        [[UIColor clearColor] set];
//    }
//    else{
        [ColorMaker(0, 0, 0, 0.7) set];
//    }
    CGContextSetLineWidth(ctx, 1);
    CGContextMoveToPoint(ctx, xCenter, yCenter);
    CGContextAddLineToPoint(ctx, xCenter, 0);
    CGFloat to = - M_PI * 0.5 + self.progressValue * M_PI * 2 + 0.001; // 初始值
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
    CGContextClosePath(ctx);
    
    CGContextFillPath(ctx);
    
}


@end
