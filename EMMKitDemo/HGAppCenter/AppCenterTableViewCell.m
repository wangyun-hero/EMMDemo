//
//  AppCenterTableViewCell.m
//  EMMKitDemo
//
//  Created by zm on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "AppCenterTableViewCell.h"
#import "AppCenterCollectionViewCell.h"
#import "HGAppModel.h"
#import "HGAppDao.h"
#import "HGCollectionViewHorizontalLayout.h"
#import "HGCollectionCellWhite.h"
#import "HGCollectionViewOneLineLayout.h"
#import "WYCollectionViewOneFlowLayout.h"
#define ReuseIdentifier @"AppCenterCollectionViewCell"
#import "PagingCollectionViewLayout.h"
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
static NSString *whiteCellID = @"whiteCellID";
@implementation AppCenterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UINib *nib = [UINib nibWithNibName:ReuseIdentifier bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:ReuseIdentifier];
    [self.collectionView registerClass:[HGCollectionCellWhite class] forCellWithReuseIdentifier:whiteCellID];
    
    
//    HGCollectionViewHorizontalLayout *layout =[[HGCollectionViewHorizontalLayout alloc]init];
    NSInteger width = (SCREENWIDTH / 5 ) ;
//    layout.itemSize = CGSizeMake(width,100);
//    
//    // cell间距
//    layout.minimumInteritemSpacing = 0;
//    // 行间距
//    layout.minimumLineSpacing = 0;
//    
//    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    PagingCollectionViewLayout *layout = [[PagingCollectionViewLayout alloc]init];
    layout.itemSize = CGSizeMake(width , 100);
//    layout.sectionInset = UIEdgeInsetsMake(5, 10, 5, 10);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectionView.collectionViewLayout = layout;
    
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = false;
    self.itemsArray = [NSMutableArray new];
    self.pageControl.backgroundColor = [UIColor whiteColor];
    // 当前的颜色
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.5 alpha:1];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.userInteractionEnabled = NO;
    
}

// 停止滑动-已经完成减速
- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView
{
    // 获取滑动的offset
    CGFloat offsetX = scrollView.contentOffset.x;
    // 计算页数
    NSInteger page = offsetX / scrollView.bounds.size.width;
    
    // 设置pageControl当前的页面
    self.pageControl.currentPage = page;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)parseAppsDic:(NSDictionary *)dic{
    
    [self.itemsArray removeAllObjects];
    self.sectionTitle.text = dic[@"appgroupname"];
    NSArray *array = [[HGAppDao sharedInstance] getApps:dic[@"appgroupcode"]];
    
    [self.itemsArray addObjectsFromArray:array];
    
    _pageCount = self.itemsArray.count;
//    if (self.itemsArray.count <= 5) {
//        _pageCount = 5;
//    }else if( (self.itemsArray.count <= 10) && (self.itemsArray.count > 5) )
//    {
//        _pageCount = 10;
//    }else if((self.itemsArray.count > 10) && (self.itemsArray.count % 10 >= 1 || self.itemsArray.count % 10 <= 9))
//    {
//        _pageCount = ((self.itemsArray.count / 10) + 1) * 10;
//        NSLog(@"sss");
//    }
    
//    [self layoutSet];
    // 计算cell的个数,包括白色的cell
    //    _pageCount = self.itemsArray.count;
    //    //一排显示四个,两排就是八个
    //    while (_pageCount % 10 != 0) {
    //        ++_pageCount;
    //        NSLog(@"%zd", _pageCount);
    //    }
    NSLog(@"%zd", _pageCount);
    
    // 计算pageControl的页数
    if (self.itemsArray.count <= 10) {
        self.pageControl.numberOfPages = 1;
        self.pageControl.hidden = YES;
    }else
    {
        if (@(self.itemsArray.count % 10) == nil) {
            self.pageControl.numberOfPages = self.itemsArray.count / 10 ;
        }else
        {
            self.pageControl.numberOfPages = (self.itemsArray.count / 10) + 1;
        }
    }
    
    [self.collectionView reloadData];
}

-(void)layoutSet
{
    if (self.itemsArray.count <= 5) {
        HGCollectionViewOneLineLayout *layout =[[HGCollectionViewOneLineLayout alloc]init];
        layout.rowCount = 1;
        
        NSInteger width = (SCREENWIDTH / 5 ) ;
        layout.itemSize = CGSizeMake(width,100);
        // cell间距
        layout.minimumInteritemSpacing = 0;
        // 行间距
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView.collectionViewLayout = layout;
//        [self.collectionView reloadData];
    }else
    {
        HGCollectionViewHorizontalLayout *layout =[[HGCollectionViewHorizontalLayout alloc]init];
        layout.rowCount = 2;
        NSInteger width = (SCREENWIDTH / 5 ) ;
        layout.itemSize = CGSizeMake(width,100);
        // cell间距
        layout.minimumInteritemSpacing = 0;
        // 行间距
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView.collectionViewLayout = layout;
//        [self.collectionView reloadData];
    }
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _pageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_pageCount <= 5)
    {
        if ((indexPath.row + 1) <= self.itemsArray.count) {
            AppCenterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
            if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(registerForPreviewingWithsourceView:)]){
                    [self.delegate registerForPreviewingWithsourceView:cell];
                }
            } else {
                //        NSLog(@"3D Touch 无效---添加长按");
                UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
                [cell addGestureRecognizer:longGestureRecognizer];
                
            }
            [cell setAppModel:self.itemsArray[indexPath.row]];
            return cell;
            
        }else
        {
            HGCollectionCellWhite *cell = [collectionView dequeueReusableCellWithReuseIdentifier:whiteCellID forIndexPath:indexPath];
            return cell;
        }
    }else
    {
        if (indexPath.item >= self.itemsArray.count) {
            HGCollectionCellWhite *cell = [collectionView dequeueReusableCellWithReuseIdentifier:whiteCellID forIndexPath:indexPath];
            return cell;
        }else
        {
            AppCenterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
            if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) && self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                if(self.delegate && [self.delegate respondsToSelector:@selector(registerForPreviewingWithsourceView:)]){
                    [self.delegate registerForPreviewingWithsourceView:cell];
                }
            } else {
                //        NSLog(@"3D Touch 无效---添加长按");
                UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
                [cell addGestureRecognizer:longGestureRecognizer];
                
            }
            [cell setAppModel:self.itemsArray[indexPath.row]];
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item >= self.itemsArray.count) {
        NSLog(@"点击了白色的cell");
    }else
    {
        if(self.delegate &&[self.delegate respondsToSelector:@selector(didSelectItemAtAppModel:withCell:)]){
            [self.delegate didSelectItemAtAppModel:self.itemsArray[indexPath.row] withCell:(AppCenterCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]];
            HGAppModel *model = self.itemsArray[indexPath.row];
            NSLog(@"ss");
        }
    }
    
    
}

////定义每个UICollectionViewCell 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(65, 100);
//}
//
////定义每个Section 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(5, 10, 5, 10);//分别为上、左、下、右
//}

- (void)longPressHandle:(UIGestureRecognizer *)longPress{
    AppCenterCollectionViewCell *cell = (AppCenterCollectionViewCell *)[longPress view];
    if(self.delegate && [self.delegate respondsToSelector:@selector(longPressAtCell:)]){
        [self.delegate longPressAtCell:cell];
    }
    [longPress removeTarget:self action:@selector(longPressHandle:)];
}






@end
