//
//  AppCenterTableViewCell.h
//  EMMKitDemo
//
//  Created by zm on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGAppModel.h"
#import "AppCenterCollectionViewCell.h"

@class AppCenterTableViewCell;
@protocol AppCenterTableViewCellDelegate <NSObject>

- (void)didSelectItemAtAppModel:(HGAppModel *)appModel withCell:(AppCenterCollectionViewCell *)cell;

- (void)registerForPreviewingWithsourceView:(AppCenterCollectionViewCell *)cell;

- (void)longPressAtCell:(AppCenterCollectionViewCell *)cell;

@end

@interface AppCenterTableViewCell : UITableViewCell<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *sectionTitle;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property(nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, strong) NSMutableArray *itemsArray;
@property (nonatomic, weak) id<AppCenterTableViewCellDelegate> delegate;
@property(nonatomic,strong) UICollectionViewFlowLayout *flowLayout;

- (void)parseAppsDic:(NSDictionary *)dic;

@end
