//
//  HGLoginViewController.m
//  EMMKitDemo
//
//  Created by 振亚 姜 on 16/6/24.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

//#import "EMMAlert.h"
#import "EMMNetConnection.h"
#import "EMMDeviceInfo.h"
#import "EMMEncrypt.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "MBProgressHUD.h"
#import "HGLoginViewController.h"
#import "HGRegisterViewController.h"
#import "EMMApplicationContext.h"
#import "EMMAnimation.h"
#import "EMMMediator.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "HGRetrievePWDViewController.h"
#import "UIColor+HexString.h"
#import "bleobj.h"
#include"blec.h"
#import "GVUserDefaults+Properties.h"
#import "UIColor+HexString.h"
#import "EMMStorage.h"
#import "VerifyNumberTool.h"
#import "HGDBHandle.h"
#import "UPushService.h"
#import "BluetoothHandler.h"
#import "UINavigationController+Extension.h"
#import <EMMApplicationContext.h>
#import <EMMDataAccessor.h>
#import <EMMPersonInfo.h>
#import <YYModel.h>
//设备全屏宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//设备全屏高度
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kOtherLoginActionSheetTag  10000
#define kBluetoothLoginActionSheetTag 10001
#define kBluetoothDeviceChooseActionSheetTag 10002

#define UPush_APPID @"3"
#define UPush_IP @"219.142.41.82"
#define  UPush_Port @"8080"
//#define UPush_APPID @"3"
//#define UPush_IP @"apppush.chinaport.gov.cn"
//#define  UPush_Port @"7001"

typedef void(^loginBlock)(BOOL succeed,NSString *errorResult);

static NSString *UPLogin = @"普通用户登录";
static NSString *AnLogin = @"匿名登录";
static NSString *BTLogin = @"蓝牙KEY登录";


@interface HGLoginViewController ()<UITextFieldDelegate,UIActionSheetDelegate
,BTSmartSensorDelegate
>{
    NSString *username; //登录用户名
    NSString *password; // 登录密码
    BOOL isAutoFind; //is gets address
    BOOL isBleSerachSucceed;//蓝牙搜索是否成功
    NSString *userType;//用户类型
    NSString *userName;//用户姓名
}
// 中国电子口岸label
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;          // 用户名、账号 --
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;          // 密码 --
@property (weak, nonatomic) IBOutlet UIButton    *btnLogin;             // 登录按钮 --
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;        // logo
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;  // 背景图 --
@property (weak, nonatomic) IBOutlet UIButton    *pwdVisibleBtn;        // 可显示密码,明文切换
@property (weak, nonatomic) IBOutlet UIView *loginView;

// 切换登录方式按钮 --
@property (weak, nonatomic) IBOutlet UIButton *chooseLoginType;
//@property (weak, nonatomic) IBOutlet UISwitch *rememberUserSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *txtPasswordImageView;
@property (weak, nonatomic) IBOutlet UIView *underPasswordView;

// 底部版本号
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
// 登录类型的ytpe标题
@property (weak, nonatomic) IBOutlet UILabel *loginTitle;

// 找回密码按钮 ---
@property (weak, nonatomic) IBOutlet UIButton *resetPWDBtn;
@property (strong, nonatomic) bleobj *ble;
@property(nonatomic,strong) EMMPersonInfo *info;
@end

@implementation HGLoginViewController


- (instancetype)initWithSettings:(NSDictionary *)settings completion:(void (^)(BOOL success, id result))completion {
    if (self = [super init]) {
        
        _settings = settings;
        self.completion = completion;
        isAutoFind = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
//    //蓝牙
//    _ble = [[bleobj alloc] init];
//    _ble.delegate = self;
//    _ble.peripherals = nil;
//    void* p = (__bridge void*)_ble;
//    ble_setdelegate(p);
    
    [self loadViewFromSettings];
    [self layoutView];
    
    self.loginType = HGLoginType_User;
    [self checkAutoFind:^(BOOL succeed, NSString *errorResult) {
        if (succeed) {
            [self checkVersion];
        }
    }];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"switchon"];
}

