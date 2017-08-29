//
//  SettingsViewController.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SettingsViewController.h"
#import "MBProgressHUD.h"
#import "EMMDataAccessor.h"
#import "EMMAnimation.h"
#import "EMMMediator.h"
#import "PersonInfoViewController.h"
#import "EMMSettingCell.h"
#import "EMMSettingInfoCell.h"
#import "HGLoginViewController.h"
#import "EMMApplicationContext.h"
#import "UIColor+HexString.h"
#import "UIAlertController+Window.h"
#import "UIAlertController+EMM.h"
#import "HGBandCardViewController.h"
#import <EMMTabBarController.h>
#import <Masonry.h>
#import "HGAboutViewController.h"
#import <EMMFeedbackViewController.h>
#import "ModifyPasswordViewController.h"
#import <EMMPersonInfo.h>
#import "UINavigationBar+UINavigationBar_other.h"
#import "HGAuthIntroduceController.h"
#import "GVUserDefaults+Properties.h"
static NSString * const kReuseIdentifierInfo = @"EMMSettingInfoCell";
static NSString * const kReuseIdentifierCommon = @"EMMSettingCell";

@interface SettingsViewController (){
    NSInteger loginType;//登录类型
}

@property(nonatomic,strong) NSMutableArray *arrayTemp;

@end

@implementation SettingsViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"name" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failReceive:) name:@"name1" object:nil];
//    self.label.text = self.personInfo.name;
    if (self.navigationController.navigationBar.hidden == false) {
        self.navigationController.navigationBar.hidden = YES;
    }
    NSLog(@"弹框提示超时");
    if ([self isTwoHours] == true) {
        [self logoutAction];
        return;
    }

    // 测试版本更新
//    WYUserDefault.version = @"1.22223";
    
//    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
//    tabVC.label.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController.navigationBar setHidden:false];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self logoutAction];
    
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
    //设置navbar的透明,一起用
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
   // [self.navigationController.navigationBar setHidden:YES];
    
    self.title = @"我";
    
    self.label.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginUserName"];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
    loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
    // 匿名登录
    if(loginType == HGLoginType_Anonymity){
        self.label.text = @"游客";
        [self setAnonymityLogin];
    }
    
    if(loginType == HGLoginType_Bluetooth){
        [self setBluetoothLogin];
    }
    
    
}

-(void)receive:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    NSLog(@"%@----%@------%@-----%@",noti,noti.object,noti.name,noti.userInfo);
    self.identity = dict[@"identity"];
    if ([dict[@"str"] isEqualToString:@"guest"]) {
        self.label.text = @"游客";
    }else
    {
        self.label.text = dict[@"str"];
    }
    self.label.alpha = 0.7;
}


-(void)failReceive:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    NSLog(@"%@----%@------%@-----%@",noti,noti.object,noti.name,noti.userInfo);
    self.label.text = WYUserDefault.USER_NAME;
//    self.identity = dict[@"identity"];
//    if ([dict[@"str"] isEqualToString:@"guest"]) {
//        self.label.text = @"游客";
//    }else
//    {
//        self.label.text = dict[@"str"];
//    }
//    self.label.alpha = 0.7;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAnonymityLogin{
    NSMutableArray *arrayTemp = [NSMutableArray new];
    for(NSDictionary *dic in self.settingSections[0]){
        NSString *title = dic[@"title"];
        if([title isEqualToString:@"问题反馈"] || [title isEqualToString:@"修改密码"] || [title isEqualToString:@"个人信息"]){
        }
        else{
            [arrayTemp addObject:dic];
        }
    }
    self.arrayTemp = arrayTemp;
//    self.settingSections = [NSArray arrayWithObject:[NSArray arrayWithArray:arrayTemp]];
    
}

