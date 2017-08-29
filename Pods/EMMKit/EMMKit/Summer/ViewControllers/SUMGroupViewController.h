//
//  SUMGroupViewController.h
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SUMWindowViewController;
@class SUMFrameViewController;
@protocol SUMPreRenderDelegate;

@interface SUMGroupViewController : UIViewController

@property (nonatomic, copy) NSString *sumId;
@property (nonatomic, weak) SUMWindowViewController *window;
@property (nonatomic, readonly) NSArray<SUMFrameViewController *> *frames;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (instancetype)initWithSumId:(NSString *)sumId frames:(NSArray<SUMFrameViewController *> *)frames;

@property (nonatomic, copy) NSDictionary *positions;
- (void)setLayoutConstraintsWithPositions:(NSDictionary *)positions;

- (void)preRenderWithIndex:(NSInteger)index observer:(id<SUMPreRenderDelegate>)observer;

- (void)setAttributes:(NSDictionary *)attributes;
- (void)setAttribute:(id)value forAttributeName:(NSString *)attributeName;

@end
