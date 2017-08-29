//
//  ChatBubbleView.h
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kYMChatBorderColorLeft @"0xededed"
#define kYMChatBackgroundColorLeft @"0xffffff"

//zwk 1121 背景颜色
#define kYMChatBorderColorRight @"0x38adff"
#define kYMChatBackgroundColorRight @"0x38adff"


typedef NS_ENUM(NSInteger, YMChatBubbleDirection) {
    kYMChatBubbleDirectionLeft = 0,
    kYMChatBubbleDirectionRight = 1
};

@interface ChatBubbleView : UIView

@property (nonatomic) YMChatBubbleDirection direction;

@property (nonatomic) BOOL showArrow;

@end
