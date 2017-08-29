//
//  HGHTTPDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/8/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGHTTPDataAccessor.h"
#import "EMMEncrypt.h"
#import "AFNetworking.h"
#import "EMMApplicationContext.h"
#import "UIDevice-Hardware.h"
#import "EMMDeviceInfo.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SvUDIDTools.h"
#import "NSString+Util.h"
#import<CommonCrypto/CommonDigest.h>

@implementation HGHTTPDataAccessor

- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    if ([self.request isEqualToString:@"registerEMM"]) {
        // 注册
        [self registerEMMWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"retrievePWD"]){
        // 找回密码
        [self requestWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"confirmCode"]){
        // 确认验证码
        [self requestWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"resetPWD"]){
        // 重置密码
        [self requestWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"modifyPWD"]){
        // 修改密码
        [self requestWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"verifyMA"]){
        // 验证MA
//        [self  MA_verifyMAWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"MA_Login"]){
        // 注册
        [self MA_loginWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"MA_Register"]){
        // 注册
        [self MA_registerWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"MA_GetToken"]){
        // 找回密码：获取 token
        [self MA_getTokenWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"MA_VerifyCode"]){
        // 找回密码：验证
        [self MA_verifyCodeWithParams:params success:success failure:failure];
    }
    else if([self.request isEqualToString:@"MA_ResetPassword"]){
        // 找回密码：重置密码
        [self MA_modifyPwdWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"MA_UpdateUserInfo"]){
        // 更新用户信息
        [self MA_updateUserInfoWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"MA_verifyPhoneNum"]){
        // 验证手机号
        [self MA_verifyPhoneNumWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"MA_registerVerifyCode"]){
        // 注册校验码
        [self MA_registerVerifyCodeWithParams:params success:success failure:failure];
    }else if ([self.request isEqualToString:@"MA_GetBleCardRandom"]){
        //获取蓝牙卡随机数
        [self MA_getBleCardRandomWithParams:params success:success failure:failure];
    }else if ([self.request isEqualToString:@"MA_bandCard"]){
        //绑定蓝牙卡
        [self MA_bandCardWithParams:params success:success failure:failure];
    }else if([self.request isEqualToString:@"MA_onlineHelp"]){
        // 客户服务-在线帮助
        [self MA_onlineHelpWithParams:params success:success failure:failure];
    }
    else if ([self.request isEqualToString:@"MA_onlineHelpList"]){
        // 客户服务-在线帮助列表
        [self MA_onlineHelpListWithParams:params success:success failure:failure];
    }
}

#pragma mark - EMM 注册

- (void)registerEMMWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone = params[@"phone"];
    NSString *password = params[@"password"];
    NSString *name = params[@"name"];
    NSString *cardtype = params[@"cardtype"];
    NSString *cardid = params[@"cardid"];
    
    NSDictionary *parameters = @{
                                 @"code": phone,
                                 @"pwd": password,
                                 @"name": name,
                                 @"cardtype": cardtype,
                                 @"cardid": cardid,
                                 @"tel": phone,
                                 @"email": @"",
                                 @"source": @"",
                                 @"orgid": @"",
                                 @"flag": @"1",
                                 };
    NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataString = [EMMEncrypt encryptDES:dataString];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"des",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

- (void)requestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataString = [EMMEncrypt encryptDES:dataString];
    
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"des",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

#pragma mark - MA 接口

/**
 *  注册
 *
 *  @param phone    电话号码
 *  @param password 密码
 */
- (void)MA_registerWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone     = params[@"phone"];
    NSString *password  = [self md5:params[@"password"]];
    NSString *name      = params[@"name"];
    NSString *cardtype  = params[@"cardtype"];
    NSString *cardid    = params[@"cardid"];
    NSString *usertypecd = params[@"userTypecd"];
    NSString *orgistcd = params[@"orgIstcd"];
    NSString *etpsUNSocialCrecd = params[@"etpsUNSocialCrecd"];
    NSString *etpsNm = params[@"etpsNm"];

    NSDictionary *parameters = @{
                                 @"userId": phone,
                                 @"userPw": password,
                                 @"userName": name,
                                 @"credTypecd": cardtype,
                                 @"credNo": cardid,
                                 @"mobileUserFlag": @"2",
                                 @"userResource": @"2",
                                 @"userTypecd":usertypecd,
                                 @"orgIstcd":orgistcd,
                                 @"etpsUNSocialCrecd":etpsUNSocialCrecd,
                                 @"etpsNm":etpsNm
                                 };
    
    NSString *dataString = [self MA_composeParamsWithAction:@"addUser" userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
    
}

