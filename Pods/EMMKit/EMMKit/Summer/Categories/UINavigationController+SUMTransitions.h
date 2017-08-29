//
//  UINavigationController+SUMTransitions.h
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (SUMTransitions)

@property (nonatomic, assign) BOOL shouldTakeOverDelegate;  // 接管 UINavigationController 的 delegate，用于 push 动画

@end
