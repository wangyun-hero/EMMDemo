//
//  SUMFrameAnimation.h
//  SummerDemo
//
//  Created by Chenly on 16/9/13.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUMFrameViewController;

@interface SUMFrameAnimation : NSObject <NSCopying>

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *subtype;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) void (^completion)(BOOL finished);

@property (nonatomic, weak) SUMFrameViewController *frame;

+ (instancetype)animationWithInfo:(NSDictionary *)info completion:(void (^)(BOOL finished))completion;

@end

@interface UIView (SUMFrameAnimation)

- (void)sum_performFrameAnimation:(SUMFrameAnimation *)animation;

@end