- (void) checkAutoFind:(loginBlock)block {
    if(isAutoFind) {
        block(YES,nil);
    } else {
        [self autoFind:^(BOOL succeed, NSString *errorResult){
            if (succeed) {
                isAutoFind = YES;
                block(YES,nil);
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                isAutoFind = NO;
                [UIAlertController showAlertWithTitle:@"提示" message:errorResult];
                block(NO,errorResult);
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.txtUserName.text.length && self.txtUserName.text.length){
        self.btnLogin.userInteractionEnabled = YES;
    }
    else{
        self.btnLogin.userInteractionEnabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_ble disconnect];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // 隐藏系统的导航栏
    self.navigationController.navigationBarHidden = YES;
    
    NSInteger savedLoginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
    if (savedLoginType == 2) {
        self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
    }else{
        NSString *savedusername = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        if ([savedusername isEqualToString:@"guest"]) {
            self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
        }else{
            self.txtUserName.text = savedusername.length?savedusername:self.txtUserName.text;
        }
    }
    NSString *app_Version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"版本号:%@",app_Version];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCompletion:(void (^)(BOOL, id))completion {
    __block NSDictionary *config = [EMMMediator applicationsConfig];
    // 在用户设置的回调之前添加消除加载框的逻辑
    typeof(self) __weak weakSelf = self;
    _completion = ^(BOOL success, id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        if(success){
//            if(self.loginType == HGLoginType_Anonymity){
//                NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:config];
//                NSArray *tabs = config[@"tabs"];
//                NSMutableArray *temp = [NSMutableArray new];
//                for(NSDictionary *dic in tabs){
//                    if(![dic[@"title"] isEqualToString:@"消息"]){
//                        [temp addObject:dic];
//                    }
//                }
//                [tempDic setObject:temp forKey:@"tabs"];
//                config = [NSDictionary dictionaryWithDictionary:tempDic];
//            }
            
            UIViewController<EMMConfigurable> *tabBarController = [[NSClassFromString(@"EMMTabBarController") alloc] initWithConfig:config];
            [EMMAnimation addAnimationToWindowWithduration:0.5 fromDirection:@"right" target:weakSelf];
            [UIApplication sharedApplication].keyWindow.rootViewController = tabBarController;
        }
        
        //        completion(success, result);
    };
}



// 布局页面
- (void)layoutView{
    self.btnLogin.layer.cornerRadius = 5.0f;
    self.btnLogin.layer.masksToBounds = YES;
    
    self.loginView.layer.cornerRadius = 8.0f;
    self.loginView.layer.masksToBounds = YES;
    self.loginView.layer.borderWidth = 0.5;
    self.loginView.layer.borderColor = [[UIColor emm_colorWithHexString:@"#dadada"]CGColor];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, self.view.frame.size.width , 0.5)];
    lineLabel.backgroundColor = [UIColor emm_colorWithHexString:@"#dadada"];
    [self.loginView addSubview:lineLabel];
}

// 加载配置
- (void)loadViewFromSettings {
    
    // logo
    NSString *logo = self.settings[@"loginlogo"];
    if (logo) {
        self.iconImageView.image = [UIImage imageNamed:logo];
    }
    // 背景图
    NSString *background = self.settings[@"loginbackground"];
    if(background) {
        self.backgroundImageView.image = [UIImage imageNamed:background];
    }
    // 登录按钮的边框及颜色
    self.btnLogin.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnLogin.layer.borderWidth = 1;
//    self.pwdVisibleBtn.hidden = YES;
//    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:23]];
    self.titleLabel.font = [UIFont fontWithName:@"HYk2gj" size:20];
    [self.txtUserName setValue:[UIColor emm_colorWithHexString:@"#d0dbe4"] forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtPassword setValue:[UIColor emm_colorWithHexString:@"#d0dbe4"] forKeyPath:@"_placeholderLabel.textColor"];
}


#pragma mark- 按钮点击
- (IBAction)tapHandle:(id)sender {
    [self.txtPassword resignFirstResponder];
    [self.txtUserName resignFirstResponder];
}

// 密码的明文与密文切换
- (IBAction)btnPwdVisible:(UIButton *)sender {
    self.txtPassword.secureTextEntry = !self.txtPassword.secureTextEntry;
    if (sender.tag == 0) {
        [self.pwdVisibleBtn setImage:[UIImage imageNamed:@"login_pwd_visible.png"] forState:UIControlStateNormal];
        self.pwdVisibleBtn.tag = 1;
        self.txtPassword.font = [UIFont systemFontOfSize:17.0];
        return;
    }
    if (sender.tag == 1) {
        [self.pwdVisibleBtn setImage:[UIImage imageNamed:@"login_pwd_invisible.png"] forState:UIControlStateNormal];
        self.pwdVisibleBtn.tag = 0;
        self.txtPassword.font = [UIFont systemFontOfSize:17.0];
        return;
    }
}


// 找回密码
- (IBAction)clickedFindPWD:(id)sender {
    [self checkAutoFind:^(BOOL succeed, NSString *errorResult) {
        if(succeed) {
            HGRetrievePWDViewController *retrievePWD = [[HGRetrievePWDViewController alloc] init];
            [self.navigationController pushViewController:retrievePWD animated:YES];
        }
    }];
}
// 登录
- (IBAction)clickLogin:(id)sender {
    [self tapHandle:nil];
    username = self.txtUserName.text;
    password = self.txtPassword.text;
    if (self.loginType == HGLoginType_Bluetooth && password.length != 8) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"蓝牙KEY密码必须为8位"];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self checkAutoFind:^(BOOL succeed, NSString *errorResult) {
        if(succeed) {
            [self login];
        }
    }];
}
// 注册
- (IBAction)clickedRegister:(id)sender {
    HGRegisterViewController *HGregister = [[HGRegisterViewController alloc] init];
    [self.navigationController pushViewController:HGregister animated:YES];

}
// 切换登录方式
- (IBAction)chooseLoginTypeAction:(UIButton *)sender {
    [self.view endEditing:YES];
    //蓝牙
    NSMutableArray *allTitles = [NSMutableArray arrayWithObjects:UPLogin,AnLogin, nil];
//    NSMutableArray *allTitles = [NSMutableArray arrayWithObjects:UPLogin,AnLogin, nil];
    [allTitles removeObjectAtIndex:self.loginType];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:allTitles[0],nil];//蓝牙+allTitles[1],
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = kOtherLoginActionSheetTag;
    [actionSheet showInView:self.view];
    
    
}

