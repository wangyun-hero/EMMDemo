//
//  HGRegisterViewController.m
//  EMMKitDemo
//
//  Created by zm on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGRegisterViewController.h"
#import "VerifyNumberTool.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h"
#import "EMMApplicationContext.h"
#import "HGBandCardViewController.h"
#import "UINavigationBar+UINavigationBar_other.h"
//设备全屏宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define lineColor [UIColor colorWithRed:128/255.0 green:127/255.0 blue:127/255.0 alpha:0.3f]

static const CGFloat IDTypePickerViewHeight = 186;
static const CGFloat bottomViewInitHeight = 150;

@interface HGRegisterViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
{
    NSArray *IDTypeArray;
    BOOL isValidTeleNum;
    BOOL isValidCardNum;
    BOOL isValidPassNum;
    BOOL isAvailablePhoneNum; //验证手机号是否可被注册
    BOOL isValidUserName;
    NSString *registerVerifyCode;// 验证码
    NSString *userType;//用户类型
    BOOL isShowKeyBoard;
    BOOL isregisterClick;
    
    float _keyboardHeight;
    
    NSInteger time;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumText;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UILabel *rePasswordLabel;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordText;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *IDnumberText;
@property (weak, nonatomic) IBOutlet UILabel *IDnumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *IDTypeText;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIView *IDView;
@property (weak, nonatomic) IBOutlet UIView *IDNumView;
@property (weak, nonatomic) IBOutlet UIButton *showPickerBtn;
@property (weak, nonatomic) IBOutlet UIButton *pwdVisible;
@property (weak, nonatomic) IBOutlet UITextField *userTypeTextField;
@property (weak, nonatomic) IBOutlet UIView *companyTypeView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIButton *verifyNumBtn;
@property (weak, nonatomic) IBOutlet UITextField *verifyNumText;

@property (nonatomic, strong) UIPickerView *IDTypePickerView;
@property (nonatomic,strong) UIToolbar *pickerToolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTrailingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verifyBtnWidthLayoutConstraint;

@property (nonatomic,strong) UILabel *IDTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *IDTypeView;
@property (weak, nonatomic) IBOutlet UITextField *organizationText;
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UITextField *creditText;
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;
@property (weak, nonatomic) IBOutlet UITextField *companyText;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;




@end

@implementation HGRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"注册";
    userType = @"0";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    
    IDTypeArray = @[@"港澳身份证",@"护照",@"港澳通行证",@"身份证"];
    [self.view addSubview:self.IDTypePickerView];
    [self.IDTypePickerView setHidden:YES];
    
    [self layoutView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    [self adapteriOS7];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
    self.navigationController.navigationBarHidden = NO;
    [self.IDTypePickerView addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear: animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.IDTypePickerView removeObserver:self forKeyPath:@"hidden"];
}

#pragma mark - Customer Method
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
    self.topView.layer.cornerRadius = 8.0f;
    self.topView.layer.masksToBounds = YES;
    
    NSArray *topSubView = self.topView.subviews;
    //布局时判断..如果有line线条,先移除,再添加
    for (UIView *lineview in topSubView) {
        if ([lineview isKindOfClass:[UILabel class]]) {
            [lineview removeFromSuperview];
        }
    }
    
    for(int i = 1; i<topSubView.count;i++){
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50*i, kScreenWidth , 0.5)];
        [lineLabel setBackgroundColor:lineColor];
        [self.topView addSubview:lineLabel];
    }
    
    
    self.bottomView.layer.cornerRadius = 8.0f;
    self.bottomView.layer.masksToBounds = YES;
    
    NSArray *bottomSubView = self.bottomView.subviews;
    
    for (UIView *lineview in bottomSubView) {
        if ([lineview isKindOfClass:[UILabel class]]) {
            [lineview removeFromSuperview];
        }
    }
    
    for(int i = 1; i<bottomSubView.count;i++){
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50*i, kScreenWidth , 0.5)];
        [lineLabel setBackgroundColor:lineColor];
        [self.bottomView addSubview:lineLabel];
    }
    
    self.registerButton.layer.masksToBounds = YES;
    self.registerButton.layer.cornerRadius = 8.0f;
    
    self.clearBtn.layer.masksToBounds = YES;
    self.clearBtn.layer.cornerRadius = 8.0f;
    
    self.verifyNumBtn.layer.masksToBounds = YES;
    self.verifyNumBtn.layer.cornerRadius = 5.0f;