/**
 *  登录
 *
 *  @param phone    电话号码
 *  @param password 密码
 */
- (void)MA_loginWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone     = params[@"username"];
    NSString *password  = params[@"password"];
    NSString *iscard = params[@"iscard"];
    NSDictionary *parameters = [[NSDictionary alloc] init];
    
    if (iscard && [iscard isEqualToString:@"true"]) {
        //蓝牙卡登录
        NSString * random = [[EMMApplicationContext defaultContext] objectForKey:@"random"];
        NSString * signData = [[EMMApplicationContext defaultContext] objectForKey:@"signData"];
        NSString * jssionId = [[EMMApplicationContext defaultContext] objectForKey:@"jssionId"];
        NSString * lt = [[EMMApplicationContext defaultContext] objectForKey:@"lt"];
        NSString * serverDate = [[EMMApplicationContext defaultContext] objectForKey:@"serverDate"];
        NSString * certNo = [[EMMApplicationContext defaultContext] objectForKey:@"certNo"];
        
        parameters = @{
                       @"user": phone,
                       @"userId": phone,
                       @"pass": password,
                       @"icCard":phone,
                       @"userPin":password,
                       @"certNo":certNo,
                       @"signData":signData,
                       @"jssionid":jssionId,
                       @"lt":lt,
                       @"serverDate":serverDate,
                       @"random":random,
                       @"_eventId":@"submit"
                       };
    
    }else{
        //正常登录
        parameters = @{
                       @"user": phone,
                       @"pass": password,
                       };
    }
    
    NSString *dataString = [self MA_composeParamsWithAction:@"login" userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
    
}

/**
 *  找回密码：获取 token
 *
 *  @param phone 电话号码
 */
- (void)MA_getTokenWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone = params[@"usercode"];
    NSDictionary *parameters = @{ @"userMobnum": phone };
    
    NSString *dataString = [self MA_composeParamsWithAction:@"getToken" userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

/**
 *  找回密码：验证 token
 *
 *  @param phone 电话号码
 *  @param token getToken 请求中返回的 token
 *  @param code  验证码
 */
- (void)MA_verifyCodeWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone = params[@"usercode"];
    NSString *token = params[@"token"]?:@"";
    NSString *code  = params[@"randomcode"];
    NSDictionary *parameters = @{
                                 @"userMobnum": phone,
                                 @"token": token,
                                 @"messageCode": code,
                                 };
    
    NSString *dataString = [self MA_composeParamsWithAction:@"verifyCode" userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

/**
 *  找回密码：设置新密码
 *
 *  @param phone    电话号码
 *  @param token    getToken 请求中返回的 token
 *  @param password 新密码
 */
- (void)MA_modifyPwdWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone     = params[@"phone"];
    NSString *token     = params[@"token"];
    NSString *password  = params[@"password"];
    NSDictionary *parameters = @{
                                 @"userMobnum": phone,
                                 @"token": token,
                                 @"userPw": password,
                                 };
    NSString *dataString = [self MA_composeParamsWithAction:@"modifyPwd" userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

/**
 *  修改个人信息
 *
 *  @param phone        电话号码
 *  @param password     旧密码
 *  @param newPassword  新密码
 *  @param newName      新名称
 *  @param newCardtype  新证件类型
 *  @param newCardid    新证件号码
 */
- (void)MA_updateUserInfoWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone         = params[@"username"];
    NSString *password      = [self md5:params[@"password"]];
    NSString *newPassword   = [self md5:params[@"newPassword"]];
    NSString *newName       = params[@"newName"];
    NSString *newCardtype   = params[@"newCardtype"];
    NSString *newCardid     = params[@"newCardid"];
    
    NSDictionary *parameters = @{
                                 @"userInfoUpdateType": @"0",   // 0.密码修改；1.注册信息修改
                                 @"userId": phone,
                                 @"userOldPw": password ?: @"",
                                 @"userNewPw": newPassword ?: @"",
                                 @"newUserName": newName ?: @"",
                                 @"newCredTypecd": newCardtype ?: @"",
                                 @"newCredNo": newCardid ?: @"",
                                 };
    NSString *dataString = [self MA_composeParamsWithAction:@"updateUserInfoByUserId" userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

// 注册-验证手机号
- (void)MA_verifyPhoneNumWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSString *dataString = [self MA_composeParamsWithAction:@"getNraUserInfoByMobNum" userParams:params andUser:@""];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];

}

// 注册-获取验证码
- (void)MA_registerVerifyCodeWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSString *dataString = [self MA_composeParamsWithAction:@"getMsgCode" userParams:params andUser:@""];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];

}

