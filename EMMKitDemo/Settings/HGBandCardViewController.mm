//
//  HGBandCardViewController.m
//  EMMKitDemo
//
//  Created by 振亚 姜 on 16/11/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGBandCardViewController.h"
#import "bleobj.h"
#include"blec.h"
//#include "SpTestCase.h"
#import "MBProgressHUD.h"
#import "UIAlertController+EMM.h"
#import "EMMDataAccessor.h"
#import "EMMMediator.h"
#import "BluetoothHandler.h"
#import<CommonCrypto/CommonDigest.h>

//设备全屏宽度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define lineColor [UIColor colorWithRed:128/255.0 green:127/255.0 blue:127/255.0 alpha:0.3f]

@interface HGBandCardViewController ()<BTSmartSensorDelegate>{
    BOOL isBleSerachSucceed;//蓝牙搜索是否成功
    NSString *orgIstcd;//组织机构代码
    NSString *EtpsNmFromCard;//企业名称
}
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *cardNumText;
@property (weak, nonatomic) IBOutlet UIButton *searchICCardBtn;
@property (weak, nonatomic) IBOutlet UIButton *bandICCardBtn;


@property (nonatomic,strong) bleobj *ble;
@end

@implementation HGBandCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"绑定蓝牙KEY";
    //初始化蓝牙
    _ble = [[bleobj alloc] init];
    _ble.delegate = self;
    _ble.peripherals = nil;
    void* p = (__bridge void*)_ble;
    ble_setdelegate(p);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view from its nib.
    [self layoutView];
    [self adapteriOS7];
    UILabel *introductionLabel = [[UILabel alloc] init];
    introductionLabel.text = @"注册企业用户绑定IC卡，等同于IC卡登陆，具有全部操作权限，可进行本企业数据详情的查询及数据的申报。绑定IC卡操作说明：\n1、手机终端支持绑定蓝牙KEY，手机通过蓝牙端口匹配，输入蓝牙KEY密码校验通过后，绑定成功；\n2、PC终端支持IC、IKEY卡绑定，登陆http://nra.chinaport.gov.cn/nar，用户管理页面绑定IC卡，输入IC、IKEY卡密码校验通过后，绑定成功。";
    NSInteger width = [UIScreen mainScreen].bounds.size.width - CGRectGetMinX(self.searchICCardBtn.frame) * 2;
    CGRect r = [introductionLabel.text boundingRectWithSize:CGSizeMake(width,0) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f]} context:nil];
    introductionLabel.frame = CGRectMake(CGRectGetMinX(self.searchICCardBtn.frame), CGRectGetMaxY(self.searchICCardBtn.frame) + 30, width, r.size.height);
    introductionLabel.numberOfLines = 0;
    introductionLabel.backgroundColor = [UIColor clearColor];
    introductionLabel.textColor = [UIColor blackColor];
    introductionLabel.font = [UIFont systemFontOfSize:13.f];
    [self.view addSubview:introductionLabel];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_ble disconnect];
    
}

- (void)tapHandle:(UITapGestureRecognizer *)tap{
    [self.view endEditing:YES];
    
}


-(void)layoutView{
    self.backView.layer.cornerRadius = 8.0f;
    self.backView.layer.masksToBounds = YES;
    self.searchICCardBtn.layer.masksToBounds = YES;
    self.searchICCardBtn.layer.cornerRadius = 5.0f;
    self.bandICCardBtn.layer.masksToBounds = YES;
    self.bandICCardBtn.layer.cornerRadius = 5.0f;
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, kScreenWidth , 0.5)];
    [lineLabel setBackgroundColor:lineColor];
    [self.backView addSubview:lineLabel];
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
- (IBAction)searchICCardAction:(id)sender {
    if ([self.passwordText.text isEqualToString:@""]) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"请先输入密码"];
        return;
    }
    if (self.passwordText.text.length != 8) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"密码必须是8位"];
        return;
    }
    //蓝牙登陆,搜索蓝牙设备
    [_ble setTimeOutForScan:50 forTransmit:50];
    //开始搜索
    [_ble scanPeripheral];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(scanTimer) userInfo:nil repeats:NO];
    
    [self performSelector:@selector(addBleCards) withObject:nil afterDelay:5.0f];
}
- (IBAction)bandICCardAction:(id)sender {
    if (!self.cardNumText.text || [self.cardNumText.text isEqualToString:@""]) {
        [UIAlertController showAlertWithTitle:@"提示" message:@"请先添加蓝牙KEY"];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *orgcd = self.orgIstcdFromRegister;
    if ([orgcd isEqualToString:@""]) {
        orgcd = orgIstcd;
    }
    NSString *social = self.socialCrecdFromRegister?:@"";
    NSString *userTypecd = @"1";
    NSString *etpsNm = self.etpsNm;
    if (!etpsNm || [etpsNm isEqualToString:@""]) {
        etpsNm = EtpsNmFromCard;
    }
//    etpsNm = @"天";
    NSString *deptNm = self.deptNm?self.deptNm:@"";
    NSString *istNum = self.istNum?self.istNum:@"";
    NSString *istNm = self.istNm?self.istNm:@"";
    NSString *md5pwd = [self md5:self.userPw];
    
    NSString *signStr = [NSString stringWithFormat:@"%@||%@||%@||%@||%@||%@||%@||%@||%@||%@||%@",self.userId,md5pwd,self.userName,userTypecd,self.cardNumText.text,orgcd,social,etpsNm,deptNm,istNum,istNm];
    
    NSString * signData = [self BleSign:signStr];
    
    
    NSDictionary *params = @{@"userId":self.userId,
                             @"password":self.userPw,
                             @"cardFlag":@"0",
                             @"deptNm":deptNm,
                             @"etpsNm":etpsNm,
                             @"icCardNo":self.cardNumText.text,
                             @"istNm":istNm,
                             @"istNum":istNum,
                             @"orgIstcd":orgcd,
                             @"etpsUNSocialCrecd":social,
                             @"userName":self.userName,
                             @"singnatureData":signData
                             };
    
    [self bandICCard:params];
}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

//蓝牙签名
-(NSString *)BleSign:(NSString *)random{
    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    const char* ss = [random cStringUsingEncoding:enc];
    unsigned long len = strlen(ss);

    unsigned char *rr = [BluetoothHandler enCodingFromString:random];
    unsigned char *ppp = [BluetoothHandler enCodingFromString:self.passwordText.text];
    __block NSString *signData = @"";
    [BluetoothHandler signData:rr randomLen:(unsigned int)len pin:ppp resultBlock:^(BOOL isSuccess, NSString *result) {
        if(isSuccess){
            signData = result;
        }
        else{
            [UIAlertController showAlertWithTitle:@"提示" message:result];
        }
    }];
    
    NSLog(@"signData:%@",signData);
    
    return signData;
    
}


-(void)bandICCard:(NSDictionary *)params{
    EMMDataAccessor *verifyDataAccessor = [EMMDataAccessor dataAccessorWithModule:@"accessor" request:@"MA_bandCard"];
    [verifyDataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *dic = result[@"data"];
        NSString *code = dic[@"code"];
        if ([code isEqualToString:@"1"]) {
            NSDictionary *resultDic = dic[@"resultctx"];
            NSString *cardManageResult = resultDic[@"cardManageResult"];
            NSString *msg = resultDic[@"registerDesc"];
            if ([cardManageResult isEqualToString:@"true"]) {
                [UIAlertController showAlertWithTitle:msg message:nil cancelButtonTitle:@"确定" otherButtonTitle:nil handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        
                        if(!self.fromSet){
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        }else{
                            [self logout];
                        }
                    }
                }];
            }else{
                [UIAlertController showAlertWithTitle:@"绑定失败" message:msg];
            }
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self resetBleCardLogin];
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];

}

