//
//  HGResetPWDViewController.m
//  EMMKitDemo
//
//  Created by zm on 16/8/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGResetPWDViewController.h"
#import "UIAlertController+EMM.h"
#import "HGHTTPDataAccessor.h"
#import "MBProgressHUD.h"
#import "VerifyNumberTool.h"
#import "UINavigationBar+UINavigationBar_other.h"
@interface HGResetPWDViewController ()<UIAlertViewDelegate>{
    BOOL isValidPassNum;
}
@property (weak, nonatomic) IBOutlet UITextField *setPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *resetPasswordTextField;
@property (weak, nonatomic) IBOutlet UIView *setPwdView;
@property (weak, nonatomic) IBOutlet UIView *resetPwdView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UIButton *secureBtn;

@end

@implementation HGResetPWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self layoutView];
    self.title = @"设置密码";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    [self.navigationController.navigationBar getnavBarColor:[UIColor clearColor]];
    
    self.navigationController.navigationBar.translucent = YES;
    //设置navbar的透明,一起用
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    
    //[self adapteriOS7];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapHandle:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    
}

- (void)adapteriOS7
{
    if ([[[UIDevice currentDevice] systemVersion]                                                                                                     floatValue] >= 7.0) {
        
        //边缘要延伸的方向
        self.edgesForExtendedLayout = UIRectEdgeBottom;
        //当Bar使用了不透明图片时，视图是否延伸至Bar所在区域
        self.extendedLayoutIncludesOpaqueBars = YES;
        //scrollview是否自调整
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        //去除半透明
        self.navigationController.navigationBar.translucent = NO;
        self.tabBarController.tabBar.translucent = NO;
    }
}

- (void)layoutView{
    self.setPwdView.layer.cornerRadius = 8.0f;
    self.setPwdView.layer.masksToBounds = YES;
    self.setPwdView.layer.borderWidth = 0.5;
    self.setPwdView.layer.borderColor = [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f] CGColor];
    
    self.resetPwdView.layer.cornerRadius = 8.0f;
    self.resetPwdView.layer.masksToBounds = YES;
    self.resetPwdView.layer.borderWidth = 0.5;
    self.resetPwdView.layer.borderColor =  [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f] CGColor];
    self.confirmBtn.layer.borderWidth = 1;
    self.confirmBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.confirmBtn.layer.cornerRadius = 8.0f;
    self.confirmBtn.layer.masksToBounds = YES;
    
}
- (IBAction)showSecurePWD:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.view endEditing:YES];
    
    BOOL visiable = sender.selected;
    if (visiable) {
        [self.secureBtn setImage:[UIImage imageNamed:@"login_pwd_visible.png"] forState:UIControlStateNormal];
    }else{
        [self.secureBtn setImage:[UIImage imageNamed:@"login_pwd_invisible.png"] forState:UIControlStateNormal];
    }
    self.setPasswordTextField.secureTextEntry = !visiable;
    self.resetPasswordTextField.secureTextEntry = !visiable;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if((textField == self.setPasswordTextField) || (textField == self.resetPasswordTextField)){
        if(range.location >=16)
            return NO;
    }
    return YES;
}

- (void)textFieldDidChanged:(NSNotification *)notif{
    UITextField *textField = notif.object;
    if (textField == self.setPasswordTextField) {
        [self changePasswordTextField:textField.text];
    }
    if(self.setPasswordTextField.text.length && self.resetPasswordTextField.text.length){
        self.confirmBtn.userInteractionEnabled = YES;
    }
    else{
        self.confirmBtn.userInteractionEnabled = NO;
    }
    [self changeConfimeBtnTitleColor:self.confirmBtn.userInteractionEnabled];
}

- (void)changePasswordTextField:(NSString *)text{
    isValidPassNum = [VerifyNumberTool verifyPasswordNumber:text];
    if(!isValidPassNum){
        self.setPwdView.layer.cornerRadius = 8.0f;
        self.setPwdView.layer.masksToBounds = YES;
        self.setPwdView.layer.borderWidth = 0.5;
        self.setPwdView.layer.borderColor = [[UIColor redColor] CGColor];
    }
    else{
        self.setPwdView.layer.borderColor = [[UIColor whiteColor] CGColor];
    }
    
}

- (void)changeConfimeBtnTitleColor:(BOOL)isVisible{
    if(isVisible){
        [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        [self.confirmBtn setTitleColor:[UIColor colorWithRed:249/255.0 green:166/255.0 blue:157/255.0 alpha:1.0f] forState:UIControlStateNormal];
    }
}


- (IBAction)clickedConfirm:(id)sender {
    if (!isValidPassNum) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效的密码"];
        self.setPasswordTextField.text = @"";
        self.resetPasswordTextField.text = @"";
        return;
    }
    if (![self.setPasswordTextField.text isEqualToString:self.resetPasswordTextField.text]) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"两次输入的密码不一致"];
        return;
    }
    __weak __typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_ResetPassword" bundle:[NSBundle mainBundle]];
    NSDictionary *params = @{@"phone":self.phoneNum,@"password":self.resetPasswordTextField.text,@"token":self.token};
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
            NSDictionary *data = result[@"data"];
            NSString *code = data[@"code"];
            if([code isEqualToString:@"1"]){
                NSDictionary *resultctxDic = data[@"resultctx"];
                NSString *result = resultctxDic[@"modifyResult"];
                if ([result isEqualToString:@"true"]) {
                    // 成功
                    [weakSelf resetPWD];
                }else{
                    NSString *errorDes = resultctxDic[@"modifyDesc"];
                    [UIAlertController showAlertWithTitle:@"提示" message:errorDes];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
            else{
                [UIAlertController showAlertWithTitle:@"提示" message:@"重置密码失败"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }

    } failure:^(NSError *error) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:@"重置密码失败"];
    }];
}

- (void)resetPWD{
      __weak __typeof(self) weakSelf = self;
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"resetPWD" bundle:[NSBundle mainBundle]];
    NSDictionary *params = @{@"usercode":self.phoneNum,@"pwd":self.resetPasswordTextField.text};
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
            NSDictionary *data = result[@"data"];
            NSString *code = data[@"code"];
            if([code isEqualToString:@"1"]){
                NSDictionary *resultctxDic = data[@"resultctx"];
                NSString *flag = [NSString stringWithFormat:@"%@",resultctxDic[@"flag"]];
                if ([flag isEqualToString:@"1"]) {
                    // 成功
                    [UIAlertController showAlertWithTitle:@"提示" message:@"重置密码成功" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                    }];
                }else{
                    NSString *errorDes = resultctxDic[@"desc"];
                    [UIAlertController showAlertWithTitle:@"提示" message:errorDes];
                }
            }
            else{
                [UIAlertController showAlertWithTitle:@"提示" message:@"重置密码失败"];
            }
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:@"重置密码失败"];
    }];

}

@end
