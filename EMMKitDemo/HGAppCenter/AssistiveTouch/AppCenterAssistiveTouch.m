//
//  AppCenterAssistiveTouch.m
//  EMMPortalDemo
//
//  Created by zm on 16/7/11.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "AppCenterAssistiveTouch.h"
#import "AppCenterAssistiveTouchItem.h"
#import "ViewControllersMemoryHandle.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define backItemTag 5555

static const CGFloat itemOffsetX = 2;
static const CGFloat itemOffsetY = 2;

@interface AppCenterAssistiveTouch(){
    UIView *contentView;
    BOOL isSpread; //展开
    CGFloat itemCount;
    CGPoint lastPoint;
    CGFloat systemItemWidth;
    
    CGFloat spreadWidth;
    CGFloat spreadHeight;
    CGFloat customerItemWidth;
    CGFloat customerItemHeight;
    CGFloat leftMargin;
    CGFloat topMargin;
    CGFloat backItemWidth;
    
    UIPanGestureRecognizer *pan;
}

@end

@implementation AppCenterAssistiveTouch

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.windowLevel = UIWindowLevelAlert;
        [self makeKeyAndVisible];
        
        spreadWidth = kScreenWidth/375 *3*100;
        spreadHeight = spreadWidth;
        customerItemWidth = kScreenWidth/375 *60;
        customerItemHeight = kScreenWidth/375 *95;
        leftMargin = kScreenWidth/375 *20;
        topMargin = kScreenWidth/375 *15;
        backItemWidth = kScreenWidth/375 *80;
       
        isSpread = NO;
        lastPoint = frame.origin;
        systemItemWidth = frame.size.width;
         [self loadView];
        
        pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        pan.delaysTouchesBegan = YES;
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)loadView{
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, systemItemWidth, systemItemWidth)];
    contentView.layer.cornerRadius = 30;
    [self addSubview:contentView];
    
    AppCenterAssistiveTouchItem *assistiveTouchItem = [[AppCenterAssistiveTouchItem alloc] initWithFrame:CGRectMake(0, 0, systemItemWidth, systemItemWidth) type:EMMItemViewTypeSystem];
    [contentView addSubview:assistiveTouchItem];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandel:)];
    [contentView addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tapHandel:) name:@"shinkAssistiveTouch" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteItem:) name:@"deleteItem" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWin:) name:@"closeWin" object:nil];
    
}


//改变位置
-(void)locationChange:(UIPanGestureRecognizer*)p
{
    if(p.state == UIGestureRecognizerStateBegan)
    {
        //        assistiveTouchImageView.alpha = 0.8;
    }
    if(p.state == UIGestureRecognizerStateChanged)
    {
        //        assistiveTouchImageView.alpha = 0.8;
        CGPoint translation = [p translationInView:self];
        CGAffineTransform theTransform = self.transform;
        theTransform.tx = translation.x;
        theTransform.ty = translation.y;
        
        self.transform = theTransform;
    }
    else if(p.state == UIGestureRecognizerStateEnded)
    {
        //        assistiveTouchImageView.alpha = 1.0;
        CGPoint newCenter = CGPointMake(self.center.x + self.transform.tx, self.center.y + self.transform.ty);
        CGFloat newX  = newCenter.x;
        CGFloat newY = newCenter.y;
        
        self.center = newCenter;
        
        if(newY<=systemItemWidth/2 ){
            newY = systemItemWidth/2 + itemOffsetY;
        }
        else if(newY >= kScreenHeight-systemItemWidth/2){
            newY = kScreenHeight - systemItemWidth/2 - itemOffsetY;
        }
        
        //在右边
        if(newX >= kScreenWidth/2){
            
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(kScreenWidth - systemItemWidth/2 - itemOffsetX, newY);
            }];
            
            
        }
        else{ //在左边
            [UIView animateWithDuration:0.2 animations:^{
                self.center = CGPointMake(systemItemWidth/2 + itemOffsetX, newY);
            }];
            
        }
        
        lastPoint = CGPointMake(self.center.x - systemItemWidth/2, self.center.y - systemItemWidth/2 );
        
        CGAffineTransform theTransform = self.transform;
        theTransform.tx = 0.0f;
        theTransform.ty = 0.0f;
        self.transform = theTransform;
        
        return;
        
    }
}

- (void)tapHandel:(UITapGestureRecognizer *)tap{
    if(isSpread){
        // 收起
        isSpread = NO;
        [self shrink];
    }
    else{
        // 展开
        isSpread = YES;
        [self spread];
    }
    
}