#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == kOtherLoginActionSheetTag){
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:AnLogin]){
            self.loginType = HGLoginType_Anonymity;
            self.txtUserName.placeholder = @"手机号";
            self.txtUserName.text = @"guest";
            self.txtPassword.text = @"";
            self.txtPassword.hidden = YES;
            self.txtPasswordImageView.hidden = YES;
            self.underPasswordView.hidden = YES;
            self.pwdVisibleBtn.hidden = YES;
            self.registBtn.hidden = YES;
            self.loginTitle.text = @"匿名登录";
            self.resetPWDBtn.hidden = YES;
            self.txtUserName.userInteractionEnabled = NO;
            self.txtPassword.userInteractionEnabled = NO;
            self.btnLogin.userInteractionEnabled = YES;
            [self changeLoginBtnTitleColor:YES];
        }
        else if ([title isEqualToString:UPLogin]){
            self.loginType = HGLoginType_User;
            self.txtPassword.hidden = false;
            self.txtPasswordImageView.hidden = false;
            self.underPasswordView.hidden = false;
            self.pwdVisibleBtn.hidden = false;
            self.registBtn.hidden = false;
            self.txtUserName.placeholder = @"手机号";
            self.txtUserName.text = @"";
            self.txtPassword.text = @"";
            self.loginTitle.text = @"普通用户登录";
            NSInteger savedLoginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
            if (savedLoginType == 2) {
                self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
            }else{
                NSString *savedusername = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
                if ([savedusername isEqualToString:@"guest"]) {
                    self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
                }else{
                    self.txtUserName.text = savedusername;
                }
            }
            self.txtUserName.userInteractionEnabled = YES;
            self.txtPassword.userInteractionEnabled = YES;
            self.resetPWDBtn.hidden = NO;
            [self changeLoginBtnTitleColor:NO];
        }
        else if ([title isEqualToString:BTLogin]){
            //蓝牙
            if (!_ble) {
                _ble = [[bleobj alloc] init];
            }
            _ble.delegate = self;
            _ble.peripherals = nil;
            void* p = (__bridge void*)_ble;
            ble_setdelegate(p);
            self.loginType = HGLoginType_Bluetooth;
            self.txtUserName.placeholder = @"请选择蓝牙设备";
            self.txtUserName.text = @"";
            self.txtPassword.text = @"";
            self.loginTitle.text = @"蓝牙KEY登录";
            self.txtUserName.userInteractionEnabled = YES;
            self.txtPassword.userInteractionEnabled = YES;
            self.resetPWDBtn.hidden = YES;
            [self changeLoginBtnTitleColor:NO];
        }
        
    }
    else if (actionSheet.tag == kBluetoothLoginActionSheetTag){
        if(buttonIndex != 4){
            [self.txtUserName setText:[actionSheet buttonTitleAtIndex:buttonIndex]];
        }
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(actionSheet.tag == kOtherLoginActionSheetTag){
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        if([title isEqualToString:AnLogin]){
            // 匿名登录
            
        }
        if ([title isEqualToString:BTLogin]) {
           
//            [[NSUserDefaults standardUserDefaults] setBool:self.rememberUserSwitch.isOn forKey:@"switchon"];
            //蓝牙登陆,搜索蓝牙设备
            [_ble setTimeOutForScan:50 forTransmit:50];
            //开始搜索
            [_ble scanPeripheral];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(scanTimer) userInfo:nil repeats:NO];
            
            [self performSelector:@selector(addBleCards) withObject:nil afterDelay:5.0f];
        }
    }
    
}

