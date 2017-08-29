//
//  introductoryPagesHelper.m
//  MobileProject
//
//  Created by wujunyang on 16/7/14.
//  Copyright © 2016年 wujunyang. All rights reserved.
//

#import "introductoryPagesHelper.h"
#import "EAIntroView.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height
@interface introductoryPagesHelper()<EAIntroDelegate>

@property (nonatomic) UIWindow *rootWindow;

@property(nonatomic,strong)introductoryPagesView *curIntroductoryPagesView;

@end

@implementation introductoryPagesHelper

+ (instancetype)shareInstance
{
    
    static introductoryPagesHelper *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[introductoryPagesHelper alloc] init];
    });
    
    return shareInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


+ (void)showIntroductoryPageCustomView:(NSArray *)imageArray
{
    if (![introductoryPagesHelper shareInstance].curIntroductoryPagesView) {
        [introductoryPagesHelper shareInstance].curIntroductoryPagesView=[[introductoryPagesView alloc]initPagesViewWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) Images:imageArray];
    }
    
    [introductoryPagesHelper shareInstance].rootWindow = [UIApplication sharedApplication].keyWindow;
    [[introductoryPagesHelper shareInstance].rootWindow addSubview:[introductoryPagesHelper shareInstance].curIntroductoryPagesView];
}

+ (void)showIntroductoryPageEAIntroViewView:(NSArray *)imageArray{

    NSMutableArray * pagesArray = [NSMutableArray array];
    
    [imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        EAIntroPage *page = [EAIntroPage page];
        page.title = @""; // 标题
        page.desc = @"";// 内容
        page.bgImage = [UIImage imageNamed:[imageArray objectAtIndex:idx]];
        page.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
        [pagesArray addObject:page];
    }];

    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds andPages:pagesArray];
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    intro.skipButtonY = 80.f;
    intro.pageControlY = 42.f;
    intro.delegate = [introductoryPagesHelper shareInstance];
    [intro showInView:[UIApplication sharedApplication].keyWindow animateDuration:0.3];
}

@end
