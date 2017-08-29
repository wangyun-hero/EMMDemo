//
//  HGCollectionViewHorizontalLayout.h
//  EMMKitDemo
//
//  Created by 王云 on 2017/7/12.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGCollectionViewHorizontalLayout : UICollectionViewFlowLayout
// 一行中 cell的个数
@property (nonatomic) NSUInteger itemCountPerRow;
// 一页显示多少行
@property (nonatomic) NSUInteger rowCount;
@property (strong, nonatomic) NSMutableArray *allAttributes;
//-(void)getRowNum:(NSInteger)num;
@end
