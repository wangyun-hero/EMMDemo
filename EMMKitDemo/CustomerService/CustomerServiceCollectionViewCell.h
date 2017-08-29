//
//  CustomerServiceCollectionViewCell.h
//  EMMKitDemo
//
//  Created by zm on 16/9/22.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerServiceModel.h"

@interface CustomerServiceCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setCustomerServiceModel:(CustomerServiceModel *)model;

@end
