//
//  AppCenterCollectionViewCell.m
//  EMMKitDemo
//
//  Created by zm on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "AppCenterCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "HGAppDao.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
@implementation AppCenterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setAppModel:(HGAppModel *)appModel{
    [self.circleProgressView removeFromSuperview];

    [self setImageWithUrl:appModel.iconurl andPlaceholder:@"HGApp_placeholder.png" toImageView:self.appIcon];
    self.appName.text = appModel.title;
    self.appId = appModel.applicationId;
    
    NSInteger type = [appModel.scop_type integerValue];
    if(type == 1){
        NSString *version = [[HGAppDao sharedInstance] getLocalVersion:appModel.applicationId];
        if([version isEqualToString:@"0"]){
            NSInteger p = ((SCREENWIDTH / 5) / 2) - (55 / 2) ;
            self.circleProgressView = [[DownloadCircleProgressView alloc] initWithFrame:CGRectMake(p, 8, 55, 55)];
            self.circleProgressView.circleProgressStyle = CircleProgressStyleDefault;
            [self addSubview:self.circleProgressView];
        }
    }
}

- (void)setImageWithUrl:(NSString *)url andPlaceholder:(NSString *)placeholder toImageView:(UIImageView *)imageView {
    
    if ([url hasPrefix:@"http:"]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:placeholder]];
    }
    else if ([url hasPrefix:@"https:"]){
         [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:placeholder] options:SDWebImageAllowInvalidSSLCertificates];
    }
    else {
        UIImage *image = [UIImage imageNamed:url] ?: [UIImage imageNamed:placeholder];
        imageView.image = image;
    }
}


- (void)showProgress{
    [self.circleProgressView removeFromSuperview];
    NSInteger p = ((SCREENWIDTH / 5) / 2) - (55 / 2) ;
    self.circleProgressView = [[DownloadCircleProgressView alloc] initWithFrame:CGRectMake(p, 8, 55, 55)];
    self.circleProgressView.circleProgressStyle = CircleProgressStyleDefault;
    [self addSubview:self.circleProgressView];
}

- (void)updateProgress:(CGFloat)progress{
    self.circleProgressView.circleProgressStyle = CircleProgressStyleDownloading;
    if(progress >= 1.0){
        self.circleProgressView.circleProgressStyle = CircleProgressStyleDownload;
    }
    
        self.circleProgressView.progressValue = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.circleProgressView setNeedsDisplay];
    });
    
}

@end
