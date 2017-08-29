//
//  ModifyPasswordViewController.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h"
#import "VerifyNumberTool.h"
#import "EMMApplicationContext.h"
#import "EMMMediator.h"
#import <EMMTabBarController.h>
#define lineColor [UIColor colorWithRed:128/255.0 green:127/255.0 blue:127/255.0 alpha:0.3f]

@interface ModifyPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
// 原密码
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
// 新密码
@property (weak, nonatomic) IBOutlet UITextField *modifiedPasswordTextField;
// 确认新密码
@property (weak, nonatomic) IBOutlet UITextField *verifiedPasswordTextField;
// 确定按钮
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end

@implementation ModifyPasswordViewController
{
    BOOL isOnBeginEditing;
}

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
//    //设置navbar的透明,一起用
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
//    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
//    tabVC.label.hidden = false;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    
    [self addContraintToTopBar];
    
    [self changeMargeWithTextField:self.currentPasswordTextField];
    [self changeMargeWithTextField:self.modifiedPasswordTextField];
    [self changeMargeWithTextField:self.verifiedPasswordTextField];
    
}

-(void)changeMargeWithTextField:(UITextField *)textField
{
    CGRect frame = textField.frame;//f表示你的textField的frame
    frame.size.width = 16;//设置左边距的大小
    UIView *leftview = [[UIView alloc] initWithFrame:frame];
    textField.leftViewMode = UITextFieldViewModeAlways;//设置左边距显示的时机，这个表示一直显示
    textField.leftView = leftview;
}

- (void)addContraintToTopBar {
    // 添加头部约束，无论 TopBar 是否透明，都能正常显示。
    NSLayoutConstraint *constraint;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9) {
        
        constraint = [self.headerView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:20];
    }
    else {
        constraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.topLayoutGuide
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.f
                                                   constant:20];
    }
    constraint.active = YES;
    
    UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame)/3, self.view.frame.size.width , 0.5)];
    lineLabel1.backgroundColor = lineColor;
    [self.headerView addSubview:lineLabel1];
    
    UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame)/3*2, self.view.frame.size.width , 0.5)];
    lineLabel2.backgroundColor = lineColor;
    [self.headerView addSubview:lineLabel2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 确定按钮的点击事件
- (IBAction)commit {
    if([self.modifiedPasswordTextField.text isEqualToString:self.currentPasswordTextField.text]){
        [UIAlertController showAlertWithTitle:@"提示" message:@"新密码不能与原密码相同"];
        return;
    }
    if(![self.modifiedPasswordTextField.text isEqualToString:self.verifiedPasswordTextField.text]){
        [UIAlertController showAlertWithTitle:@"提示" message:@"两次输入密码不相同"];
        return;
    }
    if (![VerifyNumberTool verifyPasswordNumber:self.modifiedPasswordTextField.text]) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入正确的密码格式"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_UpdateUserInfo" bundle:[NSBundle mainBundle]];
    NSString *usercode = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSDictionary *params = @{@"username":usercode,@"password":self.currentPasswordTextField.text,@"newPassword":self.modifiedPasswordTextField.text};
    __weak __typeof(self) weakSelf = self;
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
            NSDictionary *data = result[@"data"];
            NSString *code = data[@"code"];
            if([code isEqualToString:@"1"]){
                NSString *updaterst = data[@"resultctx"][@"updateResult"];
                if ([updaterst isEqualToString:@"true"]) {
                    [weakSelf modifyPWD];
                }else{
                    [UIAlertController showAlertWithTitle:@"提示" message:data[@"resultctx"][@"updateDesc"]?:@"修改失败"];
                }
            }
            else{
                [UIAlertController showAlertWithTitle:@"提示" message:data[@"msg"]?data[@"msg"]:@"修改失败"];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];
    
}

- (void)modifyPWD{
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"modifyPassword" bundle:[NSBundle mainBundle]];
    NSString *usercode = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSDictionary *params = @{@"username":usercode,@"oldPassword":self.currentPasswordTextField.text,@"newPassword":self.modifiedPasswordTextField.text};
    __weak __typeof(self) weakSelf = self;
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
            BOOL success = result[@"success"];
            if(success){
                [UIAlertController showAlertWithTitle:@"提示" message:@"修改成功" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    [weakSelf logout];
                }];
            }else{
                [UIAlertController showAlertWithTitle:@"提示" message:result[@"message"]?result[@"message"]:@"修改失败"];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];
}

// 密码明文切换
- (IBAction)toggleVisiableButton:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    [self.view endEditing:YES];
    
    BOOL visiable = sender.selected;
    self.modifiedPasswordTextField.secureTextEntry = !visiable;
    self.verifiedPasswordTextField.secureTextEntry = !visiable;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - <UITextFieldDelegate>

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    isOnBeginEditing = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL enabled = YES;
    self.commitButton.enabled = enabled;
    isOnBeginEditing = NO;
    if(range.location >=16){
            return NO;
    }

    return YES;
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField == self.currentPasswordTextField) {
        
        [self.modifiedPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.modifiedPasswordTextField) {
    
        [self.verifiedPasswordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

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
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usernameNoEnable"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
                UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [UIApplication sharedApplication].delegate.window.rootViewController = naviController;
            }
        }
    } failure:^(NSError *error) {
        // TODO:
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}


@end