//    [self.verifyNumBtn.layer setBorderWidth:1.0f];
//    [self.verifyNumBtn.layer setBorderColor:[UIColor colorWithRed:246/255.0 green:101/255.0 blue:72/255.0 alpha:1.0f].CGColor];
    
    self.viewTrailingLayoutConstraint.constant = kScreenWidth/375*20;
    self.verifyBtnWidthLayoutConstraint.constant = kScreenWidth/375*90;
    self.organizationText.secureTextEntry = NO;
    self.creditText.secureTextEntry = NO;
}

- (UIPickerView *)IDTypePickerView{
    if(_IDTypePickerView == nil){
        
        _IDTypePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, IDTypePickerViewHeight)];
        _IDTypePickerView.backgroundColor = [UIColor whiteColor];
        _IDTypePickerView.delegate = self;
        _IDTypePickerView.dataSource = self;
        [_IDTypePickerView selectRow:2 inComponent:0 animated:YES];
        
        _pickerToolBar = [[UIToolbar alloc] init];
        _pickerToolBar.barTintColor=[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1];
        _pickerToolBar.frame=CGRectMake(0, CGRectGetMinY(_IDTypePickerView.frame) - 38, kScreenWidth, 38);
        UIBarButtonItem *doneBtn=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(doneClick)];
        [doneBtn setTintColor:[UIColor whiteColor]];
        UIBarButtonItem *spaceBtn=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _pickerToolBar.items=@[spaceBtn,doneBtn];
        [self.view addSubview:_pickerToolBar];
        
        
        self.IDTypeText.inputView = _IDTypePickerView;
        self.IDTypeText.inputAccessoryView = _pickerToolBar;
    }
    return _IDTypePickerView;
}

- (void)textFieldDidChanged:(NSNotification *)notif{
    UITextField *textField = notif.object;
    if (textField == self.nameText) {
        isValidUserName = [VerifyNumberTool verifyUserName:textField.text];
    }
    if(textField == self.IDnumberText){
        [self changeIDTextField:textField.text];
    }
    if (textField == self.passwordText) {
        isValidPassNum = [VerifyNumberTool verifyPasswordNumber:textField.text];
    }
    
}


- (void)changeIDTextField:(NSString *)text{
    
    if([self.IDTypeText.text isEqualToString:IDTypeArray[3]]){
        // 身份证
        isValidCardNum = [VerifyNumberTool verifyIdentityNumber:text];
    }else{
        NSString *number = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        isValidCardNum = (number.length<=64);
    }
    if (!isValidCardNum) {
        [self.IDnumberLabel setTextColor:[UIColor redColor]];
    }else{
        [self.IDnumberLabel setTextColor:[UIColor blackColor]];
    }
    if ([self.IDnumberText.text isEqualToString:@""]) {
        [self.IDnumberLabel setTextColor:[UIColor blackColor]];
    }
    
}




