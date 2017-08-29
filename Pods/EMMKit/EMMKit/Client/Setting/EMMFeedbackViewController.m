//
//  FeedbackViewController.m
//  EMMKitDemo
//
//  Created by zm on 16/7/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMFeedbackViewController.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h"
#import "EMMApplicationContext.h"
#import "UIColor+HexString.h"
//#import <EMMTabBarController.h>
@interface EMMFeedbackViewController ()<UITextViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextView *questionTextView;
@property (weak, nonatomic) IBOutlet UILabel *questionPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *connectTextView;
@property (weak, nonatomic) IBOutlet UIButton *submitButtom;

@end

@implementation EMMFeedbackViewController

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
//    tabVC.label.hidden = false;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"问题反馈";
    
    [self addContraintToTopBar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)addContraintToTopBar {
    // 添加头部约束，无论 TopBar 是否透明，都能正常显示。
    NSLayoutConstraint *constraint;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9) {
        
        constraint = [self.headerView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor constant:0];
    }
    else {
        constraint = [NSLayoutConstraint constraintWithItem:self.headerView
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self.topLayoutGuide
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.f
                                                   constant:0];
    }
    constraint.active = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidChanged:(NSNotification *)notif{
    if([self.questionTextView isFirstResponder]){
        if(self.questionTextView.text.length != 0){
            self.questionPlaceholderLabel.hidden = YES;
            [self.submitButtom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else{
            self.questionPlaceholderLabel.hidden = NO;
            [self.submitButtom setTitleColor:[UIColor emm_colorWithHexString:@"#66ccff"] forState:UIControlStateNormal];
        }
    }
    
    if([self.connectTextView isFirstResponder]){
        if(self.connectTextView.text.length != 0){
            self.connectPlaceholderLabel.hidden = YES;
        }else{
            self.connectPlaceholderLabel.hidden = NO;
        }
        
    }
    
    self.submitButtom.enabled = self.questionTextView.text.length;
}

- (void)tapHandle:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    
}

- (IBAction)submitBtn:(id)sender {
    if(!self.questionTextView.text.length){
        [UIAlertController showAlertWithTitle:@"提示" message:@"请输入要反馈的问题"];
        return;
    }
    
    NSDictionary *params = @{
                             @"usercode": [[EMMApplicationContext defaultContext] objectForKey:@"username"],
                             @"detail": self.questionTextView.text,
                             @"contacts": self.connectTextView.text,
                             };
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"feedback"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"" message:@"非常感谢您的反馈，我们会尽快处理！" cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];
}

@end

