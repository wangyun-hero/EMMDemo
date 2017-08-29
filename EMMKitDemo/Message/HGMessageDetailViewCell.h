//
//  HGMessageDetailViewCell.h
//  EMMKitDemo
//
//  Created by zm on 2016/11/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//



#import <UIKit/UIKit.h>

#import "ChatBubbleView.h"
#import "MessageModel.h"
#import "YYIMLabel.h"

typedef NS_ENUM(NSUInteger, CellStyle) {
     CellStyleNoSelect= 0,
     CellStyleSelect = 1 << 1,
    CellStyleURL = 1 << 2,
};

@class HGMessageDetailViewCell;
@protocol HGMessageDetailViewCellDelegate <NSObject>

- (void)didSelectedChatWithMessage:(MessageModel *)model;

@end

@interface HGMessageDetailViewCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet ChatBubbleView *chatBubbleView;
@property (weak, nonatomic) IBOutlet UILabel *Infolabel;
//@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet YYIMLabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *line;
@property (weak, nonatomic) IBOutlet UIImageView *rightImage;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) NSInteger cellStyle;

@property (nonatomic, strong) MessageModel  *messageModel;
@property (nonatomic) id<HGMessageDetailViewCellDelegate> delegate;

+ (CGFloat)heightForCellWithData:(MessageModel *)message isTimeShow:(BOOL) isTimeShow cellStyle:(NSInteger)cellStyle;

- (void)reloadStyle;

@end
