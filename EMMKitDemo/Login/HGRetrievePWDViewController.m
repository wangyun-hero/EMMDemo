//
//  HGFindPWDViewController.m
//  EMMKitDemo
//
//  Created by zm on 16/8/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGRetrievePWDViewController.h"
#import "VerifyNumberTool.h"
#import "UIAlertController+EMM.h"
#import "HGHTTPDataAccessor.h"
#import "MBProgressHUD.h"
#import "HGResetPWDViewController.h"
#import "UINavigationBar+UINavigationBar_other.h"
#import "UINavigationController+Extension.h"
@interface HGRetrievePWDViewController (){
    BOOL isValidTeleNum;
    BOOL securityCodeBtnEnable;
}

@property (weak, nonatomic) IBOutlet UIView *wholeView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *securityTextField;
@property (weak, nonatomic) IBOutlet UIView *phoneView;
@property (weak, nonatomic) IBOutlet UIButton *retrievePWDBtn;
@property (weak, nonatomic) IBOutlet UIView *securityView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic) NSInteger time;
@property (nonatomic,copy) NSString *token;

@end

@implementation HGRetrievePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
    [self layoutView];
    self.navigationController.navigationBarHidden = NO;
    //self.title = @"找回密码";
    self.nextBtn.userInteractionEnabled = NO;
    self.nextBtn.layer.borderWidth = 1;
    self.nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    
    //[self adapteriOS7];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.time = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar getnavBarColor:[UIColor clearColor]];
    
    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //设置navbar的透明,一起用
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    //    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
    //    tabVC.label.hidden = YES;
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
    self.phoneView.layer.cornerRadius = 8.0f;
    self.phoneView.layer.masksToBounds = YES;
    self.phoneView.layer.borderWidth = 0.5;
    self.phoneView.layer.borderColor = [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f] CGColor];
    
    self.securityView.layer.cornerRadius = 8.0f;
    self.securityView.layer.masksToBounds = YES;
    self.securityView.layer.borderWidth = 0.5;
    self.securityView.layer.borderColor =  [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f] CGColor];
    
//    self.retrievePWDBtn.layer.cornerRadius = 8.0f;
//    self.retrievePWDBtn.layer.masksToBounds = YES;
    
    self.nextBtn.layer.cornerRadius = 8.0f;
    self.nextBtn.layer.masksToBounds = YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.securityTextField){
        if(range.location>=6)
            return NO;
    }
    return YES;
}

- (void)textFieldDidChanged:(NSNotification *)notif{
    UITextField *textField = notif.object;
    if(textField == self.phoneTextField){
        [self changePhoneTextField:textField.text];
    }
    
    if(self.phoneTextField.text.length && self.securityTextField.text.length){
        self.nextBtn.userInteractionEnabled = YES;
    }
    else{
        self.nextBtn.userInteractionEnabled = NO;
    }
    
    [self changeNextBtnTitleColor:self.nextBtn.userInteractionEnabled];
}

- (void)changeNextBtnTitleColor:(BOOL)isVisible{
    if(isVisible){
        [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        [self.nextBtn setTitleColor:[UIColor colorWithRed:249/255.0 green:166/255.0 blue:157/255.0 alpha:1.0f] forState:UIControlStateNormal];
    }
}

- (void)changePhoneTextField:(NSString *)text{
    isValidTeleNum = [VerifyNumberTool verifyPhoneNumber:text];
    if(!isValidTeleNum){
        self.phoneView.layer.cornerRadius = 8.0f;
        self.phoneView.layer.masksToBounds = YES;
        self.phoneView.layer.borderWidth = 0.5;
        self.phoneView.layer.borderColor = [[UIColor redColor] CGColor];
    }
    else{
        self.phoneView.layer.borderColor = [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f] CGColor];
    }
}

