//
//  HGAppCenterViewController.m
//  EMMKitDemo
//
//  Created by zm on 16/7/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGAppCenterViewController.h"
#import "AppCenterTableViewCell.h"
#import "SUMWindowViewController.h"
#import "EMMApplicationContext.h"
#import "AppCenterAssistiveTouch.h"
#import "AssistiveTouchItemModel.h"
#import "AppDelegate.h"
#import "HGAppDao.h"
#import "EMMDataAccessor.h"
#import "MBProgressHUD.h"
#import "EMMW3FolderManager.h"
#import "UIAlertController+EMM.h"
#import "UIColor+HexString.h"
#import "AppCenterCollectionViewCell.h"
#import "EMMMediator.h"
#import "AppCenterSearchTableViewCell.h"
#import "ViewControllersMemoryHandle.h"
#import "AppCenterDetailViewController.h"
#import "UINavigationBar+UINavigationBar_other.h"
#import <Masonry.h>
#import "UINavigationController+Extension.h"
#import "AppCenterTableViewCell.h"
//设备全屏宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define ReusableCellIdentifier @"AppCenterTableViewCell"
#define SearchCellIdentifier @"AppCenterSearchTableViewCell"
#define backItemTag 5555

static NSInteger HeightForTableRow = 55.0f;
//static NSInteger HeightForSeatchTableRow = 155.0f;


@interface HGAppCenterViewController ()<UITableViewDelegate,UITableViewDataSource,AppCenterTableViewCellDelegate,AppCenterAssistiveTouchDelegate,UISearchControllerDelegate,UISearchResultsUpdating,UISearchBarDelegate,UIViewControllerPreviewingDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *appClassArray; //分类数组
@property (nonatomic, strong) NSMutableArray *searchApps;

@property (nonatomic, strong) AppCenterAssistiveTouch *assistiveTouch;
@property (nonatomic, strong) NSMutableArray *assistiveTouchModels;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableViewController *searchTableViewController;
//@property(nonatomic,copy) NSString *jumpID;
@property (nonatomic, strong) AppCenterCollectionViewCell *waitUpdateCell;
@property(nonatomic,strong) UIView *titView;
@property(nonatomic,strong) AppCenterTableViewCell *cell;
@end

@implementation HGAppCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.jumpID = @"1";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
    
    [self.navigationController initNavBarBackBtnWithSystemStyle];
    UINib *nib = [UINib nibWithNibName:ReusableCellIdentifier bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:ReusableCellIdentifier];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 自动计算行高
//    self.tableView.estimatedRowHeight = 180;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.searchTableViewController.tableView.estimatedRowHeight = 44;
//    self.searchTableViewController.tableView.rowHeight = UITableViewAutomaticDimension;
    [self createSearchController];
    
    self.appClassArray = [NSMutableArray new];
    self.searchApps = [NSMutableArray new];
    self.navigationController.navigationBarHidden = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self requestData];
    
    
}

//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    NSLog(@"将要滑动");
//    self.jumpID = @"1";
//}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    if ([self isOverTwoHours] == true) {
        [self logoutAction];
        return;
    }
