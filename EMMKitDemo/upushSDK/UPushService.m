//
//  UPushService.m
//  upush
//
//  Created by 振亚 姜 on 14-12-13.
//  Copyright (c) 2014年 Uap. All rights reserved.
//

#import "UPushService.h"
#import "OpenUDID.h"
#import "SvUDIDTools.h"
#import "AFNetworking.h"
#import "EMMDeviceInfo.h"

#define SIGNIN 10010
#define NOTICE 10011
#define ADDTAG 10012
#define RETAG  10013
#define LOCATION 10014
#define LBS 10015

typedef void (^completeBlock)(id result, NSError *error,BOOL success);

@interface UPushService()<CLLocationManagerDelegate>
@property (nonatomic,strong) CLLocationManager *locationManager;


@end

@implementation UPushService

static bool backCheck;
static NSString * ips;
static NSString * ports;
static CLLocation *locationMsg;
static void (^ staticBlock)(CLLocation * locations);
static UPushService *upush = nil;
static NSString * appids;

+(UPushService *)sharedInstance{
    @synchronized(self){
        if (upush == nil) {
            upush = [[self alloc] init];
        }
    }
    return upush;
}

// 请求网络
+ (void)requestPost:(NSString *)url parameters:(NSDictionary *)params complete:(completeBlock)completeBlock{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    sessionManager.responseSerializer.acceptableContentTypes = nil;
    sessionManager.requestSerializer.timeoutInterval = 10;
    [sessionManager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
//        NSData *data = [responseObject dataUsingEncoding:NSUTF8StringEncoding];
//        NSError *error = nil;
//        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSDictionary *dic = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            
            dic = (NSDictionary *)responseObject;
            
            NSLog(@"Dersialized JSON Dictionary = %@", dic);
            
        }
        if (dic != nil ) {
            
            int code =  [dic[@"error"] intValue];
            if (code == SUCCESS) {
                completeBlock(responseObject,nil,YES);
                
            }else{
                completeBlock(responseObject,nil,NO);
            }
        }
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completeBlock(nil,error,NO);
    }];
}


//设备注册
+(void)upushSignin:(NSString *)token ip:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid complete:(UPushCompleteBlock)block{
    NSString *deviceId;
    if (!deviceid || [deviceid isEqualToString:@""]) {
        deviceId = [[EMMDeviceInfo currentDeviceInfo] UUID];//[SvUDIDTools UDID];

    }else{
        deviceId = deviceid;
    }
    //    NSString * json = [NSString stringWithFormat:@"{\"type\":\"device_reg\",\"deviceId\":\"%@\",\"appId\":\"%d\",\"token\":\"%@\"}",deviceId,APPID,token];
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/client/ios.do",ip,port];
    if (ip==nil || port ==nil) {
        url = URL;
    }
    
    NSDictionary *params = @{@"type":@"device_reg",
                             @"deviceId":deviceId,
                             @"appId":[NSNumber numberWithInt:[appid intValue]],
                             @"token":token?token:@""};
    
    [self requestPost:url parameters:params complete:^(id result, NSError *error,BOOL success) {
        block(success);
    }];
}

//通知
+(void)upushNotificationClick:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid complete:(UPushCompleteBlock)block{
    NSString *deviceId;
    if (!deviceid || [deviceid isEqualToString:@""]) {
        deviceId = [SvUDIDTools UDID];
    }else{
        deviceId = deviceid;
    }
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/client/ios.do",ip,port];
    if (ip==nil || port ==nil) {
        url = URL;
    }
    NSDictionary *params = @{@"type":@"not_click",
                             @"deviceId":deviceId,
                             @"appId":[NSNumber numberWithInt:[appid intValue]]};
    
    [self requestPost:url parameters:params complete:^(id result, NSError *error, BOOL success) {
        block(success);
    }];
}

