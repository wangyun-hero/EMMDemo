//
//  SummerWebServiceHandle.m
//  SummerDemo
//
//  Created by zm on 16/8/4.
//  Copyright © 2016年 Yonyou. All rights reserved.
//
#define LOGIN_ACTION @"login"
#define NC_LOGIN @"ncLoginService"
#define SERVICE_ID  @"serviceid"
#define APP_CONTEXT @"appcontext"
#define DEVICE_INFO @"deviceinfo"
#define SERVICE_CONTEXT  @"servicecontext"

#define UMP_TP @"__UMP_TP"
#define UMP_DATA @"__UMP_DATA"

#define DES   @"des"
#define DES_GZIP @"des_gzip"
#define TP_NONE @"none"

#import "SummerWebServiceHandle.h"
#import "SummerWebSettingService.h"
#import "zlib.h"
#import "SummerInvocation.h"
#import "EMMDeviceInfo.h"
#import "SummerWebServiceProxy.h"
#import "UIDevice-Hardware.h"
#import "EMMEncrypt.h"
#import "EMMStorage.h"
#import <objc/runtime.h>

@interface SummerWebServiceHandle(){
    completionHandle _completionHandle;
    SummerInvocation *_invocation;
    BOOL isLogin;
}
@end

@implementation SummerWebServiceHandle

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerWebServiceHandle *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerWebServiceHandle alloc] init];
    });
    return sSharedInstance;
}

- (void)loginMaWebServiceHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler {
    _completionHandle = completionHandler;
    _invocation = invocation;
    isLogin = YES;
    
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    [self setWebSettingService:invocation];
    if (settingService.type == nil || [settingService.type isEqualToString:@""]){
        NSDictionary *errorInfo = @{@"ERROR_MSG":@"服务类型为空！登录请求需配置参数type:(nc/u8/xt)"};
        NSLog(@"服务类型为空！登录请求需配置参数type:(nc/u8/xt)");
        _completionHandle(errorInfo, NO);
    }
    else  if([settingService.type isEqualToString:@"nc"]){
        [self loginNC];
    }
    
}

- (void)loginNC{
    
    [SummerWebSettingService sharedInstance].type = @"nc";
    [SummerWebSettingService sharedInstance].viewid = @"";
    [SummerWebSettingService sharedInstance].serviceid = NC_LOGIN;
    [SummerWebSettingService sharedInstance].action = LOGIN_ACTION;
    
    [self callWebService];
}

- (void)callWebService{
    
    // 检查网络
    if(![SummerWebServiceProxy isNetReachable]){
        UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"网络提示" message:@"没有网络连接,请检查网络状态!"delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
        NSDictionary *errorInfo = @{@"ERROR_MSG":@"没有网络连接"};
        _completionHandle(errorInfo,NO);
    }
    
    // 网络参数
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    
    NSString *jsonData = [self getRequestBody:_invocation];
    NSString *tp = [SummerWebSettingService sharedInstance].tp;
    NSLog(@" \n 网络请求地址:%@ \n 加密方式:%@ \n 网络请求参数:%@", settingService.serverUrl,tp,jsonData);
    if([tp isEqualToString:DES]){//加密
        jsonData = [EMMEncrypt encryptDES:jsonData];
    }
    if ([tp isEqualToString:DES_GZIP]) {//加密 + 压缩
        NSData *zipData = [SummerWebServiceHandle gzipData:[jsonData dataUsingEncoding:NSUTF8StringEncoding]];
        jsonData = [zipData base64EncodedStringWithOptions:0];
    }
    jsonData = [self encodeURL:jsonData];
    NSString * jsonStr = [NSString stringWithFormat:@"tp=%@&data=%@",tp,jsonData];
    
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    [self startRequest:data url:settingService.serverUrl];
}

- (void)startRequest:(NSData *)requestBody url:(NSString *)url{
    [SummerWebServiceProxy requestNetMethod:@"POST" urlString:url requestBody:requestBody timeout:30.0f completionHandler:^(id result, BOOL succeed) {
        
        if (succeed) {
            NSString *json = result[@"data"];
            NSString *tp = result[@"tp"];
            if([tp isEqualToString:DES_GZIP]){
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:json options:NSDataBase64DecodingIgnoreUnknownCharacters];
                decodedData = [SummerWebServiceHandle uncompressZippedData:decodedData];
                
                json = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            }
            else if([tp isEqualToString:DES]){
                json = [EMMEncrypt decryptDES:json];
            }
            
            NSDictionary *resultDic = [SummerWebServiceHandle parseJson:json];
            id resultData = resultDic[@"resultctx"];
            
            if(isLogin && [resultData isKindOfClass:[NSDictionary class]]){
                SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
                [settingService setDict:resultData];
                isLogin = NO;
            }
            _completionHandle([SummerWebServiceHandle parseJson:json],succeed);
        }
        else {
            _completionHandle(result, succeed);
        }
    }];
}