-(void)scanTimer
{
    if (!isBleSerachSucceed) {
        [self resetBleCardLogin];
        //蓝牙
        [_ble stopScan];
    }
    isBleSerachSucceed = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

//蓝牙代理方法
-(void)peripheralFound:(CBPeripheral *)peripheral{
    
}
-(void)addBleCards{
    if (_ble.peripherals.count > 0) {
        UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (CBPeripheral *peripheral in _ble.peripherals) {
            _ble.activePeripheral = peripheral;
            __block CBPeripheral *weakperipheral = _ble.activePeripheral;
            __block bleobj *weakble = _ble;
            __block typeof(self) weakself = self;
            __block int t;
            UIAlertAction *action = [UIAlertAction actionWithTitle:peripheral.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                t = [weakble connect:weakperipheral];
                [weakble stopScan];
                if (t == 0) {
                    NSLog(@"蓝牙连接成功");
                    [weakself readBleDevice];
                }
            }];
            [alertcontroller addAction:action];
        }
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertcontroller addAction:actionCancel];
        [self presentViewController:alertcontroller animated:YES completion:^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self resetBleCardLogin];
//        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        HUD.mode = MBProgressHUDModeText;
//        HUD.label.text = @"未找到蓝牙设备,请开启您的蓝牙设备";
//        HUD.removeFromSuperViewOnHide = YES;
//        [HUD hideAnimated:YES afterDelay:1.5];
        [UIAlertController showAlertWithTitle:@"提示" message:@"未搜索到可用的蓝牙KEY设备，请确认手机是否打开蓝牙或者蓝牙KEY已开启。\n注：有蓝牙KEY需求的企业，请联系当地分中心申请！"];
        [_ble stopScan];
    }
}

//读取蓝牙设备
-(void)readBleDevice{
    unsigned char *ppp = [BluetoothHandler enCodingFromString:self.passwordText.text];
    [BluetoothHandler checkPWD:ppp resultBlock:^(BOOL isSuccess, NSString *result) {
        if(!isSuccess){
            [UIAlertController showAlertWithTitle:@"提示" message:@"您输入的密码不正确"];
            return;

        }
    }];
    
    isBleSerachSucceed = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block NSString *cardID  = @"";
        __block NSString *certNoStr = @"";
        [BluetoothHandler getCardID:^(BOOL isSuccess, NSString *result) {
            if(isSuccess){
                cardID = result;
            }
        }];
        
        [BluetoothHandler getCardUserInfo:^(BOOL isSuccess, NSString *result) {
            if(isSuccess){
                certNoStr = result;
            }
        }];

        if (certNoStr &&![certNoStr isEqualToString:@""]) {
            NSArray *temp = [certNoStr componentsSeparatedByString:@"||"];
            orgIstcd = temp[8];
            EtpsNmFromCard = temp[6];
            
        }
        NSLog(@"%@------orgcd:%@------etpsNumFromCard:%@",cardID,orgIstcd,EtpsNmFromCard);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cardID && ![cardID isEqualToString:@""]) {
                self.cardNumText.text = cardID;
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
}

//蓝牙卡登录失败重置
-(void)resetBleCardLogin{
    self.cardNumText.text = @"";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logout {
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
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
