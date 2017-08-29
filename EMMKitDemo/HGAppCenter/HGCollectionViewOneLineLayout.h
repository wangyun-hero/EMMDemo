//
//  HGCollectionViewOneLineLayout.h
//  EMMKitDemo
//
//  Created by 王云 on 2017/7/13.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGCollectionViewOneLineLayout : UICollectionViewFlowLayout
// 一行中 cell的个数
@property (nonatomic) NSUInteger itemCountPerRow;
// 一页显示多少行
@property (nonatomic) NSUInteger rowCount;
@property (strong, nonatomic) NSMutableArray *allAttributes;
@end