#pragma mark - KeyBoard
- (void)keyboardWillShow:(NSNotification *)info
{
    CGRect keyboardBounds = [[[info userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float keyboardHeight =  keyboardBounds.size.height;
    
    
    
    if(!isShowKeyBoard){
        _keyboardHeight = keyboardHeight;
        self.view.frame = CGRectMake(0,64,CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - keyboardHeight );
        isShowKeyBoard = YES;
    }
    
    
}

- (void)keyboardWillHide:(NSNotification *)info
{
    if(isShowKeyBoard){
    CGRect keyboardBounds = [[[info userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    float keyboardHeight =  keyboardBounds.size.height;
        if(keyboardHeight != _keyboardHeight)
            keyboardHeight = _keyboardHeight;
        
    self.view.frame = CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + keyboardHeight );
        isShowKeyBoard = NO;
    }
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return IDTypeArray.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return IDTypeArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component{
    self.IDTypeText.text = IDTypeArray[row];
    if (![self.IDTypeText.text isEqualToString:@"身份证"]) {
        [self.IDnumberLabel setTextColor:[UIColor blackColor]];
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField == self.IDTypeText){
        [self.view endEditing:YES];
        self.IDTypePickerView.hidden = !self.IDTypePickerView.hidden;
        return NO;
    }
    if (textField == self.userTypeTextField) {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __block typeof(self) weakself = self;
        if ([textField.text isEqualToString:@"个人用户"]) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"企业用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weakself.userTypeTextField.text = @"企业用户";
                userType = @"2";
                 [weakself layoutView];
                weakself.bottomViewHeightLayoutConstraint.constant= 350;
                weakself.companyTypeView.hidden = NO;
               
            }];
            [alertcontroller addAction:action];
        }else{
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"个人用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                weakself.userTypeTextField.text = @"个人用户";
                userType = @"0";
                weakself.companyTypeView.hidden = YES;
                [weakself layoutView];
                weakself.bottomViewHeightLayoutConstraint.constant= 200;
            }];
            [alertcontroller addAction:action];
        }
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertcontroller addAction:actionCancel];
        [self presentViewController:alertcontroller animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.phoneNumText){
        [self.verifyNumText becomeFirstResponder];
    }
    if(textField == self.verifyNumText){
        [self.passwordText becomeFirstResponder];
    }
    if(textField == self.passwordText){
        [self.rePasswordText becomeFirstResponder];
    }
    if(textField == self.rePasswordText){
        [self.nameText becomeFirstResponder];
    }
    if(textField == self.nameText){
        [self.IDnumberText becomeFirstResponder];
    }
    if(textField == self.IDnumberText){
        [self.IDnumberText resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSString *hudText = @"";
    if(textField == self.phoneNumText){
        isValidTeleNum = [VerifyNumberTool verifyPhoneNumber:self.phoneNumText.text];
        if(isValidTeleNum){
            [self.phoneNumLabel setTextColor:[UIColor blackColor]];
        }
        else{
            [self.phoneNumLabel setTextColor:[UIColor redColor]];
            hudText = @"请输入有效的手机号码";
        }
        
    }
    if(textField == self.passwordText){
        isValidPassNum = [VerifyNumberTool verifyPasswordNumber:textField.text];
        if(isValidPassNum){
            [self.passwordLabel setTextColor:[UIColor blackColor]];
        }
        else{
            [self.passwordLabel setTextColor:[UIColor redColor]];
            hudText = @"请输入有效的密码";
        }
    }
    if(textField == self.rePasswordText){
        if([self.rePasswordText.text isEqualToString:self.passwordText.text]){
            [self.rePasswordLabel setTextColor:[UIColor blackColor]];
            [self.passwordLabel setTextColor:[UIColor blackColor]];
        }
        else{
            [self.rePasswordLabel setTextColor:[UIColor redColor]];
            [self.passwordLabel setTextColor:[UIColor redColor]];
            hudText = @"两次密码输入不一致";
        }
    }
    
    if(textField == self.nameText){
         isValidUserName = [VerifyNumberTool verifyUserName:textField.text];
        if(isValidUserName){
            [self.nameLabel setTextColor:[UIColor blackColor]];
        }
        else{
            [self.nameLabel setTextColor:[UIColor redColor]];
            hudText = @"姓名只能包含汉字和英文";
        }
    }
    
    if(textField == self.organizationText){
        if ([VerifyNumberTool verifyOrganizationNumber:textField.text]){
            [self.organizationLabel setTextColor:[UIColor blackColor]];
        }
        else{
            [self.organizationLabel setTextColor:[UIColor redColor]];
            hudText = @"请输入有效组织机构代码";
        }
    }
    
    if(textField == self.creditText){
        if ([VerifyNumberTool verifyCreditNumber:textField.text]){
            [self.creditLabel setTextColor:[UIColor blackColor]];
        }
        else{
            [self.creditLabel setTextColor:[UIColor redColor]];
            hudText = @"请输入有效统一社会信用代码";
        }
    }
    
    
    
    
    if(hudText.length){
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = hudText;
        [hud hideAnimated:YES afterDelay:1.0f];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.verifyNumText){
        if(range.location>=6)
        return NO;
    }
    if((textField == self.passwordText) || (textField == self.rePasswordText)){
        if(range.location >=16)
            return NO;
    }
        return YES;
}


// 验证手机号是否可注册
- (void)verifyPhoneNum{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *param = @{@"userId":self.phoneNumText.text};
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_verifyPhoneNum" bundle:[NSBundle mainBundle]];
    [dataAccessor sendRequestWithParams:param success:^(id result) {
        
        NSDictionary *dic = result[@"data"];
        NSString *code = dic[@"code"];
        if([code isEqualToString:@"1"]){
            NSDictionary *resultctx = dic[@"resultctx"];
            NSString * isSuccessed = resultctx[@"queryResult"];
            if ([isSuccessed isEqualToString:@"true"]) {
                NSString *Exist = resultctx[@"userExistFlag"];
                if([Exist isEqualToString:@"true"]){
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [UIAlertController showAlertWithTitle:@"提示" message:@"该手机号已被注册"];
                    isAvailablePhoneNum = NO;
                }else{
                    NSLog(@"手机号验证通过，可以注册");
                    isAvailablePhoneNum = YES;
                    //获取验证码
                    [self getVerifyNum];
                }
            }
            else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [UIAlertController showAlertWithTitle:@"提示" message:resultctx[@"queryDesc"]];
                isAvailablePhoneNum = NO;
            }
        }
        else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [UIAlertController showAlertWithTitle:@"提示" message:dic[@"msg"]];
            isAvailablePhoneNum = NO;
        }
    } failure:^(NSError *error) {
        NSLog(@"验证失败");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        isAvailablePhoneNum = NO;
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];
    
}


#pragma mark - btnClick
//pickerview 完成按钮
-(void)doneClick{
    self.IDTypePickerView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, IDTypePickerViewHeight);
    _pickerToolBar.frame = CGRectMake(0, CGRectGetMinY(self.IDTypePickerView.frame)-38, kScreenWidth, 38);
    [self.showPickerBtn setImage:[UIImage imageNamed:@"register_down.png"] forState:UIControlStateNormal];
    self.IDTypePickerView.hidden = YES;
}
// 密码的明文与密文切换
- (IBAction)btnPwdVisible:(UIButton *)sender {
    self.passwordText.secureTextEntry = !self.passwordText.secureTextEntry;
    self.rePasswordText.secureTextEntry = !self.rePasswordText.secureTextEntry;
    if (sender.tag == 0) {
        [self.pwdVisible setImage:[UIImage imageNamed:@"login_pwd_visible.png"] forState:UIControlStateNormal];
        self.pwdVisible.tag = 1;
        return;
    }
    if (sender.tag == 1) {
        [self.pwdVisible setImage:[UIImage imageNamed:@"login_pwd_invisible.png"] forState:UIControlStateNormal];
        self.pwdVisible.tag = 0;
        return;
    }
}


- (IBAction)clickedRegisterBtn:(id)sender {
    [self tapHandle:nil];
    
//    [self registerEMM];
//    [UIAlertController showAlertWithTitle:@"注册成功" message:@"是否绑定IC卡?" cancelButtonTitle:@"取消" otherButtonTitle:@"是" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
//        if (buttonIndex == 0) {
//            [self.navigationController popViewControllerAnimated:YES];
//        }else if(buttonIndex == 1){
//            HGBandCardViewController *vc = [[HGBandCardViewController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }];
//    return;
    isValidTeleNum = [VerifyNumberTool verifyPhoneNumber:self.phoneNumText.text];
    if(!isValidTeleNum){
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效的手机号码" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.phoneNumText becomeFirstResponder];
        }];
        return;
    }
    
    
     if((self.verifyNumText.text) &&![registerVerifyCode isEqualToString:self.verifyNumText.text]){
        [UIAlertController showAlertWithTitle:@"提示" message:@"验证码不正确" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.verifyNumText becomeFirstResponder];
        }];
        return;
    }
    
    if(!isAvailablePhoneNum){
        [UIAlertController showAlertWithTitle:@"提示" message:@"该手机号不能被注册" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.phoneNumText becomeFirstResponder];
        }];
        return;
    }
    
    if (!isValidPassNum) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效的密码" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            self.passwordText.text = @"";
            self.rePasswordText.text = @"";
            [self.passwordText becomeFirstResponder];
        }];
        return;
    }
    

    if (! [self.passwordText.text isEqual:self.rePasswordText.text]) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"两次输入密码不一致" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.rePasswordText becomeFirstResponder];
        }];
        return;
    }

    if (!isValidUserName) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"姓名只能包含汉字和英文" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            self.nameText.text = @"";
            [self.passwordText becomeFirstResponder];
        }];
        return;
    }else if(self.nameText.text.length == 0){
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入姓名" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.nameText becomeFirstResponder];
        }];
        return;
    }else if (self.nameText.text.length >20){
        [UIAlertController showAlertWithTitle:@"提示" message:@"姓名长度不能超过20个字符" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.nameText becomeFirstResponder];
        }];
        return;
    }
    //如果是企业用户,需要校验组织机构代码,统一社会信用代码,工作单位
    if ([self.userTypeTextField.text isEqualToString:@"企业用户"])
    {
        if ([self.organizationText.text isEqualToString:@""] && [self.creditText.text isEqualToString:@""])
        {
            [UIAlertController showAlertWithTitle:@"提示" message:@"组织机构代码、统一社会信用代码至少填一项"];
            return;
        }else{
            if (![self.organizationText.text isEqualToString:@""]) {
                if (![VerifyNumberTool verifyOrganizationNumber:self.organizationText.text]) {
                    [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效组织机构代码"];
                    return;
                }
            }
            if (![self.creditText.text isEqualToString:@""]) {
                if (![VerifyNumberTool verifyCreditNumber:self.creditText.text]) {
                    [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效统一社会信用代码"];
                    return;
                }
            }
        }
        
        if ([self.companyText.text isEqualToString:@""]) {
            [UIAlertController showAlertWithTitle:@"提示" message:@"企业名称不能为空"];
            return;
        }

        if (self.companyText.text.length > 256) {
            [UIAlertController showAlertWithTitle:@"提示" message:@"企业名称不能超过512个字符"];
            return;
        }
        
    }
    
    if(!isValidCardNum){
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效的证件号码" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.IDnumberText becomeFirstResponder];
        }];
        return;
        
    }

    [self registerMA];
}


