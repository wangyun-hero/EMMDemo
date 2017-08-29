//
//  MyInfoTableViewCell.h
//  BusinessFamilyV2
//
//  Created by zhangjlt on 15/12/28.
//  Copyright (c) 2015年 donglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMSettingInfoCell : UITableViewCell

@property (nonatomic, copy) NSString *name;

- (void)setAvatarImage:(UIImage *)avatarImage;
- (void)setAvatarImageWithURL:(NSString *)imageURL;

@end