- (void)spread{
    
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat width = spreadWidth;
        CGFloat height = spreadHeight;
        CGRect screen = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake((CGRectGetWidth(screen) - spreadWidth) / 2,
                                (CGRectGetHeight(screen) - height) / 2,
                                width, height);
        contentView.frame = self.bounds;
        contentView.alpha = 1;
        contentView.backgroundColor = [UIColor grayColor];
        
        NSArray *array = [contentView subviews];
        for(UIView *view in array){
            if([view isKindOfClass:[AppCenterAssistiveTouchItem class]]){
                [view removeFromSuperview];
            }
        }
        
    } completion:^(BOOL finished) {
        [self removeGestureRecognizer:pan];
        
        [self reloadItems];
    }];
    
}

- (void)shrink{
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(lastPoint.x, lastPoint.y, systemItemWidth, systemItemWidth);
        
        contentView.frame = self.bounds;
        contentView.alpha = 1;
        contentView.backgroundColor = [UIColor clearColor];
        
        NSArray *array = [contentView subviews];
        for(UIView *view in array){
            if([view isKindOfClass:[AppCenterAssistiveTouchItem class]]){
                [view removeFromSuperview];
            }
        }

    } completion:^(BOOL finished) {
        AppCenterAssistiveTouchItem *item = [[AppCenterAssistiveTouchItem alloc] initWithFrame:CGRectMake(0, 0, systemItemWidth, systemItemWidth) type:EMMItemViewTypeSystem];
        
        [contentView addSubview:item];
        
        [self addGestureRecognizer:pan];
        
        [self measureHidden];
    }];
    
}

- (void)selectedItem:(UITapGestureRecognizer *)tap{
    
    AppCenterAssistiveTouchItem *item =  (AppCenterAssistiveTouchItem *)[tap view];
    NSLog(@"点击item%ld",(long)item.itemTag);
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedAssistiveTouchItem:)]){
        [self.delegate selectedAssistiveTouchItem:item.itemTag];
    }
    
    [self shrink];
    isSpread = NO;
}

- (void)reloadItems{
    
    NSArray *array = [contentView subviews];
    for(UIView *view in array){
        if([view isKindOfClass:[AppCenterAssistiveTouchItem class]]){
            [view removeFromSuperview];
        }
    }

    NSMutableArray *tempArray = [NSMutableArray new];
    [tempArray addObjectsFromArray:_assistiveTouchItemArray];
    if(tempArray.count>4){
        [tempArray insertObject:@"back" atIndex:4];
    }
    else{
        [tempArray addObject:@"back"];
    }
    
    for(int i = 0; i < tempArray.count;i++){
        id model = tempArray[i];
        if([model isKindOfClass:[AssistiveTouchItemModel class]]){
            int col = i/3; //列
            int row = i%3; // 行
            
            AssistiveTouchItemModel *model = tempArray[i];
            AppCenterAssistiveTouchItem *item;
            if([model.key isEqualToString:self.currentKey]){
                item = [[AppCenterAssistiveTouchItem alloc] initWithFrame:CGRectMake( leftMargin+ spreadWidth/3*row,topMargin+spreadHeight/3*col, customerItemWidth, customerItemHeight) itemModel:model  type:EMMItemViewTypeOpeningCustomer ];
            }else{
                item = [[AppCenterAssistiveTouchItem alloc] initWithFrame:CGRectMake( leftMargin+ spreadWidth/3*row,topMargin+spreadHeight/3*col, customerItemWidth, customerItemHeight) itemModel:model  type:EMMItemViewTypeCustomer ];
            }
            
            item.itemTag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedItem:)];
            [item addGestureRecognizer:tap];
            
            [contentView addSubview:item];
        }
        else{
            AppCenterAssistiveTouchItem *backItem = [[AppCenterAssistiveTouchItem alloc] initWithFrame:CGRectMake((spreadWidth-backItemWidth)/2,(spreadHeight-backItemWidth)/2, backItemWidth, backItemWidth) type:EMMItemViewTypeBack];
            backItem.itemTag = backItemTag;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedItem:)];
            [backItem addGestureRecognizer:tap];
            
            [contentView addSubview:backItem];
        }
    }
}

- (void)deleteItem:(NSNotification *)notif{
    
    NSDictionary *dic = [notif userInfo];
    NSString *appKey = dic[@"appKey"];
    NSString *animated = dic[@"closeAnimated"];
    [[ViewControllersMemoryHandle sharedInstance] removeViewControllesr:appKey];
    for(AssistiveTouchItemModel *model in self.assistiveTouchItemArray){
        if([model.key isEqualToString:appKey]){
            [self.assistiveTouchItemArray removeObject:model];
            break;
        }
    }
    
    if([animated isEqualToString:@"reload"]){
        [self reloadItems];
    }
    
}

- (void)measureHidden{
    if(self.assistiveTouchItemArray.count == 0){
        self.hidden = YES;
    }
    else{
        self.hidden = NO;
    }
}

- (void)closeWin:(NSNotification *)noti{
    
    if(self.currentKey){
        NSDictionary *dic = @{@"appKey":self.currentKey};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:self userInfo:dic];
        [self shrink];
    }
}



@end