- (void)registerMA{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *cardtype;
    if ([self.IDTypeText.text isEqualToString:@"身份证"]) {
        cardtype = @"1";
    }else if ([self.IDTypeText.text isEqualToString:@"港澳通行证"]) {
        cardtype = @"2";
    }else if ([self.IDTypeText.text isEqualToString:@"护照"]) {
        cardtype = @"3";
    }else if ([self.IDTypeText.text isEqualToString:@"港澳身份证"]) {
        cardtype = @"4";
    }
    NSDictionary *params = @{
                             @"phone": self.phoneNumText.text,
                             @"password": self.passwordText.text,
                             @"name": self.nameText.text,
                             @"cardtype": cardtype,
                             @"cardid": self.IDnumberText.text,
                             @"userTypecd": userType,
                             @"orgIstcd" : self.organizationText.text,
                             @"etpsUNSocialCrecd":self.creditText.text,
                             @"etpsNm" : self.companyText.text
                             };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_Register" bundle:[NSBundle mainBundle]];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        NSDictionary *dic = result[@"data"];
        NSString * isSuccessed = dic[@"resultctx"][@"registerResult"];
        if ([isSuccessed isEqualToString:@"true"]) {
            [self registerEMM];
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *message =dic[@"resultctx"][@"registerDesc"];
            [UIAlertController showAlertWithTitle:@"注册失败" message:message];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //
    }];
}