//获取蓝牙卡随机数
-(void)MA_getBleCardRandomWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSString *dataString = [self MA_composeParamsWithAction:@"getFormWithCard" userParams:params andUser:@""];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
    
}
//绑定或解绑蓝牙卡
-(void)MA_bandCardWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    
    NSString *phone         = params[@"userId"];
    NSString *password      = [self md5:params[@"password"]];
    NSString *cardFlag      = params[@"cardFlag"];
    NSString *deptNm        = params[@"deptNm"];
    NSString *etpsNm        = params[@"etpsNm"];
    NSString *icCardNo      = params[@"icCardNo"];
    NSString *istNm         = params[@"istNm"];
    NSString *istNum        = params[@"istNum"];
    NSString *orgIstcd      = params[@"orgIstcd"];
    NSString *etpsUNSocialCrecd = params[@"etpsUNSocialCrecd"];
    NSString *userName      = params[@"userName"];
    NSString *singnatureData = params[@"singnatureData"]?:@"";
    NSString *actionName = @"cardManager";
    NSString *userType = @"1";
    if ([cardFlag isEqualToString:@"1"]) {
//        actionName = @"cancelNraUser";
        userType = @"2";
    }
    
    NSDictionary *parameters = @{
                                 @"userId": phone,
                                 @"userPw": password ?: @"",
                                 @"cardFlag": cardFlag,
                                 @"deptNm": deptNm ?: @"",
                                 @"etpsNm": etpsNm ?: @"",
                                 @"icCardNo": icCardNo,
                                 @"istNm": istNm ?: @"",
                                 @"istNum": istNum ?: @"",
                                 @"orgIstcd" : orgIstcd,
                                 @"etpsUNSocialCrecd":etpsUNSocialCrecd,
                                 @"userName" : userName ?: @"",
                                 @"userTypecd" : userType,
                                 @"signatureData" : singnatureData
                                 };
    NSString *dataString = [self MA_composeParamsWithAction:actionName userParams:parameters andUser:phone];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
    
}

#pragma mark - 在线帮助
- (void)MA_onlineHelpWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure{
    NSString *user = params[@"username"];
    NSString *dataString = [self MA_composeParamsWithAction:@"getTypeList" userParams:params andUser:user];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
    
}

- (void)MA_onlineHelpListWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure{
    NSString *user = params[@"username"];
    NSString *dataString = [self MA_composeParamsWithAction:@"getHelpList" userParams:params andUser:user];
    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"none",
                                 @"data": dataString
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];

    
}


#pragma mark - MA参数
- (NSString *)MA_composeParamsWithAction:(NSString *)action userParams:(NSDictionary *)userParams andUser:(NSString *)user {
    
//    NSString *versionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
    
    NSString *viewId = @"com.eport.userws.HGUserWS";
    NSString *appId = @"HGUserWebService";
    if ([action isEqualToString:@"login"] || [action isEqualToString:@"getFormWithCard"]) {
        
        appId = @"HGMAServer";
        viewId = @"com.yonyou.uap.haiguan.ApplyController";
    }
    if ([action isEqualToString:@"cardManager"] || [action isEqualToString:@"cancelNraUser"]) {
//        appId = @"hgmobusermanagerapp";
        viewId = @"com.eport.userws.HGUserManagerWS";
    }
    if([action isEqualToString:@"getTypeList"] || [action isEqualToString:@"getHelpList"]){
        viewId = @"com.yonyou.userhelp.UserHelp";
        appId = @"userhelpapp";
    }
    
    NSDictionary *appcontext = @{
                                 @"appversion": @"1",
                                 @"appid": appId,
                                 @"user":user
                                 };
    NSDictionary *servicecontext = @{
                                     @"actionid": @"umCommonService",
                                     @"actionname": action,
                                     @"action": action,
                                     @"callback": @"nothing",
                                     @"viewid": viewId,
                                     @"params": userParams,
                                     };
    NSDictionary *deviceinfo = @{
                                 @"style": @"ios",
                                 @"appversion": @"1",
                                 @"devid": UUID
                                 };
    NSDictionary *params = @{
                             @"appcontext": appcontext,
                             @"servicecontext": servicecontext,
                             @"deviceinfo": deviceinfo,
                             @"serviceid": @"umCommonService"
                             };
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return  jsonString;
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



@end