//    if (self.cell) {
//        [UIView animateWithDuration:0.1 animations:^{
//            self.cell.collectionView.contentOffset = CGPointMake(self.cell.collectionView.contentOffset.x, self.cell.collectionView.contentOffset.y +20);
//        }];
//    }
    
    
    [self showAssistiveTouch];
    BOOL close = [[NSUserDefaults standardUserDefaults] boolForKey:@"closeAssistiveTouch"];
    if((!close) && self.assistiveTouchModels.count != 0){
        self.assistiveTouch.hidden = NO;
    }
    else{
        self.assistiveTouch.hidden = YES;
    }
    
    [self adapteriOS7];
    [self.navigationController setNavigationBarHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.assistiveTouch.currentKey = nil;
    
    BOOL updateCell = [[NSUserDefaults standardUserDefaults] boolForKey:@"updateCell"];
    if(updateCell)
    {
        HGAppModel *model = [[HGAppDao sharedInstance] getApp:self.waitUpdateCell.appId];
        [self downloadWWW:model updateCell:self.waitUpdateCell];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"updateCell"];
        //[self.tableView reloadData];
    }else
    {
        if(self.waitUpdateCell.circleProgressView.circleProgressStyle != CircleProgressStyleDownloading){
            // 下载完成更新
            [self.tableView reloadData];
        }
    }
    
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    
    if(!self.assistiveTouch.hidden){
        // 切换在别的tabbar 隐藏assistiveTouch
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UITabBarController *tabber = (UITabBarController *)delegate.window.rootViewController;
        UINavigationController *nav = [tabber selectedViewController];
        if(![[nav topViewController] isKindOfClass:[SUMViewController class]]){
            self.assistiveTouch.hidden = YES;
        }
        else{
            self.assistiveTouch.hidden = NO;
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createSearchController{
    // 重要！ searchbar隐藏导航栏必备
    // 当搜索框弹出时是否覆盖当前的视图控制器
    self.definesPresentationContext = YES;
    
    // 搜索结果控制器
    self.searchTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    self.searchTableViewController.tableView.delegate = self;
    self.searchTableViewController.tableView.dataSource = self;
    self.searchTableViewController.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.searchTableViewController.tableView.backgroundColor = [UIColor whiteColor];
    self.searchTableViewController.hidesBottomBarWhenPushed = YES;
    
    // 搜索框控制器
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchTableViewController];
    //设置背景不透明
    self.searchController.searchBar.translucent = NO;
    // 代理
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    // 修改取消字体的颜色
    UIButton *cancleBtn = [self.searchController.searchBar valueForKey:@"cancelButton"];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 去除searchbar上下两条黑线及设置背景
    self.searchController.searchBar.barTintColor = [UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1];
//    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    UIImageView *barImageView = [[[self.searchController.searchBar.subviews firstObject] subviews] firstObject];
    barImageView.layer.borderColor = [UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1].CGColor;
    barImageView.layer.borderWidth = 1;
    
//    self.searchController.searchBar.barTintColor = [UIColor emm_colorWithHexString:@"#e6e6e6"];
//    self.searchController.searchBar.layer.borderWidth = 1;
//    self.searchController.searchBar.layer.borderColor = [[UIColor emm_colorWithHexString:@"#e0e0e0"] CGColor];
    self.searchController.searchResultsUpdater = self;
//    self.searchController.hidesBottomBarWhenPushed = YES;
//    self.searchController.view.backgroundColor = [UIColor whiteColor];
    
    
    self.searchController.searchBar.placeholder = @"请输入要查询的关键字";
    [self.searchController.searchBar sizeToFit];
    //搜索时是否隐藏导航条
    self.searchController.hidesNavigationBarDuringPresentation = false;
    //能否选中搜索到的结果
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    UITextField *searchField = [_searchController.searchBar valueForKey:@"searchField"];
    searchField.layer.cornerRadius = 10;
    searchField.textAlignment = NSTextAlignmentLeft;
    
    NSInteger width = [UIScreen mainScreen].bounds.size.width - 30;
    UIView *titView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 40)];
    titView.backgroundColor = [UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1];
    self.titView = titView;
    [titView addSubview:self.searchController.searchBar];
    [self.searchController.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(titView);
       
    }];
    
//    self.searchController.searchBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
    self.navigationItem.titleView = titView;
    UINib *nib = [UINib nibWithNibName:SearchCellIdentifier bundle:nil];
    [self.searchTableViewController.tableView registerNib:nib forCellReuseIdentifier:SearchCellIdentifier];
    
    self.searchTableViewController.tableView.tableFooterView = [[UIView alloc] init];
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


- (void)showAssistiveTouch{
    // 如果不存在,就创建
    if(!self.assistiveTouch){
        self.assistiveTouch = [[AppCenterAssistiveTouch alloc] initWithFrame:CGRectMake(2, 200, 60, 60)];
        self.assistiveTouch.delegate = self;
        self.assistiveTouchModels = [NSMutableArray new];
        self.assistiveTouch.assistiveTouchItemArray = self.assistiveTouchModels;
        
    }
}


/**
 发起网络请求应用
 */
