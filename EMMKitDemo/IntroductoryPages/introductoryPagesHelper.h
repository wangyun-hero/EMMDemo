//
//  introductoryPagesHelper.h
//  MobileProject
//
//  Created by wujunyang on 16/7/14.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "introductoryPagesView.h"

@interface introductoryPagesHelper : UIViewController

+ (instancetype)shareInstance;

+ (void)showIntroductoryPageCustomView:(NSArray *)imageArray;

+ (void)showIntroductoryPageEAIntroViewView:(NSArray *)imageArray;

@end
