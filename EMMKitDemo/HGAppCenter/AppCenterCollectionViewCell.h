//
//  AppCenterCollectionViewCell.h
//  EMMKitDemo
//
//  Created by zm on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGAppModel.h"
#import "DownloadCircleProgressView.h"

@interface AppCenterCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *appIcon;
@property (weak, nonatomic) IBOutlet UILabel *appName;

@property (nonatomic, strong) NSString  *appId;
@property (nonatomic, strong) DownloadCircleProgressView *circleProgressView;

- (void)setAppModel:(HGAppModel *)appModel;
- (void)updateProgress:(CGFloat)progress;
- (void)showProgress;
@end