- (void)postWebServiceHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler{
    _completionHandle = completionHandler;
    _invocation = invocation;
    NSString *url = invocation.params[@"url"];
    NSDictionary *header = invocation.params[@"header"];
    NSString *json = invocation.params[@"data"];
    CGFloat timeout = [invocation.params[@"timeout"] floatValue];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [SummerWebServiceProxy requestNetMethod:@"POST" urlString:url requestBody:data timeout:timeout header:header completionHandler:^(id result, BOOL succeed) {
        _completionHandle(result,succeed);
    }];
}

- (void)getWebServiceHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler{
    _completionHandle = completionHandler;
    _invocation = invocation;
    NSString *url = invocation.params[@"url"];
    NSDictionary *header = invocation.params[@"header"];
    NSString *json = invocation.params[@"data"];
    CGFloat timeout = [invocation.params[@"timeout"] floatValue];
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    [SummerWebServiceProxy requestNetMethod:@"GET" urlString:url requestBody:data timeout:timeout header:header completionHandler:^(id result, BOOL succeed) {
        _completionHandle(result,succeed);
    }];
}

- (void)callActionHandle:(SummerInvocation *)invocation completionHandler:(completionHandle)completionHandler{
    _completionHandle = completionHandler;
    _invocation = invocation;
    [self setWebSettingService:invocation];
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    [settingService setDict:invocation.params];
    
    if([invocation.params[SERVICE_ID] isEqualToString:@""] || !invocation.params[SERVICE_ID]){
        settingService.serviceid = @"umCommonService";
    }
    if([invocation.params[@"funcode"]isEqualToString:@""]||!invocation.params[@"funcode"]){
        settingService.funcode = settingService.appId;
    }
    [self callWebService];
}

- (void)setWebSettingService:(SummerInvocation *)invocation {
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    [settingService setDict:invocation.params];
    
    NSDictionary *userParams = invocation.params[@"params"];
    if (![userParams isKindOfClass:[NSDictionary class]]) {
        if ([userParams isKindOfClass:[NSString class]]) {
            NSData *data = [(NSString *)userParams dataUsingEncoding:NSUTF8StringEncoding];
            userParams = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        else {
            userParams = nil;
        }
    }
    NSString *mpVersion = userParams[@"mpVersion"];
    if (mpVersion && [mpVersion isKindOfClass:[NSString class]]) {
        settingService.mpVersion = mpVersion;
    }else
    {
        settingService.mpVersion = @"1";
    }
    NSString *appId = userParams[@"appid"];
    if (appId && [appId isKindOfClass:[NSString class]]) {
        
        settingService.appId = appId;
    }
    else {
        settingService.appId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    }
    
    settingService.httpType = [[NSString alloc] initWithFormat:@"http"];
    settingService.tp = settingService.tp.length? settingService.tp:DES_GZIP;
    settingService.devid = [[EMMDeviceInfo currentDeviceInfo] UUID];
    
    settingService.host = [[EMMStorage sharedInstance] valueForKey:@"host" fromLocation:EMMStorageLocationConfigure];
    settingService.port = [[EMMStorage sharedInstance] valueForKey:@"port" fromLocation:EMMStorageLocationConfigure];
    if([settingService.host rangeOfString:@"://"].length != 0){
        NSArray *components = [settingService.host componentsSeparatedByString:@"://"];
        NSString *hostStr = [components firstObject];
        settingService.httpType = hostStr;
        settingService.host = [components lastObject];
    }
    
    settingService.serverUrl =[NSString stringWithFormat:@"%@://%@:%@/umserver/core/", [SummerWebSettingService sharedInstance].httpType,settingService.host,settingService.port];
}

+ (NSDictionary *)parseJson:(NSString *)json {
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)json;
    }
    else if ([json isKindOfClass:[NSString class]]) {
        return [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                                               options:0
                                                 error:nil];
    }
    return nil;
}