//添加标签
+(void)upushAddTag:(NSString *)tag ip:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid complete:(UPushCompleteBlock)block{
    NSString *deviceId;
    if (!deviceid || [deviceid isEqualToString:@""]) {
        deviceId = [SvUDIDTools UDID];
    }else{
        deviceId = deviceid;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/client/ios.do",ip,port];
    if (ip==nil || port ==nil) {
        url = URL;
    }
    NSDictionary *params = @{@"type":@"add_tag",
                             @"deviceId":deviceId,
                             @"appId":[NSNumber numberWithInt:[appid intValue]],
                             @"tag":tag};
    
    [self requestPost:url parameters:params complete:^(id result, NSError *error, BOOL success) {
        block(success);
    }];
}

//移除标签
+(void)upushRemoveTag:(NSString *)tag ip:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid complete:(UPushCompleteBlock)block{
    NSString *deviceId;
    if (!deviceid || [deviceid isEqualToString:@""]) {
        deviceId = [SvUDIDTools UDID];
    }else{
        deviceId = deviceid;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/client/ios.do",ip,port];
    if (ip==nil || port ==nil) {
        url = URL;
    }
    NSDictionary *params = @{@"type":@"remove_tag",
                             @"deviceId":deviceId,
                             @"appId":[NSNumber numberWithInt:[appid intValue]],
                             @"tag":tag};
    
    [self requestPost:url parameters:params complete:^(id result, NSError *error, BOOL success) {
        block(success);
    }];
}


//添加位置信息
+(void)upushPosition:(CLLocation *)locationInfo ip:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid complete:(UPushCompleteBlock)block;{
    NSString *deviceId;
    if (!deviceid || [deviceid isEqualToString:@""]) {
        deviceId = [SvUDIDTools UDID];
    }else{
        deviceId = deviceid;
    }
    CLLocationCoordinate2D mylocation = locationInfo.coordinate;
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/client/ios.do",ip,port];
    if (ip==nil || port ==nil) {
        url = URL;
    }
    NSDictionary *params = @{@"type":@"position",
                             @"deviceId":deviceId,
                             @"appId":[NSNumber numberWithInt:[appid intValue]],
                             @"longitude":[NSNumber numberWithFloat:mylocation.longitude],
                             @"latitude":[NSNumber numberWithFloat:mylocation.latitude]};
    [self requestPost:url parameters:params complete:^(id result, NSError *error, BOOL success) {
        block(success);
    }];
}

//开启或关闭位置推送
+(void)upushLBSon:(int)lbsOn ip:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid block:(UPushServiceOpenLocation)block{
    [self upushLBSon:lbsOn metres:10.0f locationAccuracy:kCLLocationAccuracyBest ip:ip port:port appid:appid deviceid:deviceid block:block];
}

//开启或关闭位置推送(设置精度,距离间隔)
+(void)upushLBSon:(int)lbsOn metres:(float)meters locationAccuracy:(CLLocationAccuracy)locationAccuracy ip:(NSString *)ip port:(NSString *)port appid:(NSString *)appid deviceid:(NSString *)deviceid block:(UPushServiceOpenLocation)block{
    staticBlock = block;
    ports = port;
    ips = ip;
    appids = appid;
    NSString *deviceId;
    if (!deviceid || [deviceid isEqualToString:@""]) {
        deviceId = [SvUDIDTools UDID];
    }else{
        deviceId = deviceid;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%@/client/ios.do",ip,port];
    if (ip==nil || port ==nil) {
        url = URL;
    }
    NSDictionary *params = @{@"type":@"lbs_on",
                             @"deviceId":deviceId,
                             @"appId":[NSNumber numberWithInt:[appid intValue]],
                             @"lbsOn":[NSNumber numberWithInt:lbsOn]};
    
    [self requestPost:url parameters:params complete:^(id result, NSError *error, BOOL success) {
        if(success){
            if(lbsOn == 1){
                [self openlocatinonWithDistance:meters locationAccuracy:locationAccuracy];
            }
            else if(lbsOn == 0){
                [[UPushService sharedInstance].locationManager stopUpdatingLocation];
            }
        }
    }];
}


+(void)alertShow:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

+(void)openlocatinonWithDistance:(float)meters locationAccuracy:(CLLocationAccuracy)locationAccuracy{
        [UPushService sharedInstance].locationManager = [[CLLocationManager alloc] init];
        [[UPushService sharedInstance].locationManager setDistanceFilter:meters];//kCLDistanceFilterNone;
        [[UPushService sharedInstance].locationManager setDesiredAccuracy:locationAccuracy];
        [UPushService sharedInstance].locationManager.delegate = [UPushService sharedInstance];
        
        if([[UPushService sharedInstance].locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [[UPushService sharedInstance].locationManager requestAlwaysAuthorization]; // 永久授权
        }
        [[UPushService sharedInstance].locationManager startUpdatingLocation];
}
//ios8新增方法,实现位置刷新
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([[UPushService sharedInstance].locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [[UPushService sharedInstance].locationManager requestWhenInUseAuthorization];
            }
            break;
            
        default:
            break;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation * newLocations = [locations lastObject];
    locationMsg = newLocations;
    CLLocationCoordinate2D mylocation = newLocations.coordinate;
    NSLog(@"locationMsg == %f,%f",mylocation.latitude,mylocation.longitude);
    //定位成功调用block返回位置信息
    if (backCheck) {
        staticBlock(locationMsg);
    }
    
    NSString *deviceId = [SvUDIDTools UDID];
    
    [UPushService upushPosition:newLocations ip:ips port:ports appid:appids deviceid:deviceId complete:nil];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        //访问被拒绝
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
        NSLog(@"无法获取位置信息!");
    }
}

+(NSString *)getDeviceId{
    return [SvUDIDTools UDID];
}



@end
