//
//  DownloadCircleProgressView.h
//  EMMKitDemo
//
//  Created by zm on 16/9/23.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CircleProgeressStyle) {
    CircleProgressStyleDefault = 0,
    CircleProgressStyleDownloading, //下载中
    CircleProgressStyleDownload, // 下载完成
};

@interface DownloadCircleProgressView : UIView

@property (nonatomic) CGFloat progressValue;
@property (nonatomic) CircleProgeressStyle circleProgressStyle;

@end
