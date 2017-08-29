//
//  ModifyPasswordViewController.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMPasswordViewController.h"
#import "EMMDataAccessor.h"
#import "EMMApplicationContext.h"
#import "EMMMediator.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h"
#import "UIColor+HexString.h"

@interface EMMPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *modifiedPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verifiedPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end

@implementation EMMPasswordViewController
{
    BOOL isOnBeginEditing;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    
    [self addContraintToTopBar];
    [self layoutView];
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
}

- (void)layoutView{
    
    UILabel *label1= [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame)/3, CGRectGetWidth(self.view.frame), 0.5)];
    [label1 setBackgroundColor:[UIColor colorWithRed:128/255.0 green:127/255.0 blue:127/255.0 alpha:0.3f]];
    [self.headerView addSubview:label1];
    
    UILabel *label2= [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame)/3*2, CGRectGetWidth(self.view.frame), 0.5)];
    [label2 setBackgroundColor:[UIColor colorWithRed:128/255.0 green:127/255.0 blue:127/255.0 alpha:0.3f]];
    [self.headerView addSubview:label2];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)commit {
    
    [self.view endEditing:YES];
    if (![self.modifiedPasswordTextField.text isEqualToString:self.verifiedPasswordTextField.text]) {
        [UIAlertController showAlertWithTitle:@"系统提示" message:@"两次输入密码不一致。"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];    
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSString *oldPassword = self.currentPasswordTextField.text;
    NSString *newPassword = self.modifiedPasswordTextField.text;
    NSDictionary *params = @{
                             @"username": username,
                             @"oldPassword": oldPassword,
                             @"newPassword": newPassword
                             };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"modifyPassword"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        NSString *errorMessage;
        if (result) {
            if ([result[@"success"] boolValue]) {
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"系统提示" message:@"密码修改成功，请重新登录。" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    [EMMMediator segueToLoginViewController];
                }];
                [alert addAction:action];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                errorMessage = result[@"message"];
            }
        }
        if (errorMessage) {
            [UIAlertController showAlertWithTitle:@"系统提示" message:errorMessage];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}


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
    // 三个文本输入框字符长度都必须大于等于6时，提交按钮才可用。
    BOOL enabled = YES;
    NSArray *textFields = @[self.currentPasswordTextField, self.modifiedPasswordTextField, self.verifiedPasswordTextField];
    for (UITextField *tf in textFields) {
        
        if (tf == textField) {
            if (isOnBeginEditing) {
                if (string.length < 6) {
                    enabled = NO;
                    break;
                }
            }
            else if (textField.text.length - range.length + string.length < 6) {
                enabled = NO;
                break;
            }
        }
        else {
            if (tf.text.length < 6) {
                enabled = NO;
                break;
            }
        }
    }
    self.commitButton.enabled = enabled;
    isOnBeginEditing = NO;
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

@end