-(void)scanTimer
{
    if (!isBleSerachSucceed) {
        [self resetBleCardLogin];
        //蓝牙
        [_ble stopScan];
    }
    isBleSerachSucceed = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

//蓝牙代理方法
-(void)peripheralFound:(CBPeripheral *)peripheral{
    
}
-(void)addBleCards{
    if (_ble.peripherals.count > 0) {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (CBPeripheral *peripheral in _ble.peripherals) {
            _ble.activePeripheral = peripheral;
            __block CBPeripheral *weakperipheral = _ble.activePeripheral;
            __block bleobj *weakble = _ble;
            __block typeof(self) weakself = self;
            __block int t;
            UIAlertAction *action = [UIAlertAction actionWithTitle:peripheral.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                t = [weakble connect:weakperipheral];
                [weakble stopScan];
                if (t == 0) {
                    NSLog(@"蓝牙连接成功");
                    [weakself readBleDevice];
                }
            }];
            [alertcontroller addAction:action];
        }
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertcontroller addAction:actionCancel];
        [self presentViewController:alertcontroller animated:YES completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self resetBleCardLogin];
//        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        HUD.mode = MBProgressHUDModeText;
//        HUD.label.text = @"未找到蓝牙设备,请开启您的蓝牙设备";
//        HUD.removeFromSuperViewOnHide = YES;
//        [HUD hideAnimated:YES afterDelay:1.5];
        [UIAlertController showAlertWithTitle:@"提示" message:@"未搜索到可用的蓝牙KEY设备，请确认手机是否打开蓝牙或者蓝牙KEY已开启。\n注：有蓝牙KEY需求的企业，请联系当地分中心申请！"];
        [_ble stopScan];
    }
}
//读取蓝牙设备
-(void)readBleDevice{
    isBleSerachSucceed = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       __block NSString *cardID  = @"";
       __block NSString *certNoStr = @"";
        [BluetoothHandler getCardID:^(BOOL isSuccess, NSString *result) {
            if(isSuccess){
                cardID = result;
            }
        }];
        
        [BluetoothHandler getCardUserInfo:^(BOOL isSuccess, NSString *result) {
            if(isSuccess){
                certNoStr = result;
            }
        }];
//        char *cc = getCardID();
//        char *certno = getCardUserInfo();
//        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//        NSString *cardID = [[NSString alloc] initWithCString:cc encoding:enc];
//        NSString *certNoStr = [[NSString alloc] initWithCString:certno encoding:enc];
        NSLog(@"%@------certNO:%@",cardID,certNoStr);
        if (certNoStr &&![certNoStr isEqualToString:@""]) {
            NSArray *temp = [certNoStr componentsSeparatedByString:@"||"];
            NSString *certNo = temp[0];
            [[EMMApplicationContext defaultContext] setObject:certNo forKey:@"certNo"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cardID && ![cardID isEqualToString:@""] && self.loginType == HGLoginType_Bluetooth) {
                self.txtUserName.text = cardID;
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
//        delete cc;
//        delete certno;
//        cc = NULL;
//        certno = NULL;
    });
    
}

-(void)login{
    // 匿名登录
    if (self.loginType == HGLoginType_Anonymity) {
        [self guestLogin];
    }else{
        // 普通登录
        if (self.loginType == HGLoginType_User) {
            BOOL istelnumOK = [VerifyNumberTool verifyPhoneNumber:self.txtUserName.text];
            if (!istelnumOK) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效手机号"];
                return;
            }
            
        }
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self verifyMA:^(BOOL succeed, NSString *errorResult) {
            if(succeed){
                [self registerEMM:^(BOOL succeed, NSString *errorResult) {
                    if(succeed){
                        NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
                        [UPushService upushSignin:pushToken ip:UPush_IP port:UPush_Port appid:UPush_APPID deviceid:self.txtUserName.text complete:^(BOOL success) {
                            if(success){
                                NSLog(@"注册成功");
                            }
                        }];
                        NSString *lastLoginTime = [self getCurrentDate];
                        [[NSUserDefaults standardUserDefaults] setObject:lastLoginTime forKey:@"lastLoginTime"];
                        if (self.completion) {
                            self.completion(YES, nil);
                        }
                    }
                    else{
                        [self failerHandle:errorResult];
                    }
                }];
            }
            else{
                [self failerHandle:errorResult];
            }
        }];
    }
}

-(void)guestLogin{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    username = @"guest";
    password= @"";
//    [self.rememberUserSwitch setOn:NO];
//    [[NSUserDefaults standardUserDefaults] setBool:self.rememberUserSwitch.isOn forKey:@"switchon"];
    userType = @"guest";
    userName = @"guest";
    NSString *usertype = [NSString stringWithFormat:@"str-%@",userType];
    [[EMMStorage sharedInstance] setValue:usertype forKey:@"usertype" toLocation:EMMStorageLocationApplicationContext];
    [[EMMStorage sharedInstance] setValue:@"str-" forKey:@"attributes" toLocation:EMMStorageLocationApplicationContext];
    [[EMMStorage sharedInstance] setValue:@"str-" forKey:@"userID" toLocation:EMMStorageLocationApplicationContext];
    [[EMMStorage sharedInstance] setValue:@"str-" forKey:@"ticketid" toLocation:EMMStorageLocationApplicationContext];
    [self registerEMM:^(BOOL succeed, NSString *errorResult) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(succeed){
            NSString *lastLoginTime = [self getCurrentDate];
            [[NSUserDefaults standardUserDefaults] setObject:lastLoginTime forKey:@"lastLoginTime"];
            if (self.completion) {
                self.completion(YES, nil);
            }
        }
        else{
            [self failerHandle:errorResult];
        }
    }];
}

- (void)failerHandle:(NSString *)errorResult{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [UIAlertController showAlertWithTitle:@"登录失败" message:errorResult];
    
    if(self.loginType == HGLoginType_Anonymity){
        self.loginType = HGLoginType_User;
        self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
        self.txtPassword.hidden = false;
        self.txtPasswordImageView.hidden = false;
        self.underPasswordView.hidden = false;
        self.pwdVisibleBtn.hidden = false;
        self.registBtn.hidden = false;
        self.resetPWDBtn.hidden = false;
    }
}

