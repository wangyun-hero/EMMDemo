//
//  AppCenterAssistiveTouchItem.h
//  EMMPortalDemo
//
//  Created by zm on 16/7/11.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AssistiveTouchItemModel.h"

typedef NS_ENUM(NSInteger, EMMAssistiveTouchItemType) {
    EMMItemViewTypeSystem = 0,
    EMMItemViewTypeCustomer,
    EMMItemViewTypeOpeningCustomer,
    EMMItemViewTypeBack,
};

@interface AppCenterAssistiveTouchItem : UIView

- (instancetype) initWithFrame:(CGRect)frame  type:(EMMAssistiveTouchItemType)type;

- (instancetype) initWithFrame:(CGRect)frame itemModel:(AssistiveTouchItemModel *)itemModel type:(EMMAssistiveTouchItemType)type;

@property (nonatomic) NSInteger itemTag;
@end
