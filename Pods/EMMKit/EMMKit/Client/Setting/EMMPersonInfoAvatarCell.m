//
//  PersonalInfoTableViewCell.m
//  BusinessFamilyV2
//
//  Created by 周末 on 15/7/8.
//  Copyright (c) 2015年 donglei. All rights reserved.
//

#import "EMMPersonInfoAvatarCell.h"
#import "UIImageView+WebCache.h"

@implementation EMMPersonInfoAvatarCell

- (void)setAvatarImage:(UIImage *)avatarImage {
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 22.f;
    [self.avatarImageView setImage:avatarImage];
}

- (void)setAvatarImageWithURL:(NSString *)imageURL {
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 22.f;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]
                            placeholderImage:[UIImage imageNamed:@"emm_avatar_placeholder.png"]];
}

@end
