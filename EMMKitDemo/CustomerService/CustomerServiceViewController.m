//
//  CustomerServiceViewController.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/24.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "CustomerServiceViewController.h"

#import "CustomerServiceModel.h"
#import "OnlineHelpViewController.h"
#import "CustomerServiceCollectionViewCell.h"
#import "UIColor+HexString.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h"
#import "CustomerServiceTableViewCell.h"
#import <Masonry.h>
#import <UINavigationController+Extension.h>
#import "UINavigationBar+UINavigationBar_other.h"
#define ReuseIdentifier @"CustomerServiceCollectionViewCell"

typedef NS_ENUM(NSUInteger, CustomerServiceModels) {
    hotlineTelModel,
    onlineHelpModel
};
static NSString *tableViewCellID = @"tableViewCellID";
@interface CustomerServiceViewController ()<UITableViewDelegate,UITableViewDataSource>
// UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,
@property (weak, nonatomic) IBOutlet UIButton *hotlineTelBtn;
@property (weak, nonatomic) IBOutlet UIButton *onlineHelpBtn;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) NSArray *hotlineTelArray;
@property (nonatomic,strong) NSMutableArray *onlineHelpArray;
@property (nonatomic) CustomerServiceModels currentModel;

// tableview
@property(nonatomic,strong) UITableView *tableView;



@end

@implementation CustomerServiceViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.right.equalTo(self.view);
//    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
    [self.navigationController.navigationBar getnavBarColor:[UIColor colorWithRed:9/255.0 green:87/255.0 blue:131/255.0 alpha:1]];
    // Do any additional setup after loading the view from its nib.
    _hotlineTelArray = [[NSArray alloc] init];
    _onlineHelpArray = [[NSMutableArray alloc] init];
    [self getHotlineTelData];
    [self getOnlineHelpData];
    //    UINib *nib = [UINib nibWithNibName:ReuseIdentifier bundle:nil];
    //    [self.collectionView registerNib:nib forCellWithReuseIdentifier:ReuseIdentifier];
    
    [self adapteriOS7];
    
    // 顶部长条view的相关设置
    //    self.topView.layer.masksToBounds = YES;
    //    self.topView.layer.cornerRadius = 8.0f;
    //    self.topView.layer.borderWidth = 0.5;
    //    self.topView.layer.borderColor = [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0f] CGColor];
    //
    //    [self clickedHotlineTelBtn:nil];
    
    //-------------------------------
    UITableView *tableView = [[UITableView alloc]init];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
    [tableView registerNib:[UINib nibWithNibName:@"CustomerServiceTableViewCell" bundle:nil] forCellReuseIdentifier:tableViewCellID];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.estimatedRowHeight = 150;
    tableView.rowHeight = UITableViewAutomaticDimension;
//    tableView.scrollEnabled = false;
    self.tableView = tableView;
    
    //[self.tableView reloadData];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        self.currentModel = hotlineTelModel;
        CustomerServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID forIndexPath:indexPath];
        cell.mainTitleLabel.text = @"热线电话";
        cell.indexStr = @"1";
        cell.mainCollectionView.scrollEnabled = false;
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        cell.dataArray = self.hotlineTelArray;
        return cell;
    }else
    {
        self.currentModel = onlineHelpModel;
        CustomerServiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellID forIndexPath:indexPath];
        cell.mainTitleLabel.text = @"在线帮助";
        cell.mainCollectionView.scrollEnabled = YES;
        cell.indexStr = @"2";
        cell.myBlock = ^(NSString *str) {
            OnlineHelpViewController *onlineHelp = [[OnlineHelpViewController alloc] init];
            onlineHelp.modelKey = str;
            [onlineHelp setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:onlineHelp animated:YES];
            NSLog(@"控制器收到点击的事件");
        };
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
        //-----------------这里需要变化,暂时解决崩溃问题
        cell.dataArray = self.onlineHelpArray;
        return cell;
        
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    //    [self.chatView observerKeyboard];
//}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //    [self.chatView removeObserverKeyboard];
}

#pragma mark - ios7Adapter
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

#pragma mark -点击热线电话
- (IBAction)clickedHotlineTelBtn:(id)sender {
    self.navigationItem.title = @"热线电话";
    self.hotlineTelBtn.backgroundColor = [UIColor emm_colorWithHexString:@"#5ec1f7"];
    self.onlineHelpBtn.backgroundColor = [UIColor emm_colorWithHexString:@"#efeff4"];
    [self.hotlineTelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.onlineHelpBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self getHotlineTelData];
    self.currentModel = hotlineTelModel;
    [self.collectionView reloadData];
}