- (void)requestData{
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.application" request:@"getApplications"];
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSDictionary *params = @{@"username":username};
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *data = result[@"data"];
        if([data[@"code"] isEqualToString:@"1"]){
            [self.appClassArray removeAllObjects];
            
            NSArray *arrayTemp = data[@"apps"];
            NSMutableArray *requestArray = [NSMutableArray new];
            for(NSDictionary *dicTemp in arrayTemp){
                HGAppModel *model = [[HGAppModel alloc] initWithDic:dicTemp];
                model.www_size = @"";
                // 存应用数据库
                [[HGAppDao sharedInstance] addApp:model];
                [requestArray addObject:model];
                
                NSDictionary *class = @{@"appgroupcode":model.appgroupcode,@"appgroupname":model.appgroupname};
                BOOL existence = NO;
                for(NSDictionary *dic in self.appClassArray){
                    if([dic[@"appgroupcode"] isEqualToString:model.appgroupcode]){
                        existence = YES;
                        break;
                    }
                }
                if(!existence){
                    [self.appClassArray addObject:class];
                }
            }
            
            [self deleteAppFromDBArray:[[HGAppDao sharedInstance] getApps] withRequestArray:requestArray];
        }
        else{
            NSString *message = data[@"msg"];
            NSLog(@"获取应用error-%@",message);
        }
        
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSLog(@"appCenter:--%@",error.localizedDescription);
    }];
}



/**
 删除多余的应用
 
 @param DBArray 本地数据
 @param requestArray 请求数据
 */
- (void)deleteAppFromDBArray:(NSArray *)DBArray withRequestArray:(NSArray *)requestArray{
    if(DBArray.count > requestArray.count){
        for(HGAppModel *DBModel in DBArray){
            BOOL isExist = NO;
            for(HGAppModel *requestModel in requestArray){
                if([DBModel.applicationId isEqualToString:requestModel.applicationId]){
                    isExist = YES;
                    break;
                }
            }
            if(isExist == NO){
                [[HGAppDao sharedInstance] deleteApp:DBModel.applicationId];
            }
        }
    }
}


#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
//    self.searchTableViewController.edgesForExtendedLayout = UIRectEdgeNone;
    searchController.searchBar.showsCancelButton = YES;
    UIView * view = [searchController.searchBar.subviews objectAtIndex:0];
    for (UIView *subView in view.subviews) {
        
        if ([subView isKindOfClass:[UIButton class]]) {
            
            UIButton *bar = (UIButton *)subView;
            
            [bar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [bar setTitle:@"取消" forState:UIControlStateNormal];
            
        }
        
    }
    [self.tabBarController.tabBar setHidden:YES];
    NSString *searchText = self.searchController.searchBar.text;
    [self.searchApps removeAllObjects];
    if(searchText.length){
        NSArray *array = [[HGAppDao sharedInstance] searchApps:@"title" value:searchText];
        [self.searchApps addObjectsFromArray:array];
        [self.searchTableViewController.tableView reloadData];
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    [self.tabBarController.tabBar setHidden:NO];
}

// 解决点击searchbar下移的bug
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchController.searchBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titView);
        make.top.equalTo(self.titView).offset(-2);
        make.bottom.equalTo(self.titView).offset(-2);
    }];
}



#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return [self.appClassArray count];
    }else
    {
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.tableView){
        return 1;
    }
    return [self.searchApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView== self.tableView){
        AppCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReusableCellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
//        if ([self.jumpID isEqualToString:@"1"]) {
//        cell.collectionView.contentOffset = CGPointMake(0, 0);
            [cell parseAppsDic:self.appClassArray[indexPath.section]];
//        }
        
        cell.delegate = self;
        return cell;
    }
    else{
        AppCenterSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
        HGAppModel *model = self.searchApps[indexPath.row];
        [cell setAppModel:model];
        return cell;
    }
}