- (void)setBluetoothLogin{
    NSMutableArray *arrayTemp = [NSMutableArray new];
    for(NSDictionary *dic in self.settingSections[0]){
        NSString *title = dic[@"title"];
        if([title isEqualToString:@"修改密码"] || [title isEqualToString:@"绑定蓝牙KEY"]){
        }
        else{
            [arrayTemp addObject:dic];
        }
    }
    self.settingSections = [NSArray arrayWithObject:[NSArray arrayWithArray:arrayTemp]];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 匿名登录
    if (loginType == 1) {
        if (indexPath.row == 0) {
            NSDictionary *setting = self.arrayTemp[0];
            EMMSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
            cell.cellLable.text = setting[@"title"];
            cell.cellLable.font = [UIFont fontWithName:@"FZLTHK--GBK1-0" size:15];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UISwitch *switchBtn = [[UISwitch alloc] init];
            BOOL closeAssistiveTouch = [[NSUserDefaults standardUserDefaults] boolForKey:@"closeAssistiveTouch"];
            switchBtn.on = !closeAssistiveTouch;
            switchBtn.tag = 0;
            switchBtn.onTintColor = [UIColor emm_colorWithHexString:@"#53D769"];
            [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView =switchBtn;
            return cell;
        }else if(indexPath.row == 1)
        {
            NSDictionary *setting = self.arrayTemp[1];
            EMMSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
            cell.cellLable.text = setting[@"title"];
            return cell;
 
        }else
        {
            NSDictionary *setting = self.arrayTemp[2];
            EMMSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
            cell.cellLable.text = setting[@"title"];
            return cell;

        }
    }else
    {
        // 普通登录
        if (indexPath.section == 0) {
            // 原来注释
            //        EMMSettingInfoCell *infoCell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierInfo];
            //        if(loginType == HGLoginType_Anonymity){
            //            infoCell.name = @"匿名用户";
            //            [infoCell setAccessoryType:UITableViewCellAccessoryNone];
            //            [infoCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            //        }
            //        infoCell.name = [self.personInfo name];
            //        if (self.personInfo.avatarImage) {
            //            [infoCell setAvatarImage:self.personInfo.avatarImage];
            //        }
            //        else {
            //            [infoCell setAvatarImageWithURL:self.personInfo.imgurl];
            //        }
            
            // 取到数组
            NSArray *settings = self.settingSections[0];
            NSDictionary *setting;
            if (indexPath.row == 0) {
                setting = settings[0];
            }else
            {
                setting = settings[1];
            }
            EMMSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
            cell.cellLable.text = setting[@"title"];
            //        UITableViewCell *infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"info"];
            //        infoCell.textLabel.text = [self.personInfo name];
            return cell;
        }else if (indexPath.section == (self.settingSections.count+1)){
            // 第二组 退出登录
            //        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logout"];
            //        cell.textLabel.text = @"退出登录";
            //        [cell.textLabel setTextColor:[UIColor emm_colorWithHexString:@"#ff1b1a"]];
            //        cell.textLabel.textAlignment = NSTextAlignmentCenter;
            //        return cell;
            
            
            // 第二组
            // 取到数组
            NSArray *settings = self.settingSections[0];
            EMMSettingCell *cell;
            if (indexPath.row == 0) {
                NSDictionary *setting = settings[4];
                cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
                cell.cellLable.text = setting[@"title"];
                
            }else if(indexPath.row == 1)
            {
                NSDictionary *setting = settings[5];
                
                cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
                cell.cellLable.text = setting[@"title"];
            }
            
            
            return cell;
        }
        else {
            // 第一组
            // 取到数组
            NSArray *settings = self.settingSections[indexPath.section - 1];
            
            EMMSettingCell *cell;
            if (indexPath.row == 0) {
                NSDictionary *setting = settings[2];
                cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
                cell.cellLable.text = setting[@"title"];
            }else
            {
                NSDictionary *setting = settings[3];
                cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
                cell.cellLable.text = setting[@"title"];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                UISwitch *switchBtn = [[UISwitch alloc] init];
                BOOL closeAssistiveTouch = [[NSUserDefaults standardUserDefaults] boolForKey:@"closeAssistiveTouch"];
                switchBtn.on = !closeAssistiveTouch;
                switchBtn.tag = 0;
                switchBtn.onTintColor = [UIColor emm_colorWithHexString:@"#53D769"];
                [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView =switchBtn;
            }
            //        EMMSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifierCommon];
            //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
            //        cell.cellImage.image = [UIImage imageNamed:setting[@"icon"]];
            //        cell.cellLable.text = setting[@"title"];
            //        NSString *userType = [[NSUserDefaults standardUserDefaults] objectForKey:@"userType"];
            //        if ([userType isEqualToString:@"1"]) {
            //            if ([cell.cellLable.text isEqualToString:@"绑定蓝牙KEY"]) {
            //                cell.cellLable.text = @"解除绑定蓝牙KEY";
            //            }
            //        }
            //        if([cell.cellLable.text isEqualToString:@"打开多任务"]){
            //            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            //            UISwitch *switchBtn = [[UISwitch alloc] init];
            //            BOOL closeAssistiveTouch = [[NSUserDefaults standardUserDefaults] boolForKey:@"closeAssistiveTouch"];
            //            switchBtn.on = !closeAssistiveTouch;
            //            switchBtn.tag = 0;
            //            switchBtn.onTintColor = [UIColor emm_colorWithHexString:@"#5ec1f7"];
            //            [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            //            cell.accessoryView =switchBtn;
            //        }
            
            return cell;
        }
 
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }else
    {
       return  5; 
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (loginType == 1)
    {
        // 匿名登录
        if (indexPath.row == 1) {
            
            HGAuthIntroduceController *vc = [[HGAuthIntroduceController alloc]init];
            vc.labelString = self.label.text;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 2)
        {
            HGAboutViewController *vc = [[HGAboutViewController alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else
    {
        if ([self isTwoHours] == true) {
            [self logoutAction];
        }else
        {
            // 普通登录
            UIViewController *viewController;
            // 第0组
            if (indexPath.section == 0)
            {
                if (indexPath.row == 0)
                {
                    // 个人详情
                    if(loginType != HGLoginType_Anonymity)
                    {
                        PersonInfoViewController *personInfoViewController  = [[PersonInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
                        personInfoViewController .personInfo = self.personInfo;
                        personInfoViewController.hidesBottomBarWhenPushed = YES;
                        [self.navigationController pushViewController:personInfoViewController animated:YES];
                    }
                    
                }else
                {
                    ModifyPasswordViewController *vc = [[ModifyPasswordViewController alloc]init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            else if (indexPath.section == self.settingSections.count + 1)
            {
                // 第2组
                if (indexPath.row == 0)
                {
                    HGAuthIntroduceController *vc = [[HGAuthIntroduceController alloc]init];
                    vc.identityName = self.identity;
                    viewController = nil;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }else
                {
                    HGAboutViewController *vc = [[HGAboutViewController alloc]init];
                    viewController = nil;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            else
            {
                // 第1组
                //            EMMSettingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                //            if ([cell.cellLable.text isEqualToString:@"解除绑定蓝牙KEY"]) {
                //                [self cancelBandICCard];
                //                return;
                //            }
                if (indexPath.row == 0) {
                    EMMFeedbackViewController *vc = [[EMMFeedbackViewController alloc]init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                //            NSDictionary *setting = self.settingSections[indexPath.section + 1][indexPath.row];
                //            NSDictionary *segueInfo = setting[@"segue"];
                //            if (!segueInfo) {
                //                return;
                //            }
                //            viewController = [EMMMediator instanceWithClassName:segueInfo[@"class"]
                //                                                           type:segueInfo[@"type"]
                //                                                         config:segueInfo[@"configs"]];
                
            }
            if (viewController) {
                if ([viewController isKindOfClass:[HGBandCardViewController class]]) {
                    ((HGBandCardViewController *)viewController).etpsNm = @"";
                    ((HGBandCardViewController *)viewController).userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                    ((HGBandCardViewController *)viewController).userName = [self.personInfo name];
                    ((HGBandCardViewController *)viewController).userPw = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
                    ((HGBandCardViewController *)viewController).orgIstcdFromRegister = @"";
                    ((HGBandCardViewController *)viewController).fromSet = @"true";
                    
                }
                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
    
    
}

#pragma mark -判断超过两小时
-(BOOL)isTwoHours{
    NSString *lastLoginTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoginTime"];//@"2016/11/11-12:10";
    NSString *currentTime = [self getCurrentDate];//@"2016/11/11-14:09";
    NSArray * lastLoginTimeArray = [lastLoginTime componentsSeparatedByString:@"-"];
    NSString *lastLoginMonthAndDay = lastLoginTimeArray[0];
    NSInteger lastDay = [[lastLoginMonthAndDay substringFromIndex:lastLoginMonthAndDay.length - 2] integerValue];
    NSString *lastLoginHourAndMin = lastLoginTimeArray[1];
    NSArray * lastLoginHourAndMinArray = [lastLoginHourAndMin componentsSeparatedByString:@":"];
    NSInteger lastHour = [lastLoginHourAndMinArray[0] integerValue];
    NSInteger lastMin = [lastLoginHourAndMinArray[1] integerValue];
//    NSRange range = [currentTime rangeOfString:@"-"];
    
   
    
    NSArray *currentTimeArr = [currentTime componentsSeparatedByString:@"-"];
    NSString *currentMonthAndDay = currentTimeArr[0];
    NSInteger currentDay = [[currentMonthAndDay substringFromIndex:currentMonthAndDay.length -2] integerValue];
    
    NSString *currentHourAndMin = currentTimeArr[1];
    NSArray *currentHourAndMinArray = [currentHourAndMin componentsSeparatedByString:@":"];
    NSInteger currentHour = [currentHourAndMinArray[0] integerValue];
    NSInteger currentMin = [currentHourAndMinArray[1] integerValue];
    // 天数相等
    if (currentDay == lastDay) {
        if (currentHour > lastHour)
        {
            NSInteger H = currentHour - lastHour;
            if (H >= 3) {
                return YES;
            }else{
                NSInteger M ;
                if (currentMin >= lastMin) {
                    M = H * 60 + (currentMin - lastMin);
                }else{
                    M = H * 60 - (lastMin - currentMin);
                }
                
                if (M>120) {
                    return YES;
                }else{
                    return NO;
                }
            }
        }else{
            // 小时相等
            //        if ((currentMin - lastMin) > 0) {
            //            return YES;
            //        }else
            //        {
            //            return  false;
            //        }
            
            
            return NO;
        }

    }else
    {
        return YES;
    }
    
    
}

//时间戳
-(NSString *)getCurrentDate{
    
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"yyyy/MM/dd-HH:mm"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString * timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    
    return timeNow;
}

#pragma mark -超时弹框
-(void)showAlertAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意" message:@"您登录时间已经超过两小时,请退出重新登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [EMMMediator segueToLoginViewController];
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)logoutAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录超时,请重新登录!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logout];
    }];
    [okAction setValue:[UIColor emm_colorWithHexString:@"#1073BE"] forKey:@"titleTextColor"];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
//    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录超时,请重新登录!" preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        [self logout];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }];
//    [cancelAction setValue:[UIColor emm_colorWithHexString:@"#666666"] forKey:@"titleTextColor"];
//    [sheet addAction:sureAction];
//    [sheet addAction:cancelAction];
//    
//    [sheet show];
}


#pragma mark - logout

- (void)logout {
    
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSString *password = [[EMMApplicationContext defaultContext] objectForKey:@"password"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{
                             @"username": username,
                             @"password": password
                             };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"logout"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            int code =  [result[@"data"][@"code"] intValue];
            if (code == 1) {
//                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usernameNoEnable"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
                UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [UIApplication sharedApplication].delegate.window.rootViewController = naviController;
            }
        }
    } failure:^(NSError *error) {
        // TODO:
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:@"退出登录失败"];
    }];
}

- (void)switchAction:(UISwitch *)switchBtn{
    BOOL close = switchBtn.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:!close forKey:@"closeAssistiveTouch"];
    if(close){
        NSLog(@"关闭多任务");
    }else{
        NSLog(@"打开多任务");
    }
}

//解绑IC卡
-(void)cancelBandICCard{
    [UIAlertController showAlertWithTitle:@"提示" message:@"确定解除绑定蓝牙KEY?" cancelButtonTitle:@"取消" otherButtonTitle:@"是" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
        if(buttonIndex == 1){
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            EMMDataAccessor *verifyDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_bandCard"];
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
            NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
            NSDictionary *params = @{@"userId":username,
                                     @"password":password,
                                     @"cardFlag":@"1",
                                     @"deptNm":@"",
                                     @"etpsNm":@"",
                                     @"icCardNo":@"",
                                     @"istNm":@"",
                                     @"istNum":@"",
                                     @"orgIstcd":@"",
                                     @"etpsUNSocialCrecd":@"",
                                     @"userName":[self.personInfo name]
                                     };
            [verifyDataAccessor sendRequestWithParams:params success:^(id result) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                NSDictionary *dic = result[@"data"];
                NSString *code = dic[@"code"];
                if ([code isEqualToString:@"1"]) {
                    NSDictionary *resultDic = dic[@"resultctx"];
                    NSString *cardManageResult = resultDic[@"cardManageResult"];
                    NSString *msg = resultDic[@"registerDesc"];
                    if ([cardManageResult isEqualToString:@"true"]) {
                        [UIAlertController showAlertWithTitle:msg message:nil cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                            if (buttonIndex == 0) {
                                //退出
                                [self logout];
                            }
                        }];
                    }else{
                        [UIAlertController showAlertWithTitle:@"解除绑定失败" message:msg];
                    }
                }
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
            }];

        }
    }];
}
@end
// 退出登录
//        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            [self logout];
//        }];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//
//        if([[UIDevice currentDevice] systemVersion].floatValue >9.0){
//            [cancelAction setValue:[UIColor emm_colorWithHexString:@"#666666"] forKey:@"_titleTextColor"];
//        }
//        [sheet addAction:sureAction];
//        [sheet addAction:cancelAction];
//        [sheet show];

