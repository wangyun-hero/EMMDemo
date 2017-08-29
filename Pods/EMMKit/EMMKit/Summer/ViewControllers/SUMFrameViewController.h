//
//  SUMFrameViewController.h
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMViewController.h"

@class SUMWindowViewController;
@class SUMFrameViewController;
@class SUMFrameAnimation;

@protocol SUMFrameViewControllerDelegate <NSObject>

- (void)didFrameFinishedLoad:(SUMFrameViewController *)frame;

@end

@interface SUMFrameViewController : SUMViewController

@property (nonatomic, weak) SUMWindowViewController *window;
@property (nonatomic, weak) id<SUMFrameViewControllerDelegate> delegate;

@property (nonatomic, copy) NSDictionary *positions;
- (void)setLayoutConstraintsWithPositions:(NSDictionary *)positions;

@property (nonatomic, strong) SUMFrameAnimation *animation;

@end