// 1.自动发现获取agentUrl
-(void)autoFind:(loginBlock)block{

    EMMDataAccessor *autoFindDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"autofind"];
    [autoFindDataAccessor sendRequestWithParams:@{@"companyID":@""} success:^(id result) {
        NSLog(@"login-autofind-%@",result);
        if(result != nil){
            NSString *starusStr = [NSString stringWithFormat:@"%@", result[@"status"]];
            if(!starusStr.length || [starusStr isKindOfClass:[NSNull class]]){
                block(NO,@"登录失败");
                return ;
            }
            int status =  [result[@"status"] intValue];
            if (status == 1) {
                NSData *data = [result[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *error = nil;
                id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSDictionary *dic = nil;
                if ([jsonObject isKindOfClass:[NSDictionary class]]){
                    dic = (NSDictionary *)jsonObject;
                }
                NSString * agentUrl = dic[@"config_agent_url"];
                NSString * cloudUrl = dic[@"config_cloud_url"];
                NSString * maUrl = dic[@"config_ma_url"];
                if (agentUrl && ![agentUrl isEqualToString:@""]) {
                    NSString *agentHost;
                    NSString *agentPort;
                    if ([agentUrl rangeOfString:@"http"].location != NSNotFound || [agentUrl rangeOfString:@"https"].location != NSNotFound ) {
                        NSArray *arr1 = [agentUrl componentsSeparatedByString:@":"];
                        NSString *host = [NSString stringWithFormat:@"%@:%@",arr1[0],arr1[1]];
                        agentHost = [NSString stringWithFormat:@"str-%@",host];
                        NSString *port = arr1[2];
                        agentPort = [NSString stringWithFormat:@"str-%@",port];
                    }else{
                        NSArray *arr2 = [agentUrl componentsSeparatedByString:@":"];
                        NSString *host = arr2[0];
                        agentHost = [NSString stringWithFormat:@"str-%@",host];
                        NSString *port = arr2[1];
                        agentPort = [NSString stringWithFormat:@"str-%@",port];
                    }
                    [[EMMStorage sharedInstance] setValue:agentHost forKey:@"agentHost" toLocation:EMMStorageLocationApplicationContext];
                    [[EMMStorage sharedInstance] setValue:agentPort forKey:@"agentPort" toLocation:EMMStorageLocationApplicationContext];
                }
                
                [[EMMApplicationContext defaultContext] setObject:agentUrl forKey:@"url_agent"];
                [[EMMApplicationContext defaultContext] setObject:maUrl forKey:@"maUrl"];
                [[EMMApplicationContext defaultContext] setObject:cloudUrl forKey:@"cloudUrl"];
                
                [[NSUserDefaults standardUserDefaults]setObject:agentUrl forKey:@"url_agent"] ;
                [[NSUserDefaults standardUserDefaults]setObject:maUrl forKey:@"maUrl"] ;
                [[NSUserDefaults standardUserDefaults]setObject:cloudUrl forKey:@"cloudUrl"] ;
                
                block(YES,nil);
                return;
            }
        }
        block(NO, result[@"message"]);
    } failure:^(NSError *error) {
        block(NO,error.localizedDescription);
    }];
}
//检查新版本
-(void)checkVersion{
    EMMDataAccessor *checkVersionAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"checkVersion"];
    [checkVersionAccessor sendRequestWithParams:@{@"appid":@"com.cscec3.mdmpush"} success:^(id result) {
        NSDictionary *resDic = result;
        NSInteger code = [resDic[@"code"] integerValue];
        NSString *msg = resDic[@"msg"];
        if (code == 0) {
            NSDictionary *dataDic = resDic[@"data"][@"appdetail"];
            NSString * appversionStr = dataDic[@"iosversion"];
            NSString *isUpdate = dataDic[@"iosupdate"];
            NSInteger appversion = [self stringTointeger:appversionStr];
            NSString * url = @"https://itunes.apple.com/cn/app/zhong-guo-dian-zi-kou-an/id1164930607?mt=8";
            NSString * localVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSInteger localVersion = [self stringTointeger:localVersionStr];
            if (localVersion < appversion) {
                if ([isUpdate isEqualToString:@"Y"]) {
                    [UIAlertController showAlertWithTitle:@"提示" message:@"发现新版本,请更新" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                            NSArray *arr = @[@"1",@"2"];
                            NSString *tem = arr[2];
                        }
                    }];
                }else{
                    [UIAlertController showAlertWithTitle:@"提示" message:@"发现新版本,请更新" cancelButtonTitle:@"取消 " otherButtonTitle:@"确定" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                        }
                    }];
                }
                
            }
        }else{
            NSLog(@"检查更新失败----%@",msg);
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)verifyMA:(loginBlock)block{
    if (self.loginType == HGLoginType_Bluetooth)
    {
        [self getBleCardRandom:^(BOOL succeed, NSString *errorResult) {
            if (succeed) {
                EMMDataAccessor *verifyDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_Login"];
                NSDictionary *params = @{@"username":username,@"password":password,@"iscard":@"true"};
                [verifyDataAccessor sendRequestWithParams:params success:^(id result) {
                    NSDictionary *dic = result[@"data"];
                    NSString *code = dic[@"code"];
                    if ([code isEqualToString:@"1"])
                    {
                        NSString *flag = dic[@"resultctx"][@"flag"];
                        if ([flag isEqualToString:@"1"]) {
                            NSString *castgc = [NSString stringWithFormat:@"str-%@",dic[@"resultctx"][@"casTgc"]];
                            [[EMMStorage sharedInstance] setValue:castgc forKey:@"casTgc" toLocation:EMMStorageLocationApplicationContext];
                            NSString *jsonStr = dic[@"resultctx"][@"attributes"];
                            userType = @"4";
                            NSDictionary *attributesDic = [self dictionaryWithJsonString:jsonStr];
                            userName = attributesDic[@"OP_NAME"];
                            NSString *ticketid = dic[@"resultctx"][@"ticketid"];
                            jsonStr = [NSString stringWithFormat:@"str-%@",jsonStr];
                            NSString * userID = [NSString stringWithFormat:@"str-%@",self.txtUserName.text];
                            ticketid = [NSString stringWithFormat:@"str-%@",ticketid];
                            NSString *usertype = [NSString stringWithFormat:@"str-%@",userType];
                            [[EMMStorage sharedInstance] setValue:jsonStr forKey:@"attributes" toLocation:EMMStorageLocationApplicationContext];
                            [[EMMStorage sharedInstance] setValue:userID forKey:@"userID" toLocation:EMMStorageLocationApplicationContext];
                            [[EMMStorage sharedInstance] setValue:ticketid forKey:@"ticketid" toLocation:EMMStorageLocationApplicationContext];
                            [[EMMStorage sharedInstance] setValue:usertype forKey:@"usertype" toLocation:EMMStorageLocationApplicationContext];
                            block(YES,nil);
                        }else{
                            [self resetBleCardLogin];
                            NSString *msg = dic[@"resultctx"][@"msg"];
                            block(NO,msg);
                        }
                    }else{
                        [self resetBleCardLogin];
                        NSString *msg = dic[@"msg"];
                        block(NO,msg);
                    }
                } failure:^(NSError *error) {
                    [self resetBleCardLogin];
                    block(NO,error.localizedDescription);
                }];
            }else{
                [self resetBleCardLogin];
                [self failerHandle:errorResult];
            }
        }];
    }else{
        EMMDataAccessor *verifyDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_Login"];
        NSDictionary *params = @{@"username":username,@"password":password};
        [verifyDataAccessor sendRequestWithParams:params success:^(id result) {
            NSDictionary *dic = result[@"data"];
            NSString *code = dic[@"code"];
            if ([code isEqualToString:@"1"]) {
                NSString *flag = dic[@"resultctx"][@"flag"];
                if ([flag isEqualToString:@"1"]) {
                    
                    NSString *jsonStr = dic[@"resultctx"][@"attributes"];
                    NSString *castgc = [NSString stringWithFormat:@"str-%@",dic[@"resultctx"][@"casTgc"]];
                    
                    NSDictionary *dict = [self dictionaryWithJsonString:dic[@"resultctx"][@"attributes"]];
                    self.userName = dict[@"USER_MOBNUM"];
                    WYUserDefault.USER_MOBNUM = dict[@"USER_MOBNUM"];
                    WYUserDefault.USER_NAME = dict[@"USER_NAME"];
                    [[NSUserDefaults standardUserDefaults] setObject:dict[@"USER_NAME"] forKey:@"LoginUserName"];
                    [self getPersonInfo];
                    // 添加tgc
                    [[EMMStorage sharedInstance] setValue:castgc forKey:@"casTgc" toLocation:EMMStorageLocationApplicationContext];
                    NSDictionary *attributesDic = [self dictionaryWithJsonString:jsonStr];
                    userType = attributesDic[@"USER_TYPECD"];
                    userName = attributesDic[@"USER_NAME"];
                    [[NSUserDefaults standardUserDefaults] setObject:attributesDic[@"USER_TYPECD"] forKey:@"userType"];
                    NSString *ticketid = dic[@"resultctx"][@"ticketid"];
                    NSString *usertype = [NSString stringWithFormat:@"str-%@",userType];
                    jsonStr = [NSString stringWithFormat:@"str-%@",jsonStr];
                    NSString * userID = [NSString stringWithFormat:@"str-%@",self.txtUserName.text];
                    ticketid = [NSString stringWithFormat:@"str-%@",ticketid];
                    [[EMMStorage sharedInstance] setValue:jsonStr forKey:@"attributes" toLocation:EMMStorageLocationApplicationContext];
                    [[EMMStorage sharedInstance] setValue:userID forKey:@"userID" toLocation:EMMStorageLocationApplicationContext];
                    [[EMMStorage sharedInstance] setValue:ticketid forKey:@"ticketid" toLocation:EMMStorageLocationApplicationContext];
                    [[EMMStorage sharedInstance] setValue:usertype forKey:@"usertype" toLocation:EMMStorageLocationApplicationContext];
                    block(YES,nil);
                }else{
                    NSString *msg = dic[@"resultctx"][@"msg"];
                    block(NO,msg);
                }
            }else{
                NSString *msg = dic[@"msg"];
                block(NO,msg);
            }
        } failure:^(NSError *error) {
            block(NO,error.localizedDescription);
        }];
    }
    
}

