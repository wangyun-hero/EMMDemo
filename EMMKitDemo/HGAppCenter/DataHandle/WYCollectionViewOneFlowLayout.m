//
//  WYCollectionViewOneFlowLayout.m
//  EMMKitDemo
//
//  Created by 王云 on 2017/8/9.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "WYCollectionViewOneFlowLayout.h"

@implementation WYCollectionViewOneFlowLayout
- (void)prepareLayout
{
    // 一定要去调用父类方法
    [super prepareLayout];
    
    CGFloat w =  [UIScreen mainScreen].bounds.size.width / 5 ;
    //    CGFloat h = self.collectionView.bounds.size.height / 2;
    self.itemSize = CGSizeMake(w, 100); // cell大小
    self.minimumLineSpacing = 0; // 行间距
    self.minimumInteritemSpacing = 0; // cell间距
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal; // 设置水平滑动
}

@end
