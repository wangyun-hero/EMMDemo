//
//  HGMessageMainViewCell.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGMessageMainViewCell.h"
@interface HGMessageMainViewCell()
@property (weak, nonatomic) IBOutlet UIView *backView;

@end
@implementation HGMessageMainViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    CALayer *badgeLayer = [self.badgeLabel layer];
    [badgeLayer setMasksToBounds:YES];
    [badgeLayer setCornerRadius:9];
    
    self.backView.layer.cornerRadius = 10;
    self.backView.layer.masksToBounds = YES;
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