#pragma mark -点击在线帮助
- (IBAction)clickedOnlineHelpBtn:(id)sender {
    self.navigationItem.title = @"在线帮助";
    self.onlineHelpBtn.backgroundColor = [UIColor emm_colorWithHexString:@"#5ec1f7"];
    self.hotlineTelBtn.backgroundColor = [UIColor emm_colorWithHexString:@"#efeff4"];
    [self.onlineHelpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hotlineTelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self getOnlineHelpData];
    self.currentModel = onlineHelpModel;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
//    return 1;
//}
//
//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    return self.currentModel == hotlineTelModel?self.hotlineTelArray.count:self.onlineHelpArray.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
//    CustomerServiceCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ReuseIdentifier forIndexPath:indexPath];
//    CustomerServiceModel *model;
//    if(self.currentModel == hotlineTelModel){
//        model = self.hotlineTelArray[indexPath.row];
//    }
//    else if(self.currentModel == onlineHelpModel){
//        model = self.onlineHelpArray[indexPath.row];
//    }
//    [cell setCustomerServiceModel:model];
//    return cell;
//}
//
//#pragma mark - UICollectionViewDelegate
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    if(self.currentModel == hotlineTelModel){
//        CustomerServiceModel *model = self.hotlineTelArray[indexPath.row];
//        NSString *phoneNum = [[NSString alloc] initWithFormat:@"telprompt://%@",model.phoneNumber];
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
//    }
//    else{
//        CustomerServiceModel *model = self.onlineHelpArray[indexPath.row];
//        OnlineHelpViewController *onlineHelp = [[OnlineHelpViewController alloc] init];
//        onlineHelp.modelKey = model.key;
//        [onlineHelp setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:onlineHelp animated:YES];
//    }
//}
//
//#pragma mark - UICollectionViewDelegateFlowLayout
////定义每个UICollectionViewCell 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(CGRectGetWidth(self.view.frame)/3, CGRectGetWidth(self.view.frame)/3);
//}
//
////定义每个Section 的 margin
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0, 0, 0, 0);//分别为上、左、下、右
//}


#pragma mark - GetData  获取热线电话的数据
-(void)getHotlineTelData{
    if(!self.hotlineTelArray.count){
        CustomerServiceModel *m1 = [[CustomerServiceModel alloc] init];
        m1.image = @"海关热线.png";
        m1.title = @"海关热线";
        m1.phoneNumber = @"12360";
        CustomerServiceModel *m2 = [[CustomerServiceModel alloc] init];
        m2.image = @"电子口岸.png";
        m2.title = @"电子口岸";
        m2.phoneNumber = @"95198";
        CustomerServiceModel *m3 = [[CustomerServiceModel alloc] init];
        m3.image = @"投诉电话.png";
        m3.title = @"投诉电话";
        m3.phoneNumber = @"010-65194703";
        CustomerServiceModel *m4 = [[CustomerServiceModel alloc] init];
        m4.image = @"投诉电话.png";
        m4.title = @"投诉电话";
        m4.phoneNumber = @"010-65194703";
        self.hotlineTelArray = @[m1,m2,m3,m4];
        [self.tableView reloadData];
    }
}

#pragma mark - 获取在线帮助数据的数据
-(void)getOnlineHelpData{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.onlineHelpArray removeAllObjects];
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    username = username.length ?username:@"guest";
    NSDictionary *params = @{@"username":username};
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_onlineHelp" bundle:[NSBundle mainBundle]];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *dic = result[@"data"];
        NSString *code = dic[@"code"];
        NSString *msg = dic[@"msg"];
        if([code isEqualToString:@"1"])
        {
            NSDictionary *resultyctx = dic[@"resultctx"];
            NSArray *list = resultyctx[@"list"];
            [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *onlineDic = obj;
                CustomerServiceModel *model = [[CustomerServiceModel alloc] init];
                model.key = onlineDic[@"id"];
                model.title = onlineDic[@"name"];
                model.image = [NSString stringWithFormat:@"onlineHelpIcon-%u.jpg",(idx+1)%10];
                
                [self.onlineHelpArray addObject:model];
            }];
            [self.tableView reloadData];
        }
        else{
            [UIAlertController showAlertWithTitle:@"提示" message:msg];
        }
        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if(error){
            [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
        }
    }];
    
    
}
@end
