//
//  HGAuthIntroduceController.m
//  EMMKitDemo
//
//  Created by 王云 on 2017/7/13.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "HGAuthIntroduceController.h"
#import "UINavigationBar+UINavigationBar_other.h"
#import "GVUserDefaults+Properties.h"
@interface HGAuthIntroduceController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contntLabel;

@end

@implementation HGAuthIntroduceController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar getnavBarColor:[UIColor clearColor]];
    
    
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    //设置navbar的透明,一起用
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init] ];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    //    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
    //    tabVC.label.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"权限说明";
    
//    UIFont *font = [UIFont fontWithName:@"FZLTHK--GBK1-0" size:16];
//    self.nameLabel.font = font;
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    // 行间距设置为30
    [paragraphStyle  setLineSpacing:5];
    
    if ([self.labelString isEqualToString:@"游客"]) {
        self.nameLabel.text = @"匿名用户,您好";
        self.contntLabel.text = @"    欢迎使用电子口岸APP，您可查询系统通知消息，查看在线帮助，部分应用的查询功能。如需使用更多功能，请成为我们的注册用户!";
    }else
    {
        NSString *typeString = WYUserDefault.typeString;
        if ([typeString isEqualToString:@"绑卡企业"]) {
            self.nameLabel.text = @"企业绑卡用户,您好";
            self.contntLabel.text = @"    欢迎使用电子口岸APP，您可使用APP的全部功能。";
        }else if ([typeString isEqualToString:@"未绑卡企业"])
        {
            self.nameLabel.text = @"未绑卡企业用户,您好";
            self.contntLabel.text = @"    欢迎使用电子口岸APP，您可查询系统通知消息，查看在线帮助，部分应用的查询功能。如需使用更多功能，请在PC端，访问http：//nra.chinaport.gov.cn/nra地址绑定IC卡！";
        }else if ([typeString isEqualToString:@"个人用户"])
        {
            self.nameLabel.text = @"个人用户,您好";
            self.contntLabel.text = @"    欢迎使用电子口岸APP，您可查询系统通知消息，查看在线帮助，跨境个人消费信息查询及公路舱单确报申报等功能。";
        }else
        {
            NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
            if (type == 1) {
                self.nameLabel.text = @"匿名用户,您好";
                self.contntLabel.text = @"    欢迎使用电子口岸APP，您可查询系统通知消息，查看在线帮助，部分应用的查询功能。如需使用更多功能，请成为我们的注册用户!";
            }
            
        }
    }
    
    NSString  *testString = self.contntLabel.text;
    NSMutableAttributedString  *setString = [[NSMutableAttributedString alloc] initWithString:testString];
    [setString  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [testString length])];
    
    // 设置Label要显示的text
    [self.contntLabel  setAttributedText:setString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
