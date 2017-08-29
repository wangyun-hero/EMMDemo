//
//  CustomerServiceCollectionViewCell.m
//  EMMKitDemo
//
//  Created by zm on 16/9/22.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "CustomerServiceCollectionViewCell.h"

@implementation CustomerServiceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [[UIColor colorWithRed:229/255.0 green:229/255.0 blue:229/255.0 alpha:1.0] CGColor];
}

- (void)setCustomerServiceModel:(CustomerServiceModel *)model{
    self.titleLabel.text = model.title;
    [self.imageView setImage:[UIImage imageNamed:model.image]];
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.layer.cornerRadius = 13;
}

@end
