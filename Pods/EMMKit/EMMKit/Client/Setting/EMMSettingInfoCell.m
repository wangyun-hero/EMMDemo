//
//  MyInfoTableViewCell.m
//  BusinessFamilyV2
//
//  Created by zhangjlt on 15/12/28.
//  Copyright (c) 2015年 donglei. All rights reserved.
//

#import "EMMSettingInfoCell.h"
#import "UIImageView+WebCache.h"

@interface EMMSettingInfoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLable;

@end

@implementation EMMSettingInfoCell

- (void)setName:(NSString *)name {
    
    _name = [name copy];
    self.nameLable.text = name;
}

- (void)setAvatarImage:(UIImage *)avatarImage {

    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.layer.cornerRadius = 25;
    self.avatarImg.image = avatarImage;
}

- (void)setAvatarImageWithURL:(NSString *)imageURL {
    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.layer.cornerRadius = 25;
    [self.avatarImg sd_setImageWithURL:[NSURL URLWithString:imageURL]
                      placeholderImage:[UIImage imageNamed:@"emm_avatar_placeholder.png"]];
}

@end
