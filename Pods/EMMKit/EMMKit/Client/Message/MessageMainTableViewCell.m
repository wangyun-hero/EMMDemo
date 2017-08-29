//
//  MessageMainTableViewCell.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "MessageMainTableViewCell.h"

@implementation MessageMainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CALayer *badgeLayer = [self.badgeLabel layer];
    [badgeLayer setMasksToBounds:YES];
    [badgeLayer setCornerRadius:9];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHeadImage:(UIImage *)headImage{
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 24;
    [self.headImageView setImage:headImage];
}

- (void)setBadge:(NSString *)badge {
    if (!badge || [badge isEqualToString:@"0"]) {
        [self.badgeLabel setText:nil];
        [self.badgeLabel setHidden:YES];
    } else {
        NSInteger badgeNumber = badge.integerValue;
        if (badgeNumber > 9) {
            badge = [NSString stringWithFormat:@"%@   ", badge];
        } else if (badgeNumber > 99) {
            badge = @" 99+ ";
        }
        [self.badgeLabel setText:badge];
        [self.badgeLabel setHidden:NO];
    }
}

@end