/*
 NSDictionary *dict = self.appClassArray[indexPath.section];
 NSArray *array = [[HGAppDao sharedInstance] getApps:dict[@"appgroupcode"]];
 if (array.count <= 5) {
 HGCollectionViewOneLineLayout *layout =[[HGCollectionViewOneLineLayout alloc]init];
 NSInteger width = (SCREENWIDTH / 5 ) ;
 layout.itemSize = CGSizeMake(width,100);
 // cell间距
 layout.minimumInteritemSpacing = 0;
 // 行间距
 layout.minimumLineSpacing = 0;
 layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 cell.collectionView.collectionViewLayout = layout;
 }else
 {
 HGCollectionViewHorizontalLayout *layout =[[HGCollectionViewHorizontalLayout alloc]init];
 NSInteger width = (SCREENWIDTH / 5 ) ;
 layout.itemSize = CGSizeMake(width,100);
 // cell间距
 layout.minimumInteritemSpacing = 0;
 // 行间距
 layout.minimumLineSpacing = 0;
 layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 cell.collectionView.collectionViewLayout = layout;
 }

 */

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppCenterTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    self.cell = cell;
    if(tableView == self.searchTableViewController.tableView){
        if(!self.tableView.userInteractionEnabled)
        {
            // 正在下载 不能点击
            [UIAlertController showAlertWithTitle:@"提示" message:@"有正在下载的应用，请稍后再试"];
            return;
        }
        
        HGAppModel *model = self.searchApps[indexPath.row];
        BOOL isNeedDownload = [[HGAppDao sharedInstance] isNeedDownload:model.applicationId];
        if(isNeedDownload){
            // 跳转到详情下载
        NSArray *models = [[HGAppDao sharedInstance] getApps:model.appgroupcode];
        __block NSInteger tableRow = 0;
        [self.appClassArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *class = obj;
            NSString *appgroupcode = class[@"appgroupcode"];
            if([appgroupcode isEqualToString:model.appgroupcode]){
                tableRow = idx;
            }
        }];
        NSIndexPath *tableIndexPath = [NSIndexPath indexPathForRow:tableRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:tableIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
        AppCenterTableViewCell *tableCell = [self.tableView cellForRowAtIndexPath:tableIndexPath];
        
        __block NSInteger collectionRow = 0;
        [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HGAppModel *appModel = obj;
            if([appModel.applicationId isEqualToString:model.applicationId]){
                collectionRow = idx;
            }
        }];
        NSIndexPath *index = [NSIndexPath indexPathForItem:collectionRow inSection:0];
        
        
        [self.searchController dismissViewControllerAnimated:YES completion:^{
            [self.tabBarController.tabBar setHidden:NO];
            [tableCell.collectionView scrollToItemAtIndexPath:index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.waitUpdateCell = (AppCenterCollectionViewCell *)[tableCell.collectionView cellForItemAtIndexPath:index];
                AppCenterDetailViewController *detail = [[AppCenterDetailViewController alloc] init];
                detail.appModel = model;
                self.searchController.searchBar.text = @"";
                [detail setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:detail animated:YES];
            });
            
        }];
        
    }
        
        else{
            //直接打开
            [self.searchController dismissViewControllerAnimated:YES completion:^{
                [self.tabBarController.tabBar setHidden:NO];
                  self.searchController.searchBar.text = @"";
                [self openWeb:model];
            }];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.searchTableViewController.tableView){
        return HeightForTableRow;
    }else
    {
        NSArray *array = [[HGAppDao sharedInstance] getApps:self.appClassArray[indexPath.section][@"appgroupcode"]];
        if (array.count > 5) {
            return 263;
        }else
        {
            return 165;
        }
    }
//    return HeightForSeatchTableRow;
}


#pragma mark - AppCenterTableViewCellDelegate
// 长按cell
- (void) longPressAtCell:(AppCenterCollectionViewCell *)cell{
    if ([self isOverTwoHours] == true) {
        [self logoutAction];
    }else
    {
        self.waitUpdateCell = cell;
        AppCenterDetailViewController *detail = [[AppCenterDetailViewController alloc] init];
        HGAppModel *model = [[HGAppDao sharedInstance] getApp:cell.appId];
        detail.appModel = model;
        [detail setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:detail animated:YES];
    }
    
}

// 注册3Dtouch
- (void)registerForPreviewingWithsourceView:(AppCenterCollectionViewCell *)cell{
    [self registerForPreviewingWithDelegate:self sourceView:cell];
}

// 单击
- (void)didSelectItemAtAppModel:(HGAppModel *)appModel withCell:(AppCenterCollectionViewCell *)cell{
    
    if ([self isOverTwoHours] == true) {
        [self logoutAction];
        return;
    }
    
    [self.assistiveTouch shrink];
    NSInteger type = [appModel.scop_type integerValue];
    if(type == 1){
        BOOL isNeedDownload = [[HGAppDao sharedInstance] isNeedDownload:appModel.applicationId];
        if(isNeedDownload){
            NSString *localVersion = [[HGAppDao sharedInstance] getLocalVersion:appModel.applicationId];
            NSString *message = @"长按应用图标打开详情页进行更新";
            if([localVersion isEqualToString:@"0"]){
                message = @"长按应用图标打开详情页进行安装";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [self presentViewController:alert animated:YES completion:nil];
            //            [self downloadWWW:appModel updateCell:cell];
        }
        else{
//            self.jumpID = @"2";
            [self openWeb:appModel];
        }
    }
    if(type== 3|| type == 5 || type == 6){
        // 原生
        NSURL *url = [NSURL URLWithString:appModel.URL_Scheme];
        BOOL isCanOpen =  [[UIApplication sharedApplication] canOpenURL:url];
        if(isCanOpen){
            // 打开
            NSData *data = [appModel.appinfoexport dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSMutableDictionary *dic = [NSMutableDictionary new];
            for(NSString *key in jsonObject){
                [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:key] forKey:key];
            }
            
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"uaername"];
            NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
            NSString *hostPort = [[NSUserDefaults standardUserDefaults] objectForKey:@"maUrl"];
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSString *appUrl = [NSString stringWithFormat:@"%@//%@:%@@%@?%@",appModel.URL_Scheme,username,password,hostPort,json];
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appUrl]];
        }
        else{
            // 下载
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:appModel.url]];
        }
    }
}