// 获取个人信息
- (void)getPersonInfo {
//    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSDictionary *params = @{ @"username": self.userName };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"getUserInfo"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        //        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.info = [EMMPersonInfo yy_modelWithJSON:result[@"data"]];
        WYUserDefault.typeString = self.info.department;
//        [[NSUserDefaults standardUserDefaults] setObject:self.info.department forKey:@"LoginTypeCD"];
    } failure:^(NSError *error) {
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        
//        NSDictionary *dict = @{@"str":@"",@"identity":@""};
//        //创建通知xx
//        NSNotification *notification1 =[NSNotification notificationWithName:@"name1" object:self userInfo:dict];
//        //通过通知中心发送通知
//        [[NSNotificationCenter defaultCenter] postNotification:notification1];
        
//        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}


//取蓝牙卡随机数
-(void)getBleCardRandom:(loginBlock)block{
    EMMDataAccessor *getBleCardRandomAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_GetBleCardRandom"];
    NSDictionary *params = @{@"username":username,@"password":password};
    [getBleCardRandomAccessor sendRequestWithParams:params success:^(id result) {
        NSLog(@"%@",result);
        NSDictionary *dic = result[@"data"];
        NSString *code = dic[@"code"];
        if ([code isEqualToString:@"1"]) {
            NSDictionary *resDic = dic[@"resultctx"];
            NSString * jssionId = resDic[@"jssionid"];
            NSString * lt = resDic[@"lt"];
            NSString * random = resDic[@"random"];
            NSString * serverDate = resDic[@"serverDate"];
            
            if (random && ![random isEqualToString:@""]) {
                NSString *signData = [self BleSign:random];
                if([signData isEqualToString:@""]){
                     [_ble disconnect];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    return ;
                }
                [[EMMApplicationContext defaultContext] setObject:signData forKey:@"signData"];
                [[EMMApplicationContext defaultContext] setObject:random forKey:@"random"];
            }
            
            [[EMMApplicationContext defaultContext] setObject:jssionId forKey:@"jssionId"];
            [[EMMApplicationContext defaultContext] setObject:lt forKey:@"lt"];
            [[EMMApplicationContext defaultContext] setObject:serverDate forKey:@"serverDate"];
            //蓝牙
            [_ble disconnect];
            block(YES,nil);
        }else{
            NSString *msg = dic[@"msg"];
            block(NO,msg);
        }
    } failure:^(NSError *error) {
        block(NO,error.localizedDescription);
    }];
}
//蓝牙签名
-(NSString *)BleSign:(NSString *)random{
    const char* ss = [random cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned long len = strlen(ss);
    unsigned char *rr = [BluetoothHandler enCodingFromString:random];
    unsigned char *ppp = [BluetoothHandler enCodingFromString:self.txtPassword.text];
    __block NSString *signData = @"";
    [BluetoothHandler signName:rr randomLen:(unsigned int)len pin:ppp resultBlock:^(BOOL isSuccess, NSString *result) {
        if(isSuccess){
            signData = result;
        }
        else{
            [UIAlertController showAlertWithTitle:@"提示" message:result];
        }
    }];
    
    NSLog(@"signData:%@",signData);
    
    return signData;
    
}

// 2. 注册emm
- (void)registerEMM:(loginBlock)block{
    
    __weak typeof(self) weakSelf = self;
    EMMDataAccessor *registerDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"register"];
    NSDictionary *params = @{@"username":username,@"password":password,@"usertype":userType,@"userName":userName};
    [registerDataAccessor sendRequestWithParams:params success:^(id result) {
        
        NSLog(@"login-register-%@",result);
        if(result != nil){
            
            NSDictionary *data = result[@"data"];
            if(data.count){
                NSString *codeStr = [NSString stringWithFormat:@"%@",data[@"code"]];
                NSString *statusStr = [NSString stringWithFormat:@"%@",data[@"status"]];
                int code = [codeStr intValue];
                int status = 0;
                
                if(code !=1 ){
                    if( ![statusStr isKindOfClass:[NSNull class]] && statusStr.length){
                        status = [statusStr intValue];
                    }
                }
                
                if( code == 1 || (code==0&&status == 1)){
                    [[EMMApplicationContext defaultContext] setObject:username forKey:@"username"];
                    [[EMMApplicationContext defaultContext] setObject:password forKey:@"password"];
                    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                    //显示登录名时,如果是guest,则取此值
                    if (![username isEqualToString:@"guest"] && weakSelf.loginType !=HGLoginType_Bluetooth) {
                        [[NSUserDefaults standardUserDefaults]setObject:username forKey:@"username1"] ;
                    }
                    [[NSUserDefaults standardUserDefaults]setObject:password forKey:@"password"] ;
                    if(weakSelf.loginType != HGLoginType_Anonymity){
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"usernameNoEnable"];
                    }
                    [[NSUserDefaults standardUserDefaults] setInteger:weakSelf.loginType forKey:@"currentLoginType"];
                    [[HGDBHandle sharedInstance] creatTable];
                    
                    block(YES,nil);
                    
                }
                else{
                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                    
                    NSString *msg = result[@"data"][@"msg"];
                    if([msg rangeOfString:@"1060"].length){
                        // 不存在的用户
                        weakSelf.txtUserName.enabled = YES;
                        weakSelf.chooseLoginType.hidden = NO;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usernameNoEnable"];
                    }
                    block(NO,msg);
                    
                }
            }
        }
        
    } failure:^(NSError *error) {
        block(NO,error.localizedDescription);
    }];
}