- (void)onTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1ull*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
//        NSLog(@"%ld",(long)self.time);
        if(self.time <= 0){
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.retrievePWDBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                [self.retrievePWDBtn setBackgroundColor:[UIColor colorWithRed:32/255.0 green:186/255.0 blue:248/255.0 alpha:1.0]];
                self.retrievePWDBtn.userInteractionEnabled = YES;
            });
        }
        else{
            NSInteger seconds = (long)self.time % 90;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.retrievePWDBtn setTitle:[NSString stringWithFormat:@"重新发送(%.2ld)",(long)seconds] forState:UIControlStateNormal];
//                [self.retrievePWDBtn setBackgroundColor:[UIColor colorWithRed:32/255.0 green:186/255.0 blue:248/255.0 alpha:1.0]];
                [self.retrievePWDBtn setBackgroundColor:[UIColor grayColor]];
                self.retrievePWDBtn.userInteractionEnabled = NO;
            });
            
            self.time--;
        }
        
    });
    dispatch_resume(timer);
}

#pragma mark - click
- (IBAction)clickedSecurityCode:(id)sender {
    [self tapHandle:nil];
    if(!isValidTeleNum){
        [UIAlertController showAlertWithTitle:@"提示"  message:@"请输入有效的手机号码" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.phoneTextField becomeFirstResponder];
        }];
        return;
    }
   
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_GetToken" bundle:[NSBundle mainBundle]];
    NSDictionary *params = @{@"usercode":self.phoneTextField.text};
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
            NSDictionary *data = result[@"data"];
            NSString *code = data[@"code"];
            if([code isEqualToString:@"1"]){
                NSDictionary *resultctxDic = data[@"resultctx"];
                NSString *issucceed = resultctxDic[@"executeResult"];
                if ([issucceed isEqualToString:@"true"]) {
                    // 成功
                    [UIAlertController showAlertWithTitle:@"提示"  message:@"发送成功" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                        [self.securityTextField becomeFirstResponder];
                    }];
                    self.token = resultctxDic[@"token"];
                    self.time = (long)89;
                    [self onTimer];
                    
                }else{
                    NSString *msg = resultctxDic[@"executeDesc"];
                    [UIAlertController showAlertWithTitle:@"提示"  message:msg cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    }];
                }
            }
            else{
                [UIAlertController showAlertWithTitle:@"提示" message:@"发送失败"];
                self.time = 0;
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:@"发送失败"];
        self.time = 0;
    }];
}


- (IBAction)clickedRetrievePWD:(id)sender {
    [self tapHandle:nil];
    if(!isValidTeleNum){
        [UIAlertController showAlertWithTitle:@"提示"  message:@"请输入有效的手机号码" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.phoneTextField becomeFirstResponder];
        }];
        return;
    }
    if (self.token.length == 0 || !self.token) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"请重新获取验证码"];
        return;
    }

     __weak __typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_VerifyCode" bundle:[NSBundle mainBundle]];
    NSDictionary *params = @{@"usercode":self.phoneTextField.text,@"randomcode":self.securityTextField.text,@"token":self.token};
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(result){
            NSDictionary *data = result[@"data"];
            NSString *code = data[@"code"];
            if([code isEqualToString:@"1"]){
                NSDictionary *resultctxDic = data[@"resultctx"];
                NSString *issucceed = resultctxDic[@"verifyCodeResult"];
                if ([issucceed isEqualToString:@"true"]) {
                    // 成功
                    HGResetPWDViewController *reset = [[HGResetPWDViewController alloc] init];
                    reset.phoneNum = self.phoneTextField.text;
                    reset.token = self.token;
                    [weakSelf.navigationController pushViewController:reset animated:YES];
                }else{
                    NSString *msg = @"请重新获取验证码";
                    [UIAlertController showAlertWithTitle:@"提示"  message:msg cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                        self.securityTextField.text = @"";
                    }];
                }
            }
            else{
                self.time = 0;
                [UIAlertController showAlertWithTitle:@"提示"  message:@"验证码错误"cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    self.securityTextField.text = @"";
                    [self.securityTextField becomeFirstResponder];
                }];
            }
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.time = 0;
        [UIAlertController showAlertWithTitle:@"提示"  message:@"验证码错误"cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            self.securityTextField.text = @"";
            [self.securityTextField becomeFirstResponder];
        }];
    }];
}

@end