// 打开web应用
- (void)openWeb:(HGAppModel *)appModel{
    
    BOOL close = [[NSUserDefaults standardUserDefaults] boolForKey:@"closeAssistiveTouch"];
    if(close){
        self.assistiveTouch.hidden = YES;
    }
    else{
        self.assistiveTouch.hidden = NO;
    }
    
    UIViewController *sumViewController;
    NSArray *viewControllers = [[ViewControllersMemoryHandle sharedInstance] getViewControllers:appModel.applicationId];
    if(viewControllers.count == 0){
        sumViewController = (SUMViewController *)[self getSummerViewController:appModel];
        viewControllers = [NSArray arrayWithObjects:self,sumViewController, nil];
    }
    
    AssistiveTouchItemModel *model = [[AssistiveTouchItemModel alloc] init];
    model.key = appModel.applicationId;
    model.labelName = appModel.title;
    model.imageName = appModel.iconurl;
    
    BOOL isExist = NO;
    for(AssistiveTouchItemModel *itemModel in self.assistiveTouchModels){
        if([itemModel.key isEqualToString:model.key]){
            isExist = YES;
        }
    }
    if(!isExist){
        if([self.assistiveTouchModels count] == 8){
            [self.assistiveTouchModels removeObjectAtIndex:0];
        }
        [self.assistiveTouchModels addObject:model];
    }
    
    self.assistiveTouch.currentKey = model.key;
    [sumViewController setHidesBottomBarWhenPushed:YES];
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
    return;
}


- (void)downloadWWW:(HGAppModel *)appModel updateCell:(AppCenterCollectionViewCell *)cell{
    
    [self.tableView setUserInteractionEnabled:NO];
    if(cell == nil){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [cell showProgress];
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    username = username.length ? username:@"guest";
    // 需要下载zip
    [[EMMW3FolderManager sharedInstance] downloadW3FolderWithURL:appModel.webZipUrl key:[NSString stringWithFormat:@"%@-%@",username,appModel.applicationId] version:appModel.version versionName:appModel.version incremental:NO progress:^(NSProgress *downloadProgress) {
        CGFloat progressValue = 1.0 *downloadProgress.completedUnitCount/downloadProgress.totalUnitCount;
        NSLog(@"cell.title------%@progressValue -- %lf",cell.appName.text,progressValue);
        
        [cell updateProgress:progressValue];
    } completion:^(BOOL success, id result) {
        NSLog(@"ssssss");
        [self.tableView setUserInteractionEnabled:YES];
        if(cell == nil){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        if(success){
            // 下载成功 更新数据库
            [[HGAppDao sharedInstance] updatewww_localVersion:appModel.version appId:appModel.applicationId];

            
//             [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [self.tableView reloadData];
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }
        else{
            // 下载失败
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载安装失败" preferredStyle:UIAlertControllerStyleAlert cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [self presentViewController:alert animated:YES completion:^{
                 [self.tableView reloadData];
            }];
            
        }
    }];
}