- (void)registerEMM{
    NSDictionary *params = @{
                             @"phone": self.phoneNumText.text,
                             @"password": self.passwordText.text,
                             @"name": self.nameText.text,
                             @"cardtype": self.IDTypeText.text,
                             @"cardid": self.IDnumberText.text
                             };
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"registerEMM" bundle:[NSBundle mainBundle]];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            int code =  [result[@"data"][@"code"] intValue];
            if (code == 1) {
                [UIAlertController showAlertWithTitle:@"提示" message:@"注册成功" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
//                [UIAlertController showAlertWithTitle:@"注册成功" message:@"是否绑定蓝牙KEY?" cancelButtonTitle:@"取消" otherButtonTitle:@"是" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
//                    if (buttonIndex == 0) {
//                        [self.navigationController popViewControllerAnimated:YES];
//                    }else if(buttonIndex == 1){
//                        HGBandCardViewController *vc = [[HGBandCardViewController alloc] init];
//                        vc.etpsNm = self.companyText.text;
//                        vc.userId = self.phoneNumText.text;
//                        vc.userName = self.nameText.text;
//                        vc.userPw = self.passwordText.text;
//                        vc.orgIstcdFromRegister = self.organizationText.text;
//                        vc.socialCrecdFromRegister = self.creditText.text;
//                        [self.navigationController pushViewController:vc animated:YES];
//                    }
//                }];
            }
            else {
                NSString *message = result[@"data"][@"msg"];
                [UIAlertController showAlertWithTitle:@"注册失败" message:message];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"注册失败" message:error.localizedDescription];
    }];
}

/**
 *  清空
 *
 *  @param sender
 */
- (IBAction)clickedClearAllBtn:(id)sender {
    self.phoneNumText.text = @"";
    self.passwordText.text = @"";
    self.rePasswordText.text = @"";
    self.nameText.text = @"";
    self.IDnumberText.text = @"";
    self.IDTypeText.text = @"身份证";
    self.verifyNumText.text = @"";
    self.organizationText.text = @"";
    self.creditText.text = @"";
    self.companyText.text = @"";
}

