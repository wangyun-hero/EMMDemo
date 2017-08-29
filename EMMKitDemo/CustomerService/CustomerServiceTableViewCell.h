//
//  CustomerServiceTableViewCell.h
//  EMMKitDemo
//
//  Created by 王云 on 2017/7/5.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerServiceTableViewCell : UITableViewCell
@property(nonatomic,strong) NSArray *dataArray;
@property(nonatomic,strong) NSMutableArray *onlineHelpArray;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property(nonatomic,copy) NSString *indexStr;
@property(nonatomic,copy) void(^myBlock)(NSString *str);
@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;
@end
