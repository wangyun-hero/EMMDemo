//
//  AppCenterAssistiveTouch.h
//  EMMPortalDemo
//
//  Created by zm on 16/7/11.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppCenterAssistiveTouch;
@protocol AppCenterAssistiveTouchDelegate <NSObject>

- (void)selectedAssistiveTouchItem:(NSInteger)tag;

@end

@interface AppCenterAssistiveTouch : UIWindow

@property (nonatomic, assign) id<AppCenterAssistiveTouchDelegate>  delegate;
@property (nonatomic, strong) NSMutableArray *assistiveTouchItemArray;
@property (nonatomic, strong) NSString *currentKey;

- (void)reloadItems;
- (void)shrink;
@end
