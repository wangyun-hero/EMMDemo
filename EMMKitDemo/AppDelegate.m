//
//  AppDelegate.m
//  EMMKitDemo
//
//  Created by Chenly on 16/6/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "AppDelegate.h"
#import "EMMMediator.h"
#import "EMMApplicationContext.h"
#import "EMMDataAccessor.h"
#import "UIAlertController+EMM.h"
#import "MessageModel.h"
#import "MessageDao.h"
#import "MessageDBHandle.h"
#import "MessageDateHandle.h"
#import <UserNotifications/UserNotifications.h>
#import "HGAppModel.h"
#import "HGAppDao.h"
//#import <IUMSummerAPM/IUMSummerAPM.h>
#import "IUMAPM.h"
#import <Bugly/Bugly.h>
#import "HGMessageMainViewController.h"
#import "introductoryPagesHelper.h" // 引导页
#import "GVUserDefaults+Properties.h"
#import "AdvertiseHelper.h"         // 广告
#import "WYViewController.h"
#define NotificationAppId @"888"
#define WelcomeNoteAppId @"999"



@interface AppDelegate ()<UNUserNotificationCenterDelegate>
@property(nonatomic,strong) NSString *appVersion;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 当前版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    self.appVersion = app_Version;
    
    
    NSLog(@"%@",app_Version);
    IUMAPM *iumapm = [IUMAPM defaultIUMAPM];
    NSString *appKey = @"3+mHoI5YBTTU1wFCr/NIVM3FygMw28DaBhZanOuWiY4=";
    NSString *channelKey = @"6028";
    [iumapm startWithappKey:appKey channelKey:channelKey];
    [Bugly startWithAppId:@"b21dd4ba7e"];
    // navBar允许透明
    [UINavigationBar appearance].translucent = YES;
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    BOOL notFirst = WYUserDefault.notFirstLog;
    if (notFirst) {
        NSLog(@"不是首次登陆");
        // 记录的版本号
        NSString *version = WYUserDefault.version;
        // 版本号相同
        if ([version isEqualToString:app_Version]) {
            // 加载启动页对应的vc
            WYViewController *vc = [[WYViewController alloc]init];
            self.window.rootViewController = vc;
            [self.window makeKeyAndVisible];
            // 2秒后切换rootVC
            [self performSelector:@selector(rootChange) withObject:nil afterDelay:2];
        }else
        {
            
            UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
            UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:loginVC];
            self.window.rootViewController = naviController;
            [self.window makeKeyAndVisible];
        }
    }else{
        NSLog(@"首次登陆");
        // 记录当前的版本号
        WYUserDefault.version = app_Version;
        UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
        UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = naviController;
        [self.window makeKeyAndVisible];
    }
    
    [[MessageDBHandle getSharedInstance] initTable];
    [[EMMApplicationContext defaultContext] setObject:@"219.142.41.80" forKey:@"emm_host"];
    [[EMMApplicationContext defaultContext] setObject:@"8080" forKey:@"emm_port"];
//    [[EMMApplicationContext defaultContext] setObject:@"192.168.8.115" forKey:@"emm_host"];
//    [[EMMApplicationContext defaultContext] setObject:@"7001" forKey:@"emm_port"];
//    [[EMMApplicationContext defaultContext] setObject:@"emm.chinaport.gov.cn" forKey:@"emm_host"];
//    [[EMMApplicationContext defaultContext] setObject:@"8080" forKey:@"emm_port"];
    
    // 推送
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
    } else {
        UIUserNotificationType types = UIUserNotificationTypeBadge                                                                                                                      | UIUserNotificationTypeSound | UIUserNotificationTypeAlert ;
        UIUserNotificationSettings * setting =  [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    }
    
    // 引导页
    [self setupIntroductoryPage];
    
//    [self setupAdveriseView];
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self saveReceiveRemoteNotif:userInfo];
    }
    return YES;
}

// 切换vc
-(void)rootChange
{
    UIViewController *loginVC = [EMMMediator loginViewControllerBySetting];
    UINavigationController *naviController = [[UINavigationController alloc] initWithRootViewController:loginVC];
    self.window.rootViewController = naviController;
    [self.window makeKeyAndVisible];
}