- (IBAction)clickedShowPickerView:(id)sender {
    [self.view endEditing:YES];
    self.IDTypePickerView.hidden = !self.IDTypePickerView.hidden;
}
- (IBAction)clickedGetVerifyNum:(id)sender {
    if(self.phoneNumText.text.length == 0){
        return;
    }
    
    isValidTeleNum = [VerifyNumberTool verifyPhoneNumber:self.phoneNumText.text];
    if(!isValidTeleNum){
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入有效的手机号码" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            [self.phoneNumText becomeFirstResponder];
        }];
        return;
    }else{
        isregisterClick = NO;
        [self verifyPhoneNum];
    }
}

-(void)getVerifyNum{
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_registerVerifyCode" bundle:[NSBundle mainBundle]];
    NSDictionary *param = @{@"destMobileNumber":self.phoneNumText.text};
    [dataAccessor sendRequestWithParams:param success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *dic = result[@"data"];
        if([dic[@"code"] isEqualToString:@"1"]){
            NSDictionary *resultctx = dic[@"resultctx"];
            NSString *submitResult = resultctx[@"submitSmsExactResult"];
            if([submitResult isEqualToString:@"0"]){
                registerVerifyCode = resultctx[@"verifyCode"];
                NSLog(@"注册验证码：%@",registerVerifyCode);
                // 成功
                [UIAlertController showAlertWithTitle:@"提示"  message:@"发送成功" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    [self.verifyNumText becomeFirstResponder];
                }];
                time = (long)90;
                [self onTimer];
            }
            else{
                [UIAlertController showAlertWithTitle:@"提示" message:resultctx[@"errorMsg"]];
                time = 0;
            }
        }
        else{
            [UIAlertController showAlertWithTitle:@"提示" message:dic[@"msg"]];
            time = 0;
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        time = 0;
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];
}

- (void)tapHandle:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    
}

#pragma mark - 计时器
- (void)onTimer{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, globalQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC,  0);
    dispatch_source_set_event_handler(timer, ^{
        if(time <=0){
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.verifyNumBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                self.verifyNumBtn.userInteractionEnabled = YES;
                [self.verifyNumBtn.layer setBorderWidth:1.0f];
                [self.verifyNumBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
                [self.verifyNumBtn.layer setBorderColor:[UIColor colorWithRed:246/255.0 green:101/255.0 blue:72/255.0 alpha:1.0f].CGColor];
                [self.verifyNumBtn setBackgroundColor:[UIColor whiteColor]];
                [self.verifyNumBtn setTitleColor:[UIColor colorWithRed:246/255.0 green:101/255.0 blue:72/255.0 alpha:1.0f] forState:UIControlStateNormal];
            });
            registerVerifyCode = @"";//计时结束,验证码置为无效.
            
        }
        else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.verifyNumBtn setTitle:[NSString stringWithFormat:@"%lds后\n重新发送",(long)time] forState:UIControlStateNormal];
                [self.verifyNumBtn.titleLabel setNumberOfLines:2];
                [self.verifyNumBtn.titleLabel setFont:[UIFont systemFontOfSize:10]];
                [self. verifyNumBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [self.verifyNumBtn setTitleColor:[UIColor colorWithRed:181/255.0 green:181/255.0 blue:182/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.verifyNumBtn setBackgroundColor:[UIColor colorWithRed:181/255.0 green:181/255.0 blue:182/255.0 alpha:0.3]];
                self.verifyNumBtn.layer.borderWidth = 0;
                self.verifyNumBtn.userInteractionEnabled = NO;
            });
            
            time--;
        }
    });
    dispatch_resume(timer);
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == self.IDTypePickerView){
        UIPickerView *pickerView = object;
        if(pickerView.hidden){
            [self.showPickerBtn setImage:[UIImage imageNamed:@"register_down.png"] forState:UIControlStateNormal];
            self.IDTypePickerView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, IDTypePickerViewHeight);
            _pickerToolBar.frame = CGRectMake(0, CGRectGetMinY(self.IDTypePickerView.frame)-38, kScreenWidth, 38);
        }
        else{
            [self.showPickerBtn setImage:[UIImage imageNamed:@"register_up.png"] forState:UIControlStateNormal];
            self.IDTypePickerView.frame = CGRectMake(0, kScreenHeight - IDTypePickerViewHeight, kScreenWidth, IDTypePickerViewHeight);
            _pickerToolBar.frame = CGRectMake(0, CGRectGetMinY(self.IDTypePickerView.frame)-38, kScreenWidth, 38);
        }
    }
}

@end
