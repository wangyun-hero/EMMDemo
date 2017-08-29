//
//  MessageMainViewController.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "MessageMainViewController.h"
#import "MessageMainTableViewCell.h"
#import "MessageModel.h"
#import "MessageDao.h"
#import "MessageDBHandle.h"
#import "UIImageView+WebCache.h"
#import "MessageDetailViewController.h"
#import "EMMDataAccessor.h"
#import "UINavigationController+Extension.h"
#import "MessageDateHandle.h"

#define MessageMain_Cell @"MessageMainTableViewCell"
#define EXISTWELNOTE @"WelcomeNote"
#define EXISTDOMENOTE @"DomeNote"

@interface MessageMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *messageArray;
@property (nonatomic,strong) NSMutableArray *appIdArray;
@property (nonatomic,strong) NSMutableArray *unReadNumArray;

@end

@implementation MessageMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.messageArray = [NSMutableArray new];
    self.appIdArray = [[NSMutableArray alloc] init];
    self.unReadNumArray = [[NSMutableArray alloc] init];
    [[MessageDBHandle getSharedInstance] initTable];
    // Do any additional setup after loading the view from its nib.
    self.title = @"消息";
    UINib *nib = [UINib nibWithNibName:MessageMain_Cell bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MessageMain_Cell];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMessage:) name:@"reloadMessage" object:nil];
    
    BOOL existWelNote = [[NSUserDefaults standardUserDefaults] boolForKey:EXISTWELNOTE];
    if(!existWelNote){
        [self setLoaclWelcomeNote];
    }
    
    if ([[EMMDataAccessor getDefaultBundle] isEqualToString:kEMMDataAccessorBundleDemo]) {
        BOOL existDomeNote = [[NSUserDefaults standardUserDefaults] boolForKey:EXISTDOMENOTE];
        if(!existDomeNote){
            [self getMessageFromDemo];
        }
    }else{
        [self reloadMessage:nil];
    }
    
    [self.navigationController initNavBarBackBtnWithSystemStyle];
    
}

- (void)setLoaclWelcomeNote{
    // 内置一条消息
    NSString *messageImage = @"http://mdemo.yonyou.com/maupload/img/gzyx1.png";
    NSString *messageInfo = [NSString stringWithFormat:@"欢迎使用%@移动门户",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSDictionary *userInfo = @{@"messageName":@"消息提醒",@"messageInfo":messageInfo,@"messageDate":[MessageDateHandle getCurrentDate],@"messageImage":messageImage,@"appId":@"999",@"isRead":@1};
    
    MessageModel *model = [[MessageModel alloc] init];
    [model parseDic:userInfo];
    [[MessageDao sharedInstance] addMessage:model];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:EXISTWELNOTE];
}

-(void)getMessageFromDemo{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"emm_demo_results" ofType:@"bundle"]];
    NSString *filePath = [bundle pathForResource:@"com.yyuap.emm.message.getMessage" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *arr = dic[@"messages"];
    for (NSDictionary *dictemp in arr) {
        MessageModel *model = [[MessageModel alloc] init];
#warning - 调试用 model.userId = @"guest";
        model.userId = @"guest";
        [model parseDic:dictemp];
        [[MessageDao sharedInstance] addMessage:model];
        [self.appIdArray addObject:model.appId];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:EXISTDOMENOTE];
    [self messageClassify];
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageDetailViewController *viewController = [[MessageDetailViewController alloc] init];
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
    MessageMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageMain_Cell];
    
    NSMutableArray *messages = self.messageArray[indexPath.row];
    MessageModel *model = [messages firstObject];
    cell.timeLabel.text = [MessageDateHandle conversionFromDate:model.messageDate];
    cell.titleLabel.text = model.messageName;
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

#pragma mark - UISearchBar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    searchBar.text = @"";
}

//数组去重复
-(NSMutableArray *)removeRepeatElement:(NSMutableArray *)dataArray{
    NSMutableArray *listAry = [[NSMutableArray alloc]init];
    for (id data in dataArray) {
        if (![listAry containsObject:data]) {
            [listAry addObject:data];
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
