//
//  LoginViewController.m
//  appDemo
//
//  Created by zm on 16/6/2.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "EMMLoginViewController.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "EMMDeviceInfo.h"
#import "EMMEncrypt.h"
#import "EMMApplicationContext.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "MBProgressHUD.h"
#import "UIColor+HexString.h"

@interface EMMLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtUserName;          // 用户名、账号
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;          // 密码
@property (weak, nonatomic) IBOutlet UIButton    *btnLogin;             // 登录按钮
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;  // 背景图
@property (weak, nonatomic) IBOutlet UIButton    *pwdVisibleBtn;        // 可显示密码
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UISwitch *autoLoginSwitch;

@end

@implementation EMMLoginViewController

- (instancetype)initWithConfig:(id)config {
    
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL autoLogin = [userDefaults boolForKey:@"autoLogin"];
    BOOL logined = [userDefaults boolForKey:@"logined"];
    NSString *username = [userDefaults objectForKey:@"username"];
    NSString *password = autoLogin ? [userDefaults objectForKey:@"password"] : @"";
    
    self.txtUserName.enabled = !logined;
    self.txtUserName.text = username;
    self.txtPassword.text = password;
    self.autoLoginSwitch.on = autoLogin;
    
    if (autoLogin && username.length && password.length) {
        self.btnLogin.enabled = YES;
        [self registerEMM];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCompletion:(void (^)(BOOL, id))completion {

    // 在用户设置的回调之前添加消除加载框的逻辑
    typeof(self) __weak weakSelf = self;
    _completion = ^(BOOL success, id result) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        completion(success, result);
    };
}

// 布局页面
- (void)layoutView {
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

#pragma mark- 按钮点击

// 密码的明文与密文切换
- (IBAction)btnPwdVisible:(UIButton *)sender {
    self.txtPassword.secureTextEntry = !self.txtPassword.secureTextEntry;
    if (sender.tag == 0) {
        [self.pwdVisibleBtn setImage:[UIImage imageNamed:@"login_pwd_visible.png"] forState:UIControlStateNormal];
        self.pwdVisibleBtn.tag = 1;
        return;
    }
    if (sender.tag == 1) {
        [self.pwdVisibleBtn setImage:[UIImage imageNamed:@"login_pwd_invisible.png"] forState:UIControlStateNormal];
        self.pwdVisibleBtn.tag = 0;
        return;
    }
}

- (IBAction)clickLogin:(id)sender {
    
    [self.view endEditing:YES];
    [self registerEMM];
}

- (void)tapHandle:(UIGestureRecognizer *)tap{
     [self.view endEditing:YES];
}

- (void)registerEMM {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *username = self.txtUserName.text;
    NSString *password = self.txtPassword.text;
    
    NSDictionary *params = @{
                             @"username": username,
                             @"password": password
                             };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"register"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            int code =  [result[@"data"][@"code"] intValue];
            if (code == 1) {
//                [self autofindWithCompanyID:@""];
                [[EMMApplicationContext defaultContext] setObject:username forKey:@"username"];
                [[EMMApplicationContext defaultContext] setObject:password forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                if (self.completion) {
                    self.completion(YES, nil);
                }

            }
            else {
                int status = [result[@"data"][@"status"] intValue];
                if (status == 1) {
                    // 设备没有证书，下载证书
                    NSString *host = [[EMMApplicationContext defaultContext] objectForKey:@"emm_host"];
                    NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
                    NSString *url = [NSString stringWithFormat:@"https://%@/mobem/html/ca.jsp?serialnumber=%@", host, UUID];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }
                else {
                    NSString *message = result[@"data"][@"msg"];
                    [UIAlertController showAlertWithTitle:@"登录失败" message:message];
                }
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}

- (void)loginEMM {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *username = self.txtUserName.text;
    NSString *password = self.txtPassword.text;
    NSDictionary *params = @{
                             @"username": username,
                             @"password": password
                             };
//#warning
    // ==
//    [[EMMApplicationContext defaultContext] setObject:username forKey:@"username"];
//    [[EMMApplicationContext defaultContext] setObject:password forKey:@"password"];
//    [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
//    
//    BOOL autoLogin = self.autoLoginSwitch.on;
//    if (autoLogin) {
//        [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
//    }
//    [[NSUserDefaults standardUserDefaults] setBool:autoLogin forKey:@"autoLogin"];
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logined"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    if (self.completion) {
//        self.completion(YES, nil);
//    }
//    return;
    // ==
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"login"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (result) {
            int code = [result[@"data"][@"code"] intValue];
            if (code == 1) {
                [[EMMApplicationContext defaultContext] setObject:username forKey:@"username"];
                [[EMMApplicationContext defaultContext] setObject:password forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
                
                BOOL autoLogin = self.autoLoginSwitch.on;
                if (autoLogin) {
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
                }
                [[NSUserDefaults standardUserDefaults] setBool:autoLogin forKey:@"autoLogin"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logined"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                if (self.completion) {
                    self.completion(YES, nil);
                }
            }
            else {
                //其他原因 统一提示服务信息,本地不做处理
                NSString *message = result[@"data"][@"msg"];;
                [UIAlertController showAlertWithTitle:@"登录失败" message:message];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}

- (void)autofindWithCompanyID:(NSString *)companyID {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//     NSString *companyid = [[EMMApplicationContext defaultContext] objectForKey:@"emm_companyid"];
    NSDictionary *params = @{ @"companyid": companyID.length?companyID:@"" };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"autofind"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result && [result[@"success"] boolValue]) {
            NSData *data = [result[@"data"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *agentURL = jsonObject[@"config_agent_url"];
            [[EMMApplicationContext defaultContext] setObject:agentURL forKey:@"url_agent"];
            [self loginEMM];
        }
        else {
            NSString *message = result[@"message"];
            [UIAlertController showAlertWithTitle:@"提示" message:message];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtUserName) {        
        [self.txtPassword becomeFirstResponder];
    }
    else {
        [self.view endEditing:YES];
    }
    return YES;
}

- (IBAction)setupServer {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"服务器设置" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSString *companyid = [[EMMApplicationContext defaultContext] objectForKey:@"emm_companyid"];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.placeholder = @"companyID";
        textField.text = companyid;

    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        NSString *host = [[EMMApplicationContext defaultContext] objectForKey:@"emm_host"];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.placeholder = @"IP";
        textField.text = host;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        NSString *port = [[EMMApplicationContext defaultContext] objectForKey:@"emm_port"];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.placeholder = @"端口号";
        textField.text = port;
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *hostTextField = alert.textFields[1];
        UITextField *portTextField = alert.textFields[2];
        UITextField *companyid = alert.textFields[0];
        [[EMMApplicationContext defaultContext] setObject:hostTextField.text forKey:@"emm_host"];
        [[EMMApplicationContext defaultContext] setObject:portTextField.text forKey:@"emm_port"];
        [[EMMApplicationContext defaultContext] setObject:companyid.text forKey:@"emm_companyid"];
        
        [[NSUserDefaults standardUserDefaults] setObject:hostTextField.text forKey:@"emm_host"];
    }];
    [alert addAction:actionCancel];
    [alert addAction:actionDone];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
