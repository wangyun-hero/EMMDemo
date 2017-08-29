//
//  CustomerServiceTableViewCell.m
//  EMMKitDemo
//
//  Created by 王云 on 2017/7/5.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "CustomerServiceTableViewCell.h"
#import "CustomerServiceCollectionViewCell.h"
#import "OnlineHelpViewController.h"
static NSString *collectionViewCellID = @"collectionViewCellID";
@interface CustomerServiceTableViewCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UIView *backView;



@end
@implementation CustomerServiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    [self.mainCollectionView registerNib:[UINib nibWithNibName:@"CustomerServiceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:collectionViewCellID];
    
    self.mainCollectionView.delegate = self;
    self.mainCollectionView.dataSource = self;
}

-(void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray.count < 1) {
        return 0;
    }else
    {
        return self.dataArray.count;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomerServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:
                                               collectionViewCellID forIndexPath:indexPath];
    
    cell.layer.borderColor = [UIColor clearColor].CGColor;
    CustomerServiceModel *model = self.dataArray[indexPath.row];
    
    [cell setCustomerServiceModel:model];
    return cell;
}

#pragma mark - UICollectionViewDataSource
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.currentModel == hotlineTelModel?self.hotlineTelArray.count:self.onlineHelpArray.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    CustomerServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
//    CustomerServiceModel *model;
//    if(self.currentModel == hotlineTelModel){
//        model = self.hotlineTelArray[indexPath.row];
//    }
//    else if(self.currentModel == onlineHelpModel){
//        model = self.onlineHelpArray[indexPath.row];
//    }
//    [cell setCustomerServiceModel:model];
//    return cell;
//}
//
//#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if(self.currentModel == hotlineTelModel){
//        CustomerServiceModel *model = self.hotlineTelArray[indexPath.row];
//        NSString *phoneNum = [[NSString alloc] initWithFormat:@"telprompt://%@",model.phoneNumber];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
//    }
//    else{
//        CustomerServiceModel *model = self.onlineHelpArray[indexPath.row];
//        OnlineHelpViewController *onlineHelp = [[OnlineHelpViewController alloc] init];
//        onlineHelp.modelKey = model.key;
//        [onlineHelp setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:onlineHelp animated:YES];
//    }
//}
//
//#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger widthW = self.backView.frame.size.width/3 ;
    return CGSizeMake(widthW, widthW);
}

//定义每个Section 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
//}

- (CGFloat) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat) collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了我");
    if ([self.indexStr isEqualToString:@"1"]) {
        CustomerServiceModel *model = self.dataArray[indexPath.row];
        NSString *phoneNum = [[NSString alloc]initWithFormat:@"telprompt://%@",model.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
    }else
    {
        CustomerServiceModel *model = self.dataArray[indexPath.row];
        NSString *blockStr = model.key;
        if (self.myBlock) {
            self.myBlock(blockStr);
        }
    }
    
}

@end