// 3.登录emm
- (void)loginEMM:(loginBlock)block{
    EMMDataAccessor *loginDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"login"];
    NSDictionary *params = @{@"username":username,@"password":password};
    [loginDataAccessor sendRequestWithParams:params success:^(id result) {
        NSLog(@"login-login-%@",result);
        if (result != nil ) {
            NSString * str = result[@"data"];
            NSString *json2=nil;
            if ([str isKindOfClass:[NSString class]]) {
                json2 = [EMMEncrypt decryptDES:str];
            }
            NSData *data = [json2 dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSDictionary *dic = nil;
            if ([jsonObject isKindOfClass:[NSDictionary class]]){
                dic = (NSDictionary *)jsonObject;
            }
            int code = [dic[@"code"] intValue];
            
            
            if (code == 1) {
                NSString * massotoken = dic[@"resultctx"][@"massotoken"];
                NSString * nctoken = dic[@"resultctx"][@"nctoken"];
                NSString * imtoken = dic[@"resultctx"][@"imtoken"];
                NSString * expiration = dic[@"resultctx"][@"expiration"];
                NSString * userid = dic[@"resultctx"][@"userid"];
                
                [[NSUserDefaults standardUserDefaults]setObject:massotoken forKey:@"massotoken"] ;
                [[NSUserDefaults standardUserDefaults] setObject:nctoken forKey:@"nctoken"];
                [[NSUserDefaults standardUserDefaults]setObject:imtoken forKey:@"imtoken"] ;
                [[NSUserDefaults standardUserDefaults] setObject:expiration forKey:@"expiration"];
                [[NSUserDefaults standardUserDefaults] setObject:userid forKey:@"userid"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                block(YES,nil);
            }
        }
        
        block(NO,result[@"message"]);
    } failure:^(NSError *error) {
        block(NO,error.localizedDescription);
    }];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.loginType == HGLoginType_Bluetooth && textField.tag == 0) {
        [self.view endEditing:YES];
        
        /*UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:titles, nil];
         
         actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
         actionSheet.tag = kBluetoothLoginActionSheetTag;
         [actionSheet showInView:self.view];
         */
        
        
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.txtPassword){
        if(range.location >=16)
            return NO;
    }
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(self.txtUserName.text.length && self.txtPassword.text.length){
        self.btnLogin.userInteractionEnabled = YES;
    }
    else{
        self.btnLogin.userInteractionEnabled = NO;
    }
    [self changeLoginBtnTitleColor:self.btnLogin.userInteractionEnabled];
}