#pragma mark - 拼接网络参数相关
- (NSString *)getRequestBody:(SummerInvocation *)invocation{
    NSMutableDictionary *json = [NSMutableDictionary new];
    [json setObject:[SummerWebSettingService sharedInstance].serviceid forKey:SERVICE_ID];
    [json setObject:[self getAppContext] forKey:APP_CONTEXT];
    [json setObject:[self getDeviceInfo] forKey:DEVICE_INFO];
    [json setObject:[self getServiceContext:invocation] forKey:SERVICE_CONTEXT];
    
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (NSDictionary *)getAppContext{
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    NSDictionary *appContext = @{@"appid":settingService.appId,
                                 @"tabid":settingService.tabid?settingService.tabid:@"",
                                 @"funcid":settingService.funcid?settingService.funcid:@"",
                                 @"funcode":settingService.funcode?settingService.funcode:settingService.appId,
                                 @"userid":settingService.userid?settingService.userid:@"",
                                 @"forelogin":settingService.forelogin?settingService.forelogin:@"",
                                 @"token":settingService.token?settingService.token:@"",
                                 @"pass":settingService.pass?settingService.pass:@"",
                                 @"sessionid":settingService.sessionid?settingService.sessionid:@"",
                                 @"groupid":settingService.groupid?settingService.groupid:@"",
                                 @"massotoken":settingService.massotoken?settingService.massotoken:@"",
                                 @"user":settingService.user?settingService.user:@"",
                                 @"devid":settingService.devid};
    return appContext;
}

- (NSDictionary *)getDeviceInfo{
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    NSString *uuid = [[EMMDeviceInfo currentDeviceInfo] UUID];
    NSString *ssid = [[EMMDeviceInfo currentDeviceInfo] SSID];
    ssid = ssid?ssid:@"";
    // [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
    NSDictionary *deviceInfo = @{@"style":@"ios",
                                 @"uuid":uuid,
                                 @"mac":uuid,
                                 @"wfaddress":uuid,
                                 @"bluetooth":@"",
                                 @"firmware":@"",
                                 @"ram":@"",
                                 @"rom":@"",
                                 @"imei":@"",
                                 @"imsi":@"",
                                 @"resolution":@"",
                                 @"pushtoken":settingService.pushtoken?settingService.pushtoken:@"",
                                 @"mode":[[UIDevice currentDevice] platformString],
                                 @"osversion":[[UIDevice currentDevice] systemVersion],
                                 @"appversion":settingService.mpVersion,
                                 @"lang":[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0],
                                 @"model":[[UIDevice currentDevice] model],
                                 @"categroy":[[UIDevice currentDevice] model],
                                 @"name":[[UIDevice currentDevice] name],
                                 @"screensize":@{@"width":[NSString stringWithFormat:@"%f",CGRectGetWidth([UIScreen mainScreen].bounds)],@"heigth":[NSString stringWithFormat:@"%f",CGRectGetHeight([UIScreen mainScreen].bounds)]},
                                 @"wifi":ssid,
                                 @"devid":uuid};
    return deviceInfo;
}

- (NSDictionary *)getServiceContext:(SummerInvocation *)invocation {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:invocation.params];
    [params removeObjectForKey:@"action"];
    [params removeObjectForKey:@"viewid"];
    [params removeObjectForKey:@"params"];
    
    params = [self parseDic:params];
    id userParams = invocation.params[@"params"];
    if ([userParams isKindOfClass:[NSString class]]) {
        userParams = [NSJSONSerialization JSONObjectWithData:[userParams dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    }
    if (userParams && [userParams isKindOfClass:[NSDictionary class]]) {
        [params setValuesForKeysWithDictionary:userParams];
    }
    
    SummerWebSettingService *settingService = [SummerWebSettingService sharedInstance];
    NSMutableDictionary *serviceContext = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                          @"actionname":settingService.action?settingService.action:@"",
                                                                                          @"viewid":settingService.viewid?settingService.viewid:@"",
                                                                                          @"actionid":@"",
                                                                                          @"callback":@"",
                                                                                          @"contextmapping":settingService.contextmapping?settingService.contextmapping:@"",
                                                                                          @"params":params.count>0?params:@""}];
    return serviceContext;
}

