//
//  SummerAnimatedTransition.h
//  EMMKitDemo
//
//  Created by Chenly on 16/8/24.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUMAnimatedTransition;

@protocol SUMAnimatedTransitionAvailable <NSObject>

- (SUMAnimatedTransition *)animationControllerForOperation:(NSNumber *)operation;

@end

@interface SUMAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) UINavigationControllerOperation operation;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *subtype;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) void (^completion)(BOOL finished);

+ (instancetype)transitionWithInfo:(NSDictionary *)info
                         operation:(UINavigationControllerOperation)operation
                        completion:(void (^)(BOOL finished))completion;

@end

@interface UINavigationController (SUMTransitions)

@property (nonatomic, assign) BOOL shouldTakeOverDelegate;

@end
