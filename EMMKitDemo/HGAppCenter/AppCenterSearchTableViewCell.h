//
//  AppCenterSearchTableViewCell.h
//  EMMKitDemo
//
//  Created by zm on 2016/11/2.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGAppModel.h"

@interface AppCenterSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *appIcon;
@property (weak, nonatomic) IBOutlet UILabel *appName;

- (void)setAppModel:(HGAppModel *)appModel;

@end
