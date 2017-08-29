//
//  SUMTransitionsDelegate.h
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUMAnimatedTransition;

@protocol SUMTransitionsDelegate <NSObject>

@required
- (SUMAnimatedTransition *)sum_transition;

@end
