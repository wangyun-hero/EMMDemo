//
//  HGMessageMainViewController.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/18.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGMessageMainViewController.h"
#import "MessageDBHandle.h"
#import "UINavigationController+Extension.h"
#import "MessageDateHandle.h"
#import "MessageModel.h"
#import "MessageDao.h"
#import "HGMessageMainViewCell.h"
#import "UIImageView+WebCache.h"
#import "HGMessageDetailViewController.h"
#import "HGAppDao.h"
#import "HGAppModel.h"
#import "UINavigationBar+UINavigationBar_other.h"
#define MessageMain_Cell @"HGMessageMainViewCell"
#define EXISTWELNOTE @"WelcomeNote"
#define WelcomeNoteAppId @"999"
#define NotificationAppId @"888"

@interface HGMessageMainViewController (){
    NSInteger loginType;//登录类型
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic,strong) NSMutableArray *appIdArray;
@property (nonatomic,strong) NSMutableArray *unReadNumArray;

@end

@implementation HGMessageMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];

    self.messageArray = [NSMutableArray new];
    self.appIdArray = [[NSMutableArray alloc] init];
    self.unReadNumArray = [[NSMutableArray alloc] init];
    [[MessageDBHandle getSharedInstance] initTable];
    // Do any additional setup after loading the view from its nib.
    self.title = @"消息";
    UINib *nib = [UINib nibWithNibName:MessageMain_Cell bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MessageMain_Cell];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessage:) name:@"reloadMessage" object:nil];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    userId = userId.length?userId:@"guest";
    
    BOOL existWelNote = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-%@",userId,EXISTWELNOTE]];
    if(!existWelNote){
        [self setLoaclWelcomeNote];
    }
    [self reloadMessage:nil];
    
    [self.navigationController initNavBarBackBtnWithSystemStyle];
    
}

- (void)setLoaclWelcomeNote{
    // 内置一条消息
    NSString *messageImage = @"noticeIcon.png";
    NSString *userId = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    userId = userId.length?userId:@"guest";
    NSString *hgWelcomeMsg = @"";
    loginType = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentLoginType"];
    switch (loginType) {
        case 0:
            hgWelcomeMsg = @"中国电子口岸数据中心希望利用最新的信息技术和自有信息资源，为进出口企业提供更多、更好的服务，决定开发推广电子口岸移动APP，该应用是海关外网预录入系 统和电子口岸执法系统的延伸，包含录入、申报、查询、消息订阅四类集成业务功能和多项业务服务，方便企业和个人随时随地进行口岸业务的办理及咨询。\n可在APP和PC端进行注册，用户名密码方式登录，分为个人和企业用户，可使用APP全部功能，但根据用户类型可使不同应用；\n使用范围：持有移动终端的人均可使用，但分匿名用户、注册用户和蓝牙key用户。\n注册用户可在APP和PC端进行注册，用户名密码方式登录，分为个人和企业用户，可使用APP全部功能，但根据用户类型使用不同应用。";
            break;
        case 1:
            hgWelcomeMsg = @"中国电子口岸数据中心希望利用最新的信息技术和自有信息资源，为进出口企业提供更多、更好的服务，决定开发推广电子口岸移动APP，该应用是海关外网预录入系 统和电子口岸执法系统的延伸，包含录入、申报、查询、消息订阅四类集成业务功能和多项业务服务，方便企业和个人随时随地进行口岸业务的办理及咨询。\n使用范围：持有移动终端的人均可使用，但分匿名用户、注册用户和蓝牙key用户。\n匿名用户无需注册，直接使用APP，主要可接收通知、查看在线帮助功能。\n如需使用更多功能，请使用注册用户或蓝牙KEY用户登录。";
            break;
        case 2:
            hgWelcomeMsg = @"中国电子口岸数据中心希望利用最新的信息技术和自有信息资源，为进出口企业提供更多、更好的服务，决定开发推广电子口岸移动APP，该应用是海关外网预录入系 统和电子口岸执法系统的延伸，包含录入、申报、查询、消息订阅四类集成业务功能和多项业务服务，方便企业和个人随时随地进行口岸业务的办理及咨询。\n使用范围：持有移动终端的人均可使用，但分匿名用户、注册用户和蓝牙key用户。\n蓝牙KEY用户可使用APP全部功能。";
            break;
            
        default:
            break;
    }
    NSString *messageInfo = [NSString stringWithFormat:@"欢迎使用%@移动门户\n%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],hgWelcomeMsg];
    NSDictionary *userInfo = @{@"messageName":@"消息提醒",@"messageInfo":messageInfo,@"messageDate":[MessageDateHandle getCurrentDate],@"messageImage":messageImage,@"appId":WelcomeNoteAppId,@"isRead":@1,@"userId":userId};
    
    MessageModel *model = [[MessageModel alloc] init];
    [model parseDic:userInfo];
    [[MessageDao sharedInstance] addMessage:model];
    NSString *key =[NSString stringWithFormat:@"%@-%@",userId,EXISTWELNOTE];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadMessage:nil];
    
}

