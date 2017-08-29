//
//  SUMPreRender.h
//  SummerDemo
//
//  Created by Chenly on 16/9/14.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUMPreRender;

@protocol SUMPreRenderDelegate <NSObject>

@required
- (void)preRender:(SUMPreRender *)preRender didViewControllerFinishedRender:(UIViewController *)viewController;

@end

@interface SUMPreRender : NSObject

+ (instancetype)sharedInstance;

- (void)beginPreRenderingViewController:(UIViewController *)viewController observer:(id<SUMPreRenderDelegate>)observer;
- (void)finishPreRenderingViewController:(UIViewController *)viewController;

@end

@interface UIViewController (SUMPreRender)

@property (nonatomic, assign) BOOL beenPreRendered;

@end
