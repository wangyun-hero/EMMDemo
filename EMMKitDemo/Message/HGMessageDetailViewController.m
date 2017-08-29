//
//  HGMessageDetailViewController.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGMessageDetailViewController.h"
#import "HGMessageDetailViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"
#import "UINavigationController+Extension.h"
#import "MessageDateHandle.h"
#import "HGAppModel.h"
#import "HGAppDao.h"
#import "SUMWindowViewController.h"
#import "EMMW3FolderManager.h"
#import "UIAlertController+EMM.h"

#define WelcomeNoteAppId @"999"
#define NotificationAppId @"888"

#define MessageDetail_Cell @"HGMessageDetailViewCell"

@interface HGMessageDetailViewController ()<HGMessageDetailViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HGMessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *nib = [UINib nibWithNibName:MessageDetail_Cell bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MessageDetail_Cell];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    MessageModel *model = [self.messages lastObject];
    HGAppModel *appModel = [[HGAppDao sharedInstance] getApp:model.appId];
    self.title = appModel.title?appModel.title:model.messageName;
    
    [self.tableView setBackgroundColor:[UIColor emm_colorWithHexString:@"#efeff4"]];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageModel *model = self.messages[indexPath.row];
    if([model.appId isEqualToString:WelcomeNoteAppId] || [model.appId isEqualToString:NotificationAppId]){
        return [HGMessageDetailViewCell heightForCellWithData:self.messages[indexPath.row] isTimeShow:YES cellStyle:CellStyleNoSelect];
    }
    else{
        return [HGMessageDetailViewCell heightForCellWithData:self.messages[indexPath.row] isTimeShow:YES cellStyle:CellStyleSelect];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HGMessageDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageDetail_Cell];
    cell.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    MessageModel *model = self.messages[indexPath.row];
    if([model.appId isEqualToString:WelcomeNoteAppId]){
        cell.cellStyle = CellStyleURL | CellStyleSelect;
    }
    else if( [model.appId isEqualToString:NotificationAppId]){
        cell.cellStyle = CellStyleNoSelect;
    }
    else{
        cell.cellStyle = CellStyleSelect;
    }
    cell.titleLabel.text = model.messageName;
    cell.Infolabel.text = model.messageInfo;
    cell.timeLabel.text = [MessageDateHandle detailShowTime:model.messageDate];
    cell.messageModel = model;
    [cell reloadStyle];
    return cell;
}


- (void)didSelectedChatWithMessage:(MessageModel *)model{
    NSLog(@"点击chat");
    if([model.appId isEqualToString:WelcomeNoteAppId]){
        // 欢迎消息
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"www.baidu.com"]];
    }
    else{
        HGAppModel *appModel = [[HGAppDao sharedInstance] getApp:model.appId];
        BOOL isNeedDownload = [[HGAppDao sharedInstance] isNeedDownload:model.appId];
        if(isNeedDownload){
            NSString *message = [NSString stringWithFormat:@"未安装%@应用，请下载安装",appModel.title];
            [UIAlertController showAlertWithTitle:@"提示" message:message];
            return;
        }
        UIViewController *summer = [self getSummerViewController:appModel];
        
        [self.navigationController pushViewController:summer animated:YES];
    }
}

- (UIViewController *)getSummerViewController:(HGAppModel *)appModel{
    
    SUMWindowViewController *webViewController = [[SUMWindowViewController alloc] init];
    if(appModel.webZipUrl.length){
        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        username = username.length ? username:@"guest";
        NSString *www = [[EMMW3FolderManager sharedInstance] absoluteW3FolderForKey:[NSString stringWithFormat:@"%@-%@",username,appModel.applicationId]];
        webViewController.wwwFolderName =  [www substringToIndex:[www length] - 1];
    }
    else{
        webViewController.wwwFolderName = @"";
        webViewController.startPage = appModel.url;
    }
    return webViewController;
}


@end