#pragma mark - 引导页
- (void)setupIntroductoryPage
{
    BOOL notFirst = WYUserDefault.notFirstLog;
    if (notFirst) {
        NSLog(@"不是首次登陆");
        NSString *version = WYUserDefault.version;
        if ([version isEqualToString:self.appVersion]) {
            NSLog(@"doNothing");
        }else
        {
            WYUserDefault.version = self.appVersion;
            NSArray *images=@[@"启动页一",
                              @"启动页二",
                              @"启动页三",];
            [introductoryPagesHelper showIntroductoryPageEAIntroViewView:images];
        }
    }else{
        NSLog(@"首次登陆");
        WYUserDefault.notFirstLog = YES;
        NSArray *images=@[@"启动页一",
                          @"启动页二",
                          @"启动页三",];
        [introductoryPagesHelper showIntroductoryPageEAIntroViewView:images];
    }
}

#pragma mark - 启动广告
- (void)setupAdveriseView
{
    // TODO 请求广告接口 获取广告图片
    
    //现在了一些固定的图片url代替
    NSArray *imageArray = @[
                            @"http://imgsrc.baidu.com/forum/pic/item/9213b07eca80653846dc8fab97dda144ad348257.jpg",
                            @"http://pic.paopaoche.net/up/2012-2/20122220201612322865.png",
                            @"http://img5.pcpop.com/ArticleImages/picshow/0x0/20110801/2011080114495843125.jpg",
                            @"http://www.mangowed.com/uploads/allimg/130410/1-130410215449417.jpg"
                            ];
    
    [AdvertiseHelper showAdvertiserView:imageArray];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSString *pushToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"pushToken"];

}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [self saveReceiveRemoteNotif:userInfo];
    UIViewController *viewController =  self.window.rootViewController;
    if([viewController isKindOfClass:[UITabBarController class]]){
        UITabBarController *tabbar = (UITabBarController *)viewController;
        NSArray *viewControllers = ((UINavigationController *)tabbar.selectedViewController).viewControllers;
        if(viewControllers.count > 1){
            UIViewController *last = [viewControllers lastObject];
            [last.navigationController popToRootViewControllerAnimated:NO];
        }
        [tabbar setSelectedIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadMessage" object:nil];
        
    }
}

- (void)saveReceiveRemoteNotif:(NSDictionary *)dic{
    if(dic.count == 0){
        return;
    }
    NSDictionary *aps = dic[@"aps"];
    NSDictionary *alert = aps[@"alert"];
    NSString *title = alert[@"title"];
    NSString *body = alert[@"body"];
    NSString *extra = aps[@"extra_text"];
    NSString *appId = @"";
    NSString *userId= @"";
    if(extra.length){
        NSDictionary *extraDic = [self getJsonFromUrl:extra];
        appId = extraDic[@"appId"];
        userId= extraDic[@"userId"];
    }
    NSString *messageDate = [MessageDateHandle getCurrentDate];
    NSDictionary *userInfo = [NSDictionary new];
    
    if([userId isEqualToString:@""]){
        return;
    }

    if([appId isEqualToString:@""]){
        // 通知类型
        NSString *messageName = @"通知";
        NSString *messageImage = @"notificationIcon.png";
        
        userInfo = @{@"messageName":messageName,@"messageInfo":body,@"messageDate":messageDate,@"messageImage":messageImage,@"appId":NotificationAppId,@"isRead":@1,@"userId":userId};
    }else{
        HGAppModel *appModel = [[HGAppDao sharedInstance] getApp:appId];
        if(appModel.applicationId){
            // 能打开应用类型
            userInfo = @{@"messageName":title,@"messageInfo":body,@"messageDate":messageDate,@"messageImage":appModel.iconurl,@"appId":appId,@"isRead":@1,@"userId":userId};
        }
        else{
            // 不能打开的应用类型
            NSString *messageImage = @"noticeIcon.png";
            userInfo = @{@"messageName":@"消息提醒",@"messageInfo":body,@"messageDate":messageDate,@"messageImage":messageImage,@"appId":WelcomeNoteAppId,@"isRead":@1,@"userId":userId};
        }
    }
    
    MessageModel *messageModel = [[MessageModel alloc] init];
    [messageModel parseDic:userInfo];
    [[MessageDao sharedInstance] addMessage:messageModel];
    
    
    
}

-(NSMutableDictionary *)getJsonFromUrl:(NSString *)json{
    
    NSMutableDictionary * list = [[NSMutableDictionary alloc] init];
    
    NSArray * arr = [[NSArray alloc] init];
    arr = [json componentsSeparatedByString:@"#"];
    
    for (int i=0; i< arr.count; i++) {
        
        NSString * obj = [arr objectAtIndex:i];
        
        NSRange  range = [obj rangeOfString:@"="];
        
        if (range.length > 0) {
            
            NSString * key = [obj substringToIndex:range.location];
            NSString * value = [obj substringFromIndex:range.location+1];
            
            [list setValue:value forKey:key];
            
        }
        
    }
    
    return list;
}

     
@end