#pragma mark - AppCenterAssistiveTouchDelegate
- (void)selectedAssistiveTouchItem:(NSInteger)tag{
    
    // 在应用中切换
    if(self.assistiveTouch.currentKey){
        //当前打开的应用
        NSMutableArray *childViewControllers = [NSMutableArray arrayWithArray:[self.navigationController childViewControllers]];
        
        [[ViewControllersMemoryHandle sharedInstance] setViewControllers:childViewControllers key:self.assistiveTouch.currentKey];
        
    }
    
    if(tag == backItemTag){
        [self.navigationController popToRootViewControllerAnimated:YES];
        self.assistiveTouch.currentKey = nil;
        return;
    }
    
    NSInteger index = tag>4?tag-1:tag;
    AssistiveTouchItemModel *model = self.assistiveTouchModels[index];
    
    self.assistiveTouch.currentKey = model.key;
    NSArray *viewControllers = [[ViewControllersMemoryHandle sharedInstance] getViewControllers:model.key];
    
    if(viewControllers.count){
        [self.navigationController setViewControllers:viewControllers animated:YES];
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

#pragma mark - UIViewControllerPreviewingDelegate
//peek(预览)
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    AppCenterCollectionViewCell *cell = (AppCenterCollectionViewCell *)[previewingContext sourceView];
    self.waitUpdateCell = cell;
    AppCenterDetailViewController *detail = [[AppCenterDetailViewController alloc] init];
    HGAppModel *model = [[HGAppDao sharedInstance] getApp:cell.appId];
    detail.appModel = model;
    [detail setHidesBottomBarWhenPushed:YES];
    detail.preferredContentSize = CGSizeMake(0.0f,500.0f);
    return detail;
}

//pop（按用点力进入）
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}


#pragma mark - 验证时间

//时间戳
-(NSString *)getCurrentDate{
    
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"yyyy/MM/dd-HH:mm"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString * timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    
    return timeNow;
}

#pragma mark -超时弹框
-(void)showAlertAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"注意" message:@"您登录时间已经超过两小时,请退出重新登录" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [EMMMediator segueToLoginViewController];
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(BOOL)isOverTwoHours{
    NSString *lastLoginTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLoginTime"];//@"2016/11/11-12:10";
    NSString *currentTime = [self getCurrentDate];//@"2016/11/11-14:09";
    NSArray * lastLoginTimeArray = [lastLoginTime componentsSeparatedByString:@"-"];
    NSString *lastLoginMonthAndDay = lastLoginTimeArray[0];
    NSInteger lastDay = [[lastLoginMonthAndDay substringFromIndex:lastLoginMonthAndDay.length - 2] integerValue];
    NSString *lastLoginHourAndMin = lastLoginTimeArray[1];
    NSArray * lastLoginHourAndMinArray = [lastLoginHourAndMin componentsSeparatedByString:@":"];
    NSInteger lastHour = [lastLoginHourAndMinArray[0] integerValue];
    NSInteger lastMin = [lastLoginHourAndMinArray[1] integerValue];
    //    NSRange range = [currentTime rangeOfString:@"-"];
    
    
    
    NSArray *currentTimeArr = [currentTime componentsSeparatedByString:@"-"];
    NSString *currentMonthAndDay = currentTimeArr[0];
    NSInteger currentDay = [[currentMonthAndDay substringFromIndex:currentMonthAndDay.length -2] integerValue];
    
    NSString *currentHourAndMin = currentTimeArr[1];
    NSArray *currentHourAndMinArray = [currentHourAndMin componentsSeparatedByString:@":"];
    NSInteger currentHour = [currentHourAndMinArray[0] integerValue];
    NSInteger currentMin = [currentHourAndMinArray[1] integerValue];
    // 天数相等
    if (currentDay == lastDay) {
        if (currentHour > lastHour)
        {
            NSInteger H = currentHour - lastHour;
            if (H >= 3) {
                return YES;
            }else{
                NSInteger M ;
                if (currentMin >= lastMin) {
                    M = H * 60 + (currentMin - lastMin);
                }else{
                    M = H * 60 - (lastMin - currentMin);
                }
                
                if (M>120) {
                    return YES;
                }else{
                    return NO;
                }
            }
        }else{
            // 小时相等
            //        if ((currentMin - lastMin) > 0) {
            //            return YES;
            //        }else
            //        {
            //            return  false;
            //        }
            
            
            return NO;
        }
        
    }else
    {
        return YES;
    }
    
    
}

-(void)logoutAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"登录超时,请重新登录!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self logout];
    }];
    [okAction setValue:[UIColor emm_colorWithHexString:@"#1073BE"] forKey:@"titleTextColor"];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)logout {
    
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSString *password = [[EMMApplicationContext defaultContext] objectForKey:@"password"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *params = @{
                             @"username": username,
                             @"password": password
                             };
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"logout"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (result) {
            int code =  [result[@"data"][@"code"] intValue];
            if (code == 1) {
                //                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"usernameNoEnable"];
                //                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
                UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:loginVC];
                [UIApplication sharedApplication].delegate.window.rootViewController = naviController;
            }
        }
    } failure:^(NSError *error) {
        // TODO:
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}






@end
