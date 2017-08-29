//
//  AppCenterDetailViewController.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "AppCenterDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "HGAppDao.h"
#import "EMMW3FolderManager.h"
#import "MBProgressHUD.h"
#import "HGAppCenterViewController.h"

@interface AppCenterDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *appIcon;
@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UIButton *installOrUninstallButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;

@property (nonatomic, strong) NSArray *actionsArray;
@property (weak, nonatomic) IBOutlet UILabel *introductionTitleLabel;

@end

@implementation AppCenterDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setImageWithUrl:self.appModel.iconurl andPlaceholder:@"HGApp_placeholder.png" toImageView:self.appIcon];
    self.appName.text = self.appModel.title;
    self.actionsArray = [NSArray new];
    
    self.installOrUninstallButton.layer.masksToBounds = YES;
    self.installOrUninstallButton.layer.cornerRadius = 5;
    self.installOrUninstallButton.layer.borderWidth = 1.0f;
    self.installOrUninstallButton.layer.borderColor = [UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1.0].CGColor;
    
    self.updateButton.layer.masksToBounds = YES;
    self.updateButton.layer.cornerRadius = 5;
    self.updateButton.layer.borderWidth = 1.0f;
    self.updateButton.layer.borderColor = [UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1.0].CGColor;
    [self refreshView];
    
    UILabel *introductionLabel = [[UILabel alloc] init];
//    self.appModel.introduction = @"其实，经年过往，每个人何尝不是在这场虚妄里跋涉？在真实的笑里哭着，在真实的哭里笑着，一笺烟雨，半帘幽梦，许多时候，我们不得不承认：生活，不是不寂寞，只是不想说。\n于无声处倾听凡尘落素，渐渐明白：人生，总会有许多无奈，希望、失望、憧憬、彷徨，苦过了，才知甜蜜；痛过了，才懂坚强；傻过了，才会成长。\n生命中，总有一些令人唏嘘的空白，有些人，让你牵挂，却不能相守；有些东西，让你羡慕，却不能拥有；有些错过，让你留恋，却终生遗憾。\n在这喧闹的凡尘，我们需要有适合自己的地方，用来安放灵魂。\n也许，是一座安静宅院；也许，是一本无字经书；也许，是一条迷津小路。只要是自己心之所往，便是驿站，为了将来起程时，不再那么迷惘。\n红尘三千丈，念在山水间。生活，不总是一帆风顺。因为爱，所以放手；因为放手，所以沉默；因为一份懂得，所以安心着一个回眸。\n也许，有风有雨的日子，才承载了生命的厚重；风轻云淡的日子，更适于静静领悟。";
    introductionLabel.text = self.appModel.introduction;
    NSInteger width = [UIScreen mainScreen].bounds.size.width - CGRectGetMinX(self.introductionTitleLabel.frame) * 2;
    CGRect r = [self.appModel.introduction boundingRectWithSize:CGSizeMake(width,0) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f]} context:nil];
    introductionLabel.frame = CGRectMake(CGRectGetMinX(self.introductionTitleLabel.frame), CGRectGetMaxY(self.introductionTitleLabel.frame) + 10, width, r.size.height);
    introductionLabel.numberOfLines = 0;
    introductionLabel.backgroundColor = [UIColor whiteColor];
    introductionLabel.textColor = [UIColor blackColor];
    introductionLabel.font = [UIFont systemFontOfSize:13.f];
    [self.view addSubview:introductionLabel];

}

- (void)refreshView{
    BOOL isNeedDownload =  [[HGAppDao sharedInstance] isNeedDownload:self.appModel.applicationId];
    NSString *localVersion = [[HGAppDao sharedInstance] getLocalVersion:self.appModel.applicationId];
    if([localVersion isEqualToString:@"0"]){
        [self.installOrUninstallButton setTitle:@"安装" forState:UIControlStateNormal];
        self.updateButton.hidden = YES;
        self.actionsArray = @[@"安装"];
    }
    else if(isNeedDownload){
        [self.installOrUninstallButton setTitle:@"卸载" forState:UIControlStateNormal];
        self.updateButton.hidden = NO;
        self.actionsArray = @[@"更新",@"卸载"];
    }
    else{
        [self.installOrUninstallButton setTitle:@"卸载" forState:UIControlStateNormal];
        self.updateButton.hidden = YES;
        self.actionsArray = @[@"卸载"];
    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setImageWithUrl:(NSString *)url andPlaceholder:(NSString *)placeholder toImageView:(UIImageView *)imageView {
    
    if ([url hasPrefix:@"http:"]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:placeholder]];
    }
    else if ([url hasPrefix:@"https:"]){
        [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:placeholder] options:SDWebImageAllowInvalidSSLCertificates];
    }
    else {
        UIImage *image = [UIImage imageNamed:url] ?: [UIImage imageNamed:placeholder];
        imageView.image = image;
    }
}

- (IBAction)clickedInstallOrUnInstall:(id)sender {
    BOOL isNeedDownload =  [[HGAppDao sharedInstance] isNeedDownload:self.appModel.applicationId];
    if(isNeedDownload){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"updateCell"];
            [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        username = username.length ? username:@"guest";
        BOOL isSuccess = [[EMMW3FolderManager sharedInstance] removeW3Folder:[NSString stringWithFormat:@"%@-%@",username,self.appModel.applicationId]];
        if(isSuccess){
            [[HGAppDao sharedInstance] updatewww_localVersion:@"0" appId:self.appModel.applicationId];
            [self refreshView];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = @"应用已经卸载";
            hud.mode = MBProgressHUDModeCustomView;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // 1秒之后再消失
            [hud hideAnimated:YES afterDelay:0.7f];
            [self performSelector:@selector(backToAppCenter) withObject:nil afterDelay:1.5f];
        }
    }
}

-(void)backToAppCenter{
    [self.navigationController popViewControllerAnimated:YES];
}




@end