- (void)reloadTabbarBadgeValue{
    NSInteger badgeValue = [[MessageDao sharedInstance] getUnReadMessageCount];
    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)badgeValue];
    if(badgeValue == 0){
        self.tabBarItem.badgeValue = nil;
    }
}

- (void)reloadMessage:(NSNotification *)notif{
    [self.appIdArray removeAllObjects];
    MessageDao *dao = [MessageDao sharedInstance];
    NSMutableArray *messages = [dao getMessages];
    for (MessageModel *model in messages) {
        [self.appIdArray addObject:model.appId];
    }
    [self.messageArray removeAllObjects];
    [self.unReadNumArray removeAllObjects];
    [self messageClassify];
    [self.tableView reloadData];
    [self reloadTabbarBadgeValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 67.5;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    HGMessageMainViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    HGMessageDetailViewController *viewController = [[HGMessageDetailViewController alloc] init];
    viewController.messages = self.messageArray[indexPath.row];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    NSMutableArray *messages = self.messageArray[indexPath.row];
    for (MessageModel *rowModel in messages) {
        rowModel.isRead = 0;
        [[MessageDao sharedInstance] updateMessage:rowModel];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HGMessageMainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageMain_Cell];
    
    NSMutableArray *messages = self.messageArray[indexPath.row];
    MessageModel *model = [messages lastObject];
    cell.timeLabel.text = [MessageDateHandle mainShowTime:model.messageDate];
    if([model.appId isEqualToString:WelcomeNoteAppId] || [model.appId isEqualToString:NotificationAppId]){
        cell.titleLabel.text = model.messageName;
    }
    else{
        HGAppModel *appModel = [[HGAppDao sharedInstance] getApp:model.appId];
        cell.titleLabel.text = appModel.title;
    }
    
    cell.detailLabel.text = model.messageInfo;
    NSString *badge = self.unReadNumArray[indexPath.row];
    [cell setBadge:badge];
    if ([model.messageImage hasPrefix:@"http"]) {
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:model.messageImage]];
    }else{
        [cell.headImageView setImage:[UIImage imageNamed:model.messageImage]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSArray *models = self.messageArray[indexPath.row];
        for(MessageModel *model in models){
            [[MessageDao sharedInstance] delMessage:model];
        }
        [self reloadMessage:nil];
        
    }];
    
    return @[deleteAction];
}


//数组去重复
-(NSMutableArray *)removeRepeatElement:(NSMutableArray *)dataArray{
    NSMutableArray *listAry = [[NSMutableArray alloc]init];
    for (NSString *str in dataArray) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }
    return  listAry;
}

//消息归类
-(void)messageClassify{
    NSArray *messages = [[MessageDao sharedInstance] getMessages];
    //去除重复appid的元素
    self.appIdArray = [self removeRepeatElement:self.appIdArray];
    for (NSString *appid in self.appIdArray) {
        NSInteger unreadnum = [[MessageDao sharedInstance] getUnReadMessageCountWithAppId:appid];
        [self.unReadNumArray addObject:[NSString stringWithFormat:@"%ld",(long)unreadnum]];
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (MessageModel *model in messages) {
            if ([appid isEqualToString:model.appId]) {
                [temp addObject:model];
            }
        }
        if(temp.count){
            [self.messageArray addObject:temp];
        }
    }
}
@end

