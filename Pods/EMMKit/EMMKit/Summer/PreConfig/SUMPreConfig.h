//
//  SUMPreConfig.h
//  SummerDemo
//
//  Created by Chenly on 16/8/1.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUMPreConfig : NSObject

@property (nonatomic, copy) NSString *statusBarStyle;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, assign) BOOL isFullScreenLayout;  // 是否使用状态栏的20高度
@property (nonatomic, assign) BOOL navigationBarHidden;
@property (nonatomic, assign) NSUInteger supportedOrientation;

+ (instancetype)sharedInstance;

@end
