//
//  EMMLocationHTTPDataAccessor.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMLocationHTTPDataAccessor.h"
#import "EMMDeviceInfo.h"
#import "WGS84TOGCJ02.h"
#import "EMMApplicationContext.h"
#import <CoreLocation/CoreLocation.h>

@implementation EMMLocationHTTPDataAccessor

- (void)sendRequestWithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {

    NSMutableDictionary *theParams = [NSMutableDictionary dictionary];
    
    NSDictionary *parameters = [self parametersForRequestWithParams:params];
    NSString *data = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    theParams[@"httpMehod"] = @"POST";
    theParams[@"parameters"] = @{
                                 @"tp": @"des",
                                 @"data": data,
                                 };
    [super sendRequestWithParams:theParams success:success failure:failure];
}

#pragma mark - 定位服务

- (NSString *)currentDateString {
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [df stringFromDate:[NSDate date]];
}

/**
 *  装填 HTTPBody
 */
- (NSDictionary *)parametersForRequestWithParams:(NSDictionary *)params {
    
    NSString *UUID = [EMMDeviceInfo currentDeviceInfo].UUID;
    NSString *SSID = [EMMDeviceInfo currentDeviceInfo].SSID;
    NSString *currentDate = [self currentDateString];
    if ([self.request isEqualToString:@"requestCommand"]) {
        // 获取定位指令
        return @{};
    }
    else if ([self.request isEqualToString:@"sendLocationInfo"]) {
        // 发送坐标信息
        CLLocation *loc = params[@"location"];
        NSString *command = params[@"command"];
        BOOL track = [params[@"track"] boolValue];
        Location location = transformFromWGSToGCJ(LocationMake(loc.coordinate.latitude, loc.coordinate.longitude));
        
        return @{
                 @"time": currentDate,
                 @"lng": @(location.lng),
                 @"lat": @(location.lat),
                 @"os": @"ios",
                 @"command": command,
                 @"trackflag": @(track),
                 @"deviceid": UUID
                 };
    }
    else if ([self.request isEqualToString:@"sendStrategyprogram"]) {
        // 发送设备获取策略方案
        return @{
                 @"command": @"InstallProfile",
                 @"date": currentDate,
                 @"deviceid": UUID,
                 };
    }
    else if ([self.request isEqualToString:@"sendResultfeedback"]) {
        // 发送设备检测结果
        return @{
                 @"command": @"ProfileList",
                 @"date": currentDate,
                 @"deviceid": UUID,
                 };
    }
    else if ([self.request isEqualToString:@"sendRunningfeedback"]) {
        // 发送设备运行情况
        return @{
                 @"command": @"DeviceInformation",
                 @"date": currentDate,
                 @"deviceid": UUID,
                 };
    }
    else if ([self.request isEqualToString:@"sendWifiInfo"]) {
        // 发送 Wifi 信息
        return @{
                 @"os": @"ios",
                 @"wifi": currentDate,  // TODO:
                 @"deviceid": SSID,
                 };
    }
    return @{};
}

@end
