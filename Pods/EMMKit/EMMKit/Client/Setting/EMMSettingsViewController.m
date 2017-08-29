//
//  EMMSettingsViewController.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/16.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "EMMSettingsViewController.h"
#import "EMMSettingCell.h"
#import "EMMSettingInfoCell.h"
#import "EMMPersonInfoViewController.h"
#import "EMMDataAccessor.h"
#import "EMMLoginViewController.h"
#import "EMMTabBarController.h"
#import "MBProgressHUD.h"
#import "EMMAnimation.h"
#import "EMMMediator.h"
#import "EMMFeedbackViewController.h"
#import "EMMDataAccessor.h"
#import "EMMApplicationContext.h"
#import "MBProgressHUD.h"
#import "EMMPersonInfo.h"
#import "UIAlertController+EMM.h"
#import "YYModel.h"
#import "UINavigationController+Extension.h"
#import "UIColor+HexString.h"
#import <Masonry.h>

@interface EMMSettingsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger loginType;//登录类型
}




@end

@implementation EMMSettingsViewController

static NSString * const kReuseIdentifierInfo = @"EMMSettingInfoCell";
static NSString * const kReuseIdentifierCommon = @"EMMSettingCell";

- (instancetype)initWithConfig:(id)config {
    
    if (self = [super init]) {
        if (config) {
            NSString *configFile = config[@"config_file"];
            if (configFile) {
                NSString *filePath = [[NSBundle mainBundle] pathForResource:configFile ofType:nil];
                _settingSections = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:nil];
                
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
    // 顶部长图
    UIView *Lview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    [self.view addSubview:Lview];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.image = [UIImage imageNamed:@"图层"];
    [Lview addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(Lview);
    }];
    
    // 头像
    UIImageView *headIconImageView = [[UIImageView alloc]init];
    headIconImageView.image = [UIImage imageNamed:@"新头像"];
    [Lview addSubview:headIconImageView];
    [headIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(Lview).offset(50);
        make.centerX.equalTo(Lview);
        make.width.height.offset(80);
    }];
    
    // label底部的view
    UIView *labelView = [[UIView alloc]init];
    //labelView.backgroundColor = [UIColor blackColor];
    labelView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:.8];
    
    labelView.layer.cornerRadius = 10;
    labelView.layer.masksToBounds = YES;
    [Lview addSubview:labelView];
    [labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headIconImageView.mas_bottom).offset(10);
        make.centerX.equalTo(Lview);
        make.width.offset(80);
        make.height.offset(30);
    }];
    
    // 姓名的label
    UILabel *label = [[UILabel alloc]init];
    label.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginUserName"];
//    [[NSUserDefaults standardUserDefaults] setObject:dict[@"USER_NAME"] forKey:@"LoginUserName"];;
    label.textColor = [UIColor whiteColor];
    self.label = label;
    label.textAlignment = NSTextAlignmentCenter;
    [labelView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(labelView);
        make.centerX.equalTo(labelView);
        //make.width.offset(100);
    }];
    CGFloat H = self.view.bounds.size.height - Lview.bounds.size.height - 49;
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, Lview.frame.size.height, self.view.bounds.size.width, H) style:UITableViewStyleGrouped];
    
    [self.view addSubview:tableView];
//    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view);
//        make.top.equalTo(Lview.mas_bottom);
//        make.bottom.equalTo(self.view).offset(0);
//    }];
    self.tableView = tableView;
    
    UIView *Mview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 60)];
    Mview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:Mview];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 20)];
    headView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:headView];
    
    
    UIButton *btn = [[UIButton alloc]init];
    btn.backgroundColor = [UIColor colorWithRed:10/255.0 green:88/255.0 blue:132/255.0 alpha:1.0];
    [btn setTitle:@"退出登录" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    [Mview addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(Mview);
        make.centerY.equalTo(Mview).offset(-10);
        make.width.offset(230);
        make.height.offset(40);
    }];
    btn.layer.cornerRadius = 10;
    btn.layer.masksToBounds = YES;
    
    self.tableView.tableHeaderView = headView;
    self.tableView.tableFooterView = Mview;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.tableFooterView = btn;
    self.title = @"";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:kReuseIdentifierInfo bundle:nil] forCellReuseIdentifier:kReuseIdentifierInfo];
    [self.tableView registerNib:[UINib nibWithNibName:kReuseIdentifierCommon bundle:nil] forCellReuseIdentifier:kReuseIdentifierCommon];
    
    [self.navigationController initNavBarBackBtnWithSystemStyle];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self getPersonInfo];
    [self.tableView reloadData];
}

