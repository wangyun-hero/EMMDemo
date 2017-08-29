//
//  EMMDocumentsViewController.m
//  DocumentDemo
//
//  Created by Chenly on 16/6/21.
//  Copyright © 2016年 iUapMobile. All rights reserved.
//

#import "EMMDocsViewController.h"
#import "EMMDocument.h"
#import "EMMDocDetailViewController.h"
#import "EMMApplicationContext.h"
#import "EMMDataAccessor.h"
#import "MBProgressHUD.h"
#import "UIAlertController+EMM.h"
#import "YYModel.h"
#import "UIColor+HexString.h"
#import "UINavigationController+Extension.h"

@interface EMMDocsViewController ()

@end

@implementation EMMDocsViewController

static NSString * const reuseIdentifier = @"emm_document";

- (void)viewDidLoad {
    [super viewDidLoad];
    //去除多余的分割线
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setBackgroundColor:[UIColor emm_colorWithHexString:@"#EFEFF4"]];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear:animated];
    [self getDocuments];
}

- (void)getDocuments {

    if (self.documents) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.offset = CGPointMake(0, -64.f);
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.document" request:@"getDocuments"];
    [dataAccessor sendRequestWithParams:@{ @"username": username } success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            int code =  [result[@"data"][@"code"] intValue];
            if (code == 1) {
                self.documents = [NSArray yy_modelArrayWithClass:[EMMDocument class] json:result[@"data"][@"docs"]];
                [self.tableView reloadData];
            }
            else {
                NSString *message = result[@"data"][@"msg"];
                [UIAlertController showAlertWithTitle:@"登录失败" message:message];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [UIAlertController showAlertWithTitle:@"网络连接失败" message:error.localizedDescription];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.documents.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EMMDocument *document = self.documents[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        CALayer *cellImageLayer = cell.imageView.layer;
        [cellImageLayer setCornerRadius:22];
        [cellImageLayer setMasksToBounds:YES];
    }
    
    cell.textLabel.text = document.title;
    cell.detailTextLabel.text = document.size;
    [cell.detailTextLabel setTextColor:[UIColor emm_colorWithHexString:@"#758795"]];
    cell.imageView.image = document.image;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EMMDocument *document = self.documents[indexPath.row];
    
    EMMDocDetailViewController *detailVC = [[EMMDocDetailViewController alloc] init];
    detailVC.title = document.title;
    detailVC.URLString = document.url;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
