//
//  PersonalInfoTableViewCell.h
//  BusinessFamilyV2
//
//  Created by 周末 on 15/7/8.
//  Copyright (c) 2015年 donglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMPersonInfoAvatarCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

- (void)setAvatarImage:(UIImage *)avatarImage;
- (void)setAvatarImageWithURL:(NSString *)imageURL;

@end
