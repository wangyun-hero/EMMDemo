//
//  EMMLoginHTTPDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/11.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMLoginHTTPDataAccessor.h"
#import "EMMApplicationContext.h"
#import "EMMEncrypt.h"
#import "EMMDeviceInfo.h"
#import "UIDevice-Hardware.h"
#import "AFNetworking.h"
#import <AdSupport/AdSupport.h>

typedef NS_ENUM(NSUInteger, EMMNetConnectionRequestType) {
    EMMNetConnectionRequestTypeRegister,
    EMMNetConnectionRequestTypeLogin,
};

@interface EMMLoginHTTPDataAccessor ()

@property (nonatomic, copy) NSString *action;

@end

@implementation EMMLoginHTTPDataAccessor

static NSString * const kEMMLoginActionRegister = @"register";
static NSString * const kEMMLoginActionLogin = @"login";
static NSString * const kEMMLoginActionLogout = @"logout";
static NSString * const kEMMLoginActionAutofind = @"autofind";
static NSString * const kEMMLoginActionModifyPassword = @"modifyPassword";
static NSString * const kEMMLoginActionGetUserInfo = @"getUserInfo";
static NSString * const kEMMLoginActionFeedback = @"feedback";
static NSString * const kEMMLoginActionModifyAvatar = @"modifyAvatar";
static NSString * const kEMMLoginActionCheckVersion = @"checkVersion";

- (instancetype)initWithModule:(NSString *)module request:(NSString *)request args:(NSDictionary *)args {
    
    if (self = [super initWithModule:module request:request args:args]) {
        
        _action = request;
    }
    return self;
}

- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    if ([self.action isEqualToString:kEMMLoginActionRegister]) {
        
        [self registerWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionLogin]) {
        
        [self loginWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionLogout]) {
        
        [self logoutWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionAutofind]) {
        
        [self autofindWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionGetUserInfo]) {
        
        [self getUserInfoWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionModifyPassword]) {
        
        [self modifyPasswordWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionFeedback]) {
        
        [self feedbackWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionModifyAvatar]) {
        
        [self modifyAvatarWithParams:params success:success failure:failure];
    }
    else if ([self.action isEqualToString:kEMMLoginActionCheckVersion]) {
        
        [self checkVersionParams:params success:success failure:failure];
    }
    
}

- (void)registerWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *username = params[@"username"];
    NSString *password = params[@"password"];
    NSString *usertype = params[@"usertype"];
    NSString *userName = [params objectForKey:@"userName"]?[params objectForKey:@"userName"]:@"";
    NSString *pushToken = [[EMMApplicationContext defaultContext] objectForKey:@"pushToken"];
    NSDictionary *parameters = [self parametersForLoginAction:self.action insertUsername:username password:password pushToken:pushToken userType:usertype userName:userName];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataString = [EMMEncrypt encryptDES:dataString];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"des",
                                 @"data": dataString,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

- (void)loginWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *username = params[@"username"];
    NSString *password = params[@"password"];
    NSString *usertype = params[@"usertype"];
    NSString *pushToken = [[EMMApplicationContext defaultContext] objectForKey:@"pushToken"];
    NSDictionary *parameters = [self parametersForLoginAction:self.action insertUsername:username password:password pushToken:pushToken userType:usertype userName:@""];
    NSString *data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    data = [EMMEncrypt encryptDES:data];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"des",
                                 @"data": data,
                                 };
    [super sendRequestWithParams:theParams success:^(id result) {
        
        NSString *tp = result[@"tp"];
        NSString *data = result[@"data"];
        if ([tp isEqualToString:@"des"]) {
            
            NSString *decryptString = [EMMEncrypt decryptDES:data];
            id json = [NSJSONSerialization JSONObjectWithData:[decryptString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (json) {
                NSDictionary *descryptResult = @{ @"tp": tp, @"data": json };
                success(descryptResult);
            }
        }
        else {
            success(result);
        }
    } failure:failure];
}

- (void)logoutWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
    NSDictionary *parameters = @{ @"deviceid": UUID };
    NSString *data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": data,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

- (void)autofindWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *companyID = params[@"companyID"];
    
    NSDictionary *parameters = @{
                                 @"corpcode": companyID
                                 };
    NSString *data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": data,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

- (void)modifyPasswordWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *username = params[@"username"];
    NSString *oldPassword = params[@"oldPassword"];
    NSString *newPassword = params[@"newPassword"];
    
    NSDictionary *parameters = @{
                                 @"usercode": username,
                                 @"oldpass": oldPassword,
                                 @"newpass": newPassword,
                                 };
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = parameters;
    
    [super sendRequestWithParams:theParams success:success failure:failure];
}

