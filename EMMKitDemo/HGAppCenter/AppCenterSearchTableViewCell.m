//
//  AppCenterSearchTableViewCell.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/2.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "AppCenterSearchTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation AppCenterSearchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAppModel:(HGAppModel *)appModel{
    self.appName.text = appModel.title;
    [self.appIcon sd_setImageWithURL:[NSURL URLWithString:appModel.iconurl] placeholderImage:[UIImage imageNamed:@"HGApp_placeholder.png"]];
    
}

@end
