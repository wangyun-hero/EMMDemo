//
//  OnlineHelpViewController.m
//  EMMCustomerService
//
//  Created by zm on 16/6/30.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "OnlineHelpViewController.h"
#import "UIColor+HexString.h"
#import "EMMDataAccessor.h"
#import "CustomerServiceModel.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h" 
#import "SUMWindowViewController.h"
#import "CustomerServiceWebViewController.h"
#import <UINavigationController+Extension.h>
@interface OnlineHelpViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)  UIImageView *imageView;
@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tableArray;

@end

@implementation OnlineHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
    // Do any additional setup after loading the view from its nib.
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) style:UITableViewStylePlain];
    [self.tableView setBackgroundColor:[UIColor emm_colorWithHexString:@"#efeff4"]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    self.tableArray = [NSMutableArray new];
    
    //[self requestData];
    
}

- (void)requestData{
//
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.tableArray removeAllObjects];
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    username = username.length ?username:@"guest";
    NSDictionary *params = @{@"username":username,@"type":self.modelKey};
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_onlineHelpList" bundle:[NSBundle mainBundle]];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        NSDictionary *dic = result[@"data"];
        NSString *code = dic[@"code"];
        if([code isEqualToString:@"1"]){
            NSDictionary *resultctx = dic[@"resultctx"];
            NSArray *list = resultctx[@"list"];
            for(NSDictionary *models in list){
                OnlineHelpModel *model = [[OnlineHelpModel alloc] init];
                model.title = models[@"title"];
                model.desc = models[@"description"];
                model.url = models[@"url"];
                
                [self.tableArray addObject:model];
            }
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        if(error){
            [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
        }

    }];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    OnlineHelpModel *model = self.tableArray[indexPath.row];
    cell.textLabel.text = model.title;
//    cell.detailTextLabel.text = model.desc;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    OnlineHelpModel *model = self.tableArray[indexPath.row];
    CustomerServiceWebViewController *webViewController = [[CustomerServiceWebViewController alloc] init];
    webViewController.url = model.url;
    [webViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