- (void)getUserInfoWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *username = params[@"username"];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"usercode": username
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

- (void)feedbackWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *detail = params[@"detail"];
    NSString *contacts = params[@"contacts"];
    NSString *usercode = params[@"usercode"];
    
    NSDictionary *parameters = @{
                                 @"usercode": usercode,
                                 @"detail": detail,
                                 @"contacts": contacts
                                 };
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataString = [EMMEncrypt encryptDES:dataString];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"des",
                                 @"data": dataString,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

-(void)checkVersionParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *appid = params[@"appid"];
    
    NSDictionary *parameters = @{
                                 @"appid": appid
                                 };
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}


- (NSDictionary *)parametersForLoginAction:(NSString *)action insertUsername:(NSString *)username password:(NSString *)password pushToken:(NSString *)pushToken userType:(NSString *)usertype userName:(NSString *)userName{
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    // 应用相关信息
    NSDictionary *bundleInfos = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = bundleInfos[@"CFBundleShortVersionString"];   // 应用版本
    // 电量
    currentDevice.batteryMonitoringEnabled = YES;
    NSString * batteryleft = nil;
    if ([[NSString stringWithFormat:@"%.2f", [UIDevice currentDevice].batteryLevel] isEqualToString:@"-1.00"]) {
        
        batteryleft = [[NSString stringWithFormat:@"%.0f%%", currentDevice.batteryLevel*100] substringFromIndex:1];
    }
    else {
        batteryleft = [NSString stringWithFormat:@"%.0f%%", currentDevice.batteryLevel*100];
    }
    // 内存
    long long memSpace = currentDevice.totalMemory;
    long long usedMem = currentDevice.userMemory;
    double memPersent = (double)usedMem/(double)memSpace;
    NSString * memory = [NSString stringWithFormat:@"%.1f%% %lldMB已用 %lldMB",memPersent*100,usedMem/1024/1024,memSpace/1024/1024];
    
    // 硬盘
    long long dickSpace = [[UIDevice currentDevice].totalDiskSpace doubleValue];
    long long freeDickSpace = [[UIDevice currentDevice].freeDiskSpace doubleValue];
    long long usedSpace = (dickSpace-freeDickSpace)/1024/1024;
    double totalSpace = (double)[[UIDevice currentDevice].totalDiskSpace doubleValue]/1024/1024;
    double percent = (double)usedSpace/(double)totalSpace;
    NSString * storage = [NSString stringWithFormat:@"%.1f%% %.1fGB已用 %.1fGB",percent*100,(double)usedSpace/1024,totalSpace/1024];
    
    NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
    NSString *SSID = [EMMDeviceInfo currentDeviceInfo].SSID;
    NSString *companyid = [[EMMApplicationContext defaultContext] objectForKey:@"emm_companyid"];
    
    // ======= 填充数据 =======
    if ([action isEqualToString:kEMMLoginActionLogin]) {
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *appcontext = [NSMutableDictionary dictionary];
        appcontext[@"appid"] = @"sso";
        appcontext[@"user"] = @"";
        appcontext[@"pass"] = @"";
        appcontext[@"token"] = @"";
        appcontext[@"tabid"] = @"A010031";
        appcontext[@"funcid"] = @"A0100311";
        appcontext[@"appversion"] = appVersion;
        data[@"appcontext"] = appcontext;
        
        NSMutableDictionary *servicecontext = [NSMutableDictionary dictionary];
        servicecontext[@"actionid"] = @"";
        servicecontext[@"callback"] = @"";
        servicecontext[@"viewid"] = @"com.yonyou.ma.controller.CustomerController";
        servicecontext[@"actionname"] = @"load";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"user"] = username;
        params[@"pass"] = password;
        servicecontext[@"params"] = params;
        data[@"servicecontext"] = servicecontext;
        
        NSMutableDictionary *deviceinfo = [NSMutableDictionary dictionary];
        deviceinfo[@"devid"] = UUID;
        deviceinfo[@"serialnumber"] = UUID;
        deviceinfo[@"pushMsgToken"] = pushToken ?: @"";
        deviceinfo[@"wifi"] = SSID;
        deviceinfo[@"appversion"] = appVersion;
        deviceinfo[@"isRoot"] = @"false";
        deviceinfo[@"style"] = @"ios";
        deviceinfo[@"name"] = currentDevice.name;
        deviceinfo[@"mode"] = currentDevice.platformString;
        deviceinfo[@"osversion"] = currentDevice.systemVersion;
        deviceinfo[@"ncdevid"] = [EMMDeviceInfo currentDeviceInfo].UUID;
        deviceinfo[@"wfaddress"] = currentDevice.macaddress;
        data[@"deviceinfo"] = deviceinfo;
        
        data[@"serviceid"] = @"UMSSOGetApps";
        
        return data;
    }
    else {
        
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *appcontext = [NSMutableDictionary dictionary];
        appcontext[@"appid"] = @"sso";
        appcontext[@"groupid"] = @"";
        appcontext[@"userid"] = @"";
        appcontext[@"user"] = username;
        appcontext[@"pass"] = password;
        appcontext[@"token"] = @"";
        appcontext[@"tabid"] = @"";
        appcontext[@"funcid"] = @"";
        appcontext[@"usertype"] = usertype;
        appcontext[@"username"] = userName;
        data[@"appcontext"] = appcontext;
        
        NSMutableDictionary *servicecontext = [NSMutableDictionary dictionary];
        servicecontext[@"actionid"] = @"";
        servicecontext[@"callback"] = @"";
        servicecontext[@"viewid"] = @"";
        servicecontext[@"actionname"] = @"";
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"model"] = currentDevice.platformString;
        params[@"usercode"] = username;
        params[@"screensize"] = @"";
        params[@"wifiprotocol"] = @"";
        params[@"compass"] = @"";
        params[@"osversion"] = currentDevice.systemVersion;
        params[@"orientationsensor"] = @"";
        params[@"deviceid"] = UUID;
        params[@"distancesensors"] = @"";
        params[@"managestatus"] = @"";
        params[@"batterycapacity"] = @"";
        params[@"batteryvoltage"] = @"";
        params[@"style"] = @"ios";
        params[@"screenresolution"] = @"";
        params[@"batteryleft"] = batteryleft;
        params[@"os"] = @"iOS";
        params[@"phonenumber"] = @"";
        params[@"devicestatus"] = @"";
        params[@"rearcameraresolution"] = @"";
        params[@"lightsensor"] = @"";
        params[@"imei"] = @"";
        params[@"cpu"] = @(currentDevice.cpuFrequency).stringValue;
        params[@"mdmversion"] = appVersion;
        params[@"memory"] = memory;
        params[@"wifiip"] = SSID;
        params[@"bluetoothprotocol"] = @"";
        params[@"wifimac"] = currentDevice.macaddress;
        params[@"gyro"] = @"";
        params[@"rooted"] = @"";
        params[@"pixeldensity"] = @"";
        params[@"devicename"] = currentDevice.name;
        params[@"frontcameraresolution"] = @"";
        params[@"uuid"] = UUID;
        params[@"storage"] = storage;
        params[@"serialnumber"] = UUID;
        params[@"bprotected"] = @"N";
        params[@"companyid"] = companyid.length ? companyid : @"";
        servicecontext[@"params"] = params;
        data[@"servicecontext"] = servicecontext;
        
        NSMutableDictionary *deviceinfo = [NSMutableDictionary dictionary];
        deviceinfo[@"devid"] = UUID;
        deviceinfo[@"serialnumber"] = UUID;
        deviceinfo[@"wifi"] = SSID;
        deviceinfo[@"appversion"] = appVersion;
        deviceinfo[@"isRoot"] = @"";
        data[@"deviceinfo"] = deviceinfo;
        
        data[@"serviceid"] = @"UMSSOGetApps";
        
        return data;
    }
}

- (void)modifyAvatarWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"parameters"] = @{
                                 @"tp": @"",
                                 @"usercode": params[@"usercode"],
                                 };
    theParams[@"image"] = params[@"image"];
    theParams[@"imageName"] = params[@"imageName"];
    theParams[@"name"] = @"imginfo";
    [super sendImageWithParams:theParams success:success failure:failure];
}

@end
