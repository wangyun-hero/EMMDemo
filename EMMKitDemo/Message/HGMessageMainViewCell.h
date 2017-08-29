//
//  HGMessageMainViewCell.h
//  EMMKitDemo
//
//  Created by zm on 2016/11/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGMessageMainViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

-(void)setHeadImage:(UIImage *)headImage;
- (void)setBadge:(NSString *)badge;

@end
