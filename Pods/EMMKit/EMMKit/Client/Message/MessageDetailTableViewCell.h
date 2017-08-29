//
//  MessageDetailTableViewCell.h
//  EMMPortalDemo
//
//  Created by zm on 16/6/21.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatBubbleView.h"
#import "MessageModel.h"
#import "YYIMLabel.h"

@interface MessageDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ChatBubbleView *chatBubbleView;
@property (weak, nonatomic) IBOutlet UILabel *Infolabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet YYIMLabel *timeLabel;

+ (CGFloat)heightForCellWithData:(MessageModel *)message isTimeShow:(BOOL) isTimeShow;
@end