- (void)getPersonInfo {
    
    if (self.personInfo) {
        return;
    }
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.offset = CGPointMake(0, -64.f);
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSDictionary *params = @{ @"username": username };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"getUserInfo"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.personInfo = [EMMPersonInfo yy_modelWithJSON:result[@"data"]];
        NSDictionary *dict = @{@"str":self.personInfo.name,@"identity":self.personInfo.department};
        //创建通知xx
        NSNotification *notification =[NSNotification notificationWithName:@"name" object:self userInfo:dict];
        //通过通知中心发送通知
//        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
//        NSDictionary *dict = @{@"str":@"",@"identity":@""};
        //创建通知xx
//        NSNotification *notification1 =[NSNotification notificationWithName:@"name1" object:self userInfo:dict];
        //通过通知中心发送通知
//        [[NSNotificationCenter defaultCenter] postNotification:notification1];
        
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return  15;
//}

//-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    
//    return 0.1;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    return indexPath.section == 0 ? 49 : 48;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIViewController *viewController;
    if (indexPath.section == 0) {
        // 个人详情
        if(self.personInfo){
            EMMPersonInfoViewController *vc = [[EMMPersonInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
            vc.personInfo = self.personInfo;
            viewController = vc;
        }
    }
    else if (indexPath.section == self.settingSections.count + 1) {
        // 退出登录
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self logout];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
        [cancelAction setValue:[UIColor emm_colorWithHexString:@"#666666"] forKey:@"titleTextColor"];
        [sheet addAction:sureAction];
        [sheet addAction:cancelAction];

        
        [sheet show];
        
        viewController = nil;
    }
    else {
        NSDictionary *setting = self.settingSections[indexPath.section - 1][indexPath.row];
        NSDictionary *segueInfo = setting[@"segue"];
        if (!segueInfo) {
            return;
        }
        viewController = [EMMMediator instanceWithClassName:segueInfo[@"class"]
                                                       type:segueInfo[@"type"]
                                                     config:segueInfo[@"configs"]];
        
    }
    
    if (viewController) {
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (loginType == 1) {
        return 1;
    }else
    {
    // 3组
    return self.settingSections.count + 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 匿名登录
    if (loginType == 1) {
        return 3;
    }else
    {
        return 2;
//        // 第二组 退出登录
//        if (section == _settingSections.count + 1){
//            return 2;
//        }
//        else {
//            // 第0组一个 第一组
//            //        return section == 0 ? 1 : [self.settingSections[section - 1] count];
//            return section == 0 ? 1 : 2;
//            
//        }

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        // 个人信息
        EMMSettingInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierInfo];
        NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
        if ([username isEqualToString:@""]) {
            username = self.personInfo.name;
        }
        infoCell.name = username;
        if (self.personInfo.avatar) {
            [infoCell setAvatarImage:[UIImage imageNamed:self.personInfo.avatar]];
        }
        else {
            [infoCell setAvatarImageWithURL:self.personInfo.imgurl];
        }
        return infoCell;
    }
    else if (indexPath.section == (_settingSections.count + 1)) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logout"];
//        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        cell.textLabel.text = @"退出登录";
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
    else {
        NSArray *settings = self.settingSections[indexPath.section - 1];
        NSDictionary *setting = settings[indexPath.row];
        
        EMMSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
        cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
        cell.cellLable.text = setting[@"title"];
        
        NSString *type = setting[@"type"];
        if (type) {
            if ([type isEqualToString:@"switch"]) {
                // type = "switch"
                NSString *switchKey = setting[@"switch_key"];
                UISwitch *theSwitch = [[UISwitch alloc] init];
                theSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:switchKey];
                theSwitch.tag = indexPath.section * 100 + indexPath.row;
                [theSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                theSwitch.onTintColor = [UIColor emm_colorWithHexString:@"#33afcc"];
                cell.accessoryView = theSwitch;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    
        return cell;
    }
}

-(void)logoutClick
{
            UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self logout];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    
            }];
    
            if([[UIDevice currentDevice] systemVersion].floatValue >9.0){
                [cancelAction setValue:[UIColor emm_colorWithHexString:@"#666666"] forKey:@"_titleTextColor"];
            }
    
    if([[UIDevice currentDevice] systemVersion].floatValue >9.0){
        [sureAction setValue:[UIColor emm_colorWithHexString:@"#1073BE"] forKey:@"_titleTextColor"];
    }
    
            [sheet addAction:sureAction];
    
            [sheet addAction:cancelAction];
            [sheet show];
}

- (void)switchAction:(UISwitch *)sender {
    
    NSInteger section = sender.tag / 100;
    NSInteger row = sender.tag % 100;
    NSArray *settings = self.settingSections[section - 1];
    NSDictionary *setting = settings[row];
    NSString *switchKey = setting[@"switch_key"];
    
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:switchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)logout {
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSString *password = [[EMMApplicationContext defaultContext] objectForKey:@"password"];
    NSDictionary *parameters = @{
                                 @"username": username,
                                 @"password": password
                                 };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"logout"];
    [dataAccessor sendRequestWithParams:parameters success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"LoginUserName"];
        [EMMMediator segueToLoginViewController];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}

@end
