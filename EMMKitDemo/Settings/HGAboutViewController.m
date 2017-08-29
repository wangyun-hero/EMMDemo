//
//  HGAboutViewController.m
//  EMMKitDemo
//
//  Created by zm on 16/8/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGAboutViewController.h"
#import <EMMTabBarController.h>
#import "UINavigationBar+UINavigationBar_other.h"
@interface HGAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *poweredby;
@property (weak, nonatomic) IBOutlet UILabel *iuapmobile;

@end

@implementation HGAboutViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar getnavBarColor:[UIColor clearColor]];

    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //设置navbar的透明,一起用
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
//    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
//    tabVC.label.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger p = 23 % 10;
    NSInteger m = 20 % 10;
    
    self.bottomView.alpha = 0.6;
    self.bottomView.layer.cornerRadius = 20;
    self.bottomView.layer.masksToBounds = YES;
    // 加粗
//    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    self.titleLabel.font = [UIFont fontWithName:@"HYk2gj" size:20];
    self.infoView.hidden = YES;
    
    
    NSInteger width = [UIScreen mainScreen].bounds.size.width;
//    NSInteger height = [UIScreen mainScreen].bounds.size.height;
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于门户";
    // app版本
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *app_name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    self.name.text = [NSString stringWithFormat:@"%@数据中心",app_name];
    self.version.text = [NSString stringWithFormat:@"版本 %@",app_Version];
    self.poweredby.hidden = YES;
    self.iuapmobile.hidden = YES;
    UIView *longtapView = [[UIView alloc] initWithFrame:CGRectMake((width-40)*0.5, 0, 40, 40)];
    longtapView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:longtapView];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(showLabel:)];
    [longtapView addGestureRecognizer:longPress];
}

-(void)showLabel:(UILongPressGestureRecognizer *)action{
    if (action.state == UIGestureRecognizerStateEnded) {
        self.poweredby.hidden = YES;
        self.iuapmobile.hidden = YES;
    }else{
        self.poweredby.hidden = NO;
        self.iuapmobile.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
