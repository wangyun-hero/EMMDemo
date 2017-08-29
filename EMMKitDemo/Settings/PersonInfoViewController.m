//
//  PersonInfoViewController.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/17.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "EMMPersonInfoCell.h"
#import "EMMPersonInfo.h"
#import "GVUserDefaults+Properties.h"
//#import <EMMTabBarController.h>
static NSString * const kReuseIdentifier = @"EMMPersonInfoCell";

@interface PersonInfoViewController ()

@end

@implementation PersonInfoViewController

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    EMMTabBarController *tabVC = (EMMTabBarController *)self.navigationController.tabBarController;
//    tabVC.label.hidden = false;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if(section == 0){
//        return 1;
//    }
//    else if (section == 1){
//        return 2;
//    }
//    return 1;
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMMPersonInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
    if(indexPath.row == 0){
        cell.titleLabel.text = @"姓名";
        cell.detailLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginUserName"];
        
    }
    
    else if (indexPath.row == 1) {
        cell.titleLabel.text = @"电话";
        NSString *mobileString = WYUserDefault.USER_MOBNUM;
        cell.detailLabel.text = mobileString.length?mobileString:@"  ";
    }
    else if (indexPath.row == 2) {
        cell.titleLabel.text = @"邮箱";
        cell.detailLabel.text = self.personInfo.email.length?self.personInfo.email:@" ";
    }else
    {
        cell.titleLabel.text = @"用户类型";
        NSString *typeString = WYUserDefault.typeString;
        cell.detailLabel.text =  typeString.length?typeString:@"  ";
    }
    return cell;
}


@end