- (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                kCFAllocatorDefault,
                                                                                                (CFStringRef)string, NULL, CFSTR("?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
                                                                                                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    if (newString) {
        return newString;
    }
    return string;
}

// 将字典中的字典或者数组转为json
- (NSMutableDictionary *)parseDic:(NSMutableDictionary *)dic{
    for(NSString *key in [dic allKeys]){
        id value = dic[key];
        if([value isKindOfClass:[NSDictionary class]]){
            NSDictionary *dicValue = value;
            NSError *parseError = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:dicValue options:NSJSONWritingPrettyPrinted error:&parseError];
            NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [dic setObject:string forKey:key];
        }
    }
    return dic;
}


#pragma mark - 压缩、解压缩

+ (NSData *)uncompressZippedData:(NSData *)compressedData  {
    
    if ([compressedData length] == 0) return compressedData;
    
    unsigned full_length = (unsigned)[compressedData length];
    
    unsigned half_length = (unsigned)[compressedData length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    
    BOOL done = NO;
    
    int status;
    
    z_stream strm;
    
    strm.next_in = (Bytef *)[compressedData bytes];
    
    strm.avail_in = (uInt)[compressedData length];
    
    strm.total_out = 0;
    
    strm.zalloc = Z_NULL;
    
    strm.zfree = Z_NULL;
    
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = (uInt)([decompressed length] - strm.total_out);
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }
}

+ (NSData *)gzipData:(NSData *)pUncompressedData
{
    if (!pUncompressedData || [pUncompressedData length] == 0) {
        //        DLog(@"%s: Error: Can't compress an empty or nil NSData object",__func__);
        return nil;
    }
    
    z_stream zlibStreamStruct;
    zlibStreamStruct.zalloc = Z_NULL;
    zlibStreamStruct.zfree = Z_NULL;
    zlibStreamStruct.opaque = Z_NULL;
    zlibStreamStruct.total_out = 0;
    zlibStreamStruct.next_in = (Bytef *)[pUncompressedData bytes];
    zlibStreamStruct.avail_in = (uInt)[pUncompressedData length];
    
    int initError = deflateInit2(&zlibStreamStruct, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY);
    if (initError != Z_OK) {
        NSString *errorMsg = nil;
        switch (initError) {
            case Z_STREAM_ERROR:
                errorMsg = @"Invalid parameter passed in to function.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Insufficient memory.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        //        DLog(@"%s:deflateInit2() Error: \"%@\" Message: \"%s\"",__func__,errorMsg,zlibStreamStruct.msg);
        return nil;
    }
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:[pUncompressedData length] * 1.01 + 21];
    
    int deflateStatus;
    do {
        zlibStreamStruct.next_out = [compressedData mutableBytes] + zlibStreamStruct.total_out;
        zlibStreamStruct.avail_out = [compressedData length] - zlibStreamStruct.total_out;
        deflateStatus = deflate(&zlibStreamStruct, Z_FINISH);
        
    } while (deflateStatus == Z_OK);
    
    if (deflateStatus != Z_STREAM_END)
    {
        NSString *errorMsg = nil;
        switch (deflateStatus) {
            case Z_ERRNO:
                errorMsg = @"Error occured while reading file.";
                break;
            case Z_STREAM_ERROR:
                errorMsg = @"The stream state was inconsistent (e.g., next_in or next_out was NULL).";
                break;
            case Z_DATA_ERROR:
                errorMsg = @"The deflate data was invalid or incomplete.";
                break;
            case Z_MEM_ERROR:
                errorMsg = @"Memory could not be allocated for processing.";
                break;
            case Z_BUF_ERROR:
                errorMsg = @"Ran out of output buffer for writing compressed bytes.";
                break;
            case Z_VERSION_ERROR:
                errorMsg = @"The version of zlib.h and the version of the library linked do not match.";
                break;
            default:
                errorMsg = @"Unknown error code.";
                break;
        }
        //        DLog(@"%s:zlib error while attempting compression: \"%@\" Message: \"%s\"", __func__, errorMsg, zlibStreamStruct.msg);
        deflateEnd(&zlibStreamStruct);
        return nil;
    }
    deflateEnd(&zlibStreamStruct);
    [compressedData setLength:zlibStreamStruct.total_out];
    //    DLog(@"%s: Compressed file from %lu B to %lu B", __func__, (unsigned long)[pUncompressedData length], (unsigned long)[compressedData length]);
    return compressedData;
}

@end