- (void)textFieldDidChanged:(NSNotification *)notif{
    if(self.txtUserName.text.length && self.txtPassword.text.length){
        self.btnLogin.userInteractionEnabled = YES;
    }
    else{
        self.btnLogin.userInteractionEnabled = NO;
    }
    [self changeLoginBtnTitleColor:self.btnLogin.userInteractionEnabled];
}

#pragma mark - pickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (void)changeLoginBtnTitleColor:(BOOL)isVisible{
    if(isVisible){
        [self.btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        [self.btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}



- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
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

//蓝牙卡登录失败重置
-(void)resetBleCardLogin{
    self.loginType = HGLoginType_User;
    self.txtUserName.placeholder = @"手机号";
//    self.txtUserName.text = @"";
    self.txtPassword.text = @"";
    NSInteger savedLoginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
    if (savedLoginType == 2) {
        self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
    }else{
        NSString *savedusername = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
        if ([savedusername isEqualToString:@"guest"]) {
            self.txtUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username1"];
        }else{
            self.txtUserName.text = savedusername;
        }
    }
    self.resetPWDBtn.hidden = NO;
    self.txtUserName.userInteractionEnabled = YES;
    self.txtPassword.userInteractionEnabled = YES;
    self.loginTitle.text = @"普通用户登录";
    //蓝牙
    [_ble disconnect];
}

-(NSInteger)stringTointeger:(NSString *)string{
    if ([string rangeOfString:@"."].location != NSNotFound) {
        string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (string.length <=2) {
            string = [string stringByAppendingString:@"0"];
        }
    }
    NSInteger num = [string integerValue];
    return num;
}



@end
