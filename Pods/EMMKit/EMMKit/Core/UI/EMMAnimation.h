//
//  EMMAnimation.h
//  EMMKitDemo
//
//  Created by 振亚 姜 on 16/6/24.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMAnimation : NSObject

//* 切换rooterViewController时的动画 */
+ (void)addAnimationToWindowWithduration:(float)duration fromDirection:(NSString *)direction target:(id)target;

@end
