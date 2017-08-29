//
//  EMMLocationService.m
//  EMMKitDemo
//
//  Created by Chenly on 16/6/22.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMLocationService.h"
#import "EMMDataAccessor.h"
#import "EMMLocationManager.h"

#ifdef DEBUG
#define DebugLog(s, ...) NSLog(s, ##__VA_ARGS__)
#else
#define DebugLog(s, ...)
#endif

@implementation EMMLocationService
{
    NSTimer *_timer;
    
    BOOL _needSendLocation;
    
    NSTimeInterval _timeIntervalRequestCommand;
    NSTimeInterval _timeIntervalSendLocation;
    NSTimeInterval _timeIntervalSendStrategyprogram;
    NSTimeInterval _timeIntervalSendWifi;
    NSTimeInterval _timeIntervalSendRunningfeedback;
    NSTimeInterval _timeIntervalSendResultfeedback;
    
    NSDate *_lastDateRequestCommand;
    NSDate *_lastDateSendLocation;
    NSDate *_lastDateSendStrategyprogram;
    NSDate *_lastDateSendWifi;
    NSDate *_lastDateSendRunningfeedback;
    NSDate *_lastDateSendResultfeedback;
}

static NSTimeInterval kTimeInterval = 10; // 默认定时间隔
static NSString * const kTrackingFlag = @"DeviceTrackFlag"; // 轨迹追踪的命令

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static EMMLocationService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMLocationService alloc] init];
    });
    return sSharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        // 设置默认发送信息间隔
        _timeIntervalRequestCommand = 10;       // 默认定时间隔
        _timeIntervalSendLocation = 60 * 5;     // 默认发送定位定时间隔
        _timeIntervalSendStrategyprogram = 0;
        _timeIntervalSendWifi = 0;
        _timeIntervalSendRunningfeedback = 0;
        _timeIntervalSendResultfeedback = 0;
    }
    return self;
}

/**
 *  开始定位服务
 */
- (void)beginLocationService {
    
    if (self.isOpen) {
        return;
    }
    
    self.isOpen = YES;
    if (!_timer || _timer.valid) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:kTimeInterval
                                                  target:self
                                                selector:@selector(handleTimer)
                                                userInfo:nil
                                                 repeats:YES];
    }
    [[EMMLocationManager sharedManager] startUpdatingLocation];
}

- (void)handleTimer {

    NSDate *currentDate = [NSDate date];
    
    if (_timeIntervalRequestCommand > 0 && (!_lastDateRequestCommand || [currentDate timeIntervalSinceDate:_lastDateRequestCommand] > _timeIntervalRequestCommand)) {
        // 时间间隔设定值大于0，且距离上次发送请求的时间间隔大于设定值
        [self requestCommand];
        _lastDateRequestCommand = currentDate;
    }
    
    if (_timeIntervalSendLocation > 0 && (!_lastDateSendLocation || [currentDate timeIntervalSinceDate:_lastDateSendLocation] > _timeIntervalSendLocation)) {
        
        if (_needSendLocation) {
            [self sendLocation];
            _lastDateSendLocation = currentDate;
        }
    }
    
    if (_timeIntervalSendStrategyprogram > 0 && (!_lastDateSendStrategyprogram || [currentDate timeIntervalSinceDate:_lastDateSendStrategyprogram] > _timeIntervalSendStrategyprogram)) {
        
        [self  sendStrategyprogram];
        _lastDateSendStrategyprogram = currentDate;
    }
    
    if (_timeIntervalSendWifi > 0 && (!_lastDateSendWifi || [currentDate timeIntervalSinceDate:_lastDateSendWifi] > _timeIntervalSendWifi)) {
        
        [self  sendWifiInfo];
        _lastDateSendWifi = currentDate;
    }
    
    if (_timeIntervalSendRunningfeedback > 0 && (!_lastDateSendRunningfeedback || [currentDate timeIntervalSinceDate:_lastDateSendRunningfeedback] > _timeIntervalSendRunningfeedback)) {
        
        [self sendRunningfeedback];
        _lastDateSendRunningfeedback = currentDate;
    }
    
    if (_timeIntervalSendResultfeedback > 0 && (!_lastDateSendResultfeedback || [currentDate timeIntervalSinceDate:_lastDateSendResultfeedback] > _timeIntervalSendResultfeedback)) {
        
        [self sendResultfeedback];
        _lastDateSendResultfeedback = currentDate;
    }
}

/**
 *  结束定位服务
 */
- (void)stopLocationService {
    
    if (!self.isOpen) {
        return;
    }
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    [[EMMLocationManager sharedManager] stopUpdatingLocation];
    self.isOpen = NO;
}

- (void)requestCommand {
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.location" request:@"requestCommand"];
    [dataAccessor sendRequestWithParams:nil success:^(id result) {
        
        DebugLog(@"获取定位指令成功:%@", result);
        if (!result) {
            return;
        }
        
        NSString *command = result[@"data"][@"command"];
        NSDictionary *params = result[@"data"][@"params"];
        [self excuteCommand:command params:params];
        
    } failure:^(NSError *error) {        
        DebugLog(@"获取定位指令失败:%@", error);
    }];
}

- (void)excuteCommand:(NSString *)command params:(NSDictionary *)params {
    
    if ([command isEqualToString:@"None"]) {
        return;
    }
    else if ([command isEqualToString:@"DeviceTrackFlag"]) {
        // 轨迹跟踪
        BOOL trackFlag = [params[@"trackflag"] boolValue];
        _needSendLocation = trackFlag;
    }
    else if ([command isEqualToString:@"LatestPosition"]) {
        // 发送最后一次定位信息
        [self sendLastLocation];
    }
    else if ([command isEqualToString:@"ClientSetInter"]) {
        // 修改各类信息发送间隔
        NSString *instructionFetch = params[@"instructionFetchInter"];  //设备管理指令获取周期
        NSString *positionTrack = params[@"positionTrackInter"];        //设备物理位置跟踪周期
        NSString *strategyprogram = params[@"strategyprogram"];         //设备获取策略方案周期
        NSString *resultfeedback = params[@"resultfeedback"];           //设备检测结果反馈周期
        NSString *runningfeedback = params[@"runningfeedback"];         //设备运行情况反馈周期
        
        if (instructionFetch) _timeIntervalRequestCommand = [instructionFetch floatValue];
        if (positionTrack) _timeIntervalSendLocation = [positionTrack floatValue];
        if (strategyprogram) _timeIntervalSendStrategyprogram = [strategyprogram floatValue];
        if (resultfeedback) _timeIntervalSendResultfeedback = [resultfeedback floatValue];
        if (runningfeedback) _timeIntervalSendRunningfeedback = [runningfeedback floatValue];
    }
}

/**
 *  发送定位信息
 */
- (void)sendLocation {
    CLLocation *location = [EMMLocationManager sharedManager].lastLocation;
    NSDictionary *params = @{
                             @"location": location,
                             @"command": kTrackingFlag,
                             @"track": @(YES),
                             };
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.location" request:@"sendLocationInfo"];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
    
        DebugLog(@"发送定位信息成功:%@", result);
        
    } failure:^(NSError *error) {
        
        DebugLog(@"发送定位信息失败:%@", error);
    }];
}

/**
 *  发送设备检测结果
 */
- (void)sendStrategyprogram {

    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.location" request:@"sendStrategyprogram"];
    [dataAccessor sendRequestWithParams:nil success:^(id result) {
    
        DebugLog(@"发送设备检测结果成功:%@", result);
        
    } failure:^(NSError *error) {
        
        DebugLog(@"发送设备检测结果失败:%@", error);
    }];
}

/**
 *  发送 WIFI 信息
 */
- (void)sendWifiInfo {

    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.location" request:@"sendWifiInfo"];
    [dataAccessor sendRequestWithParams:nil success:^(id result) {
    
        DebugLog(@"发送 WIFI 信息成功:%@", result);
        
    } failure:^(NSError *error) {
        
        DebugLog(@"发送 WIFI 信息失败:%@", error);
    }];
}

/**
 *  发送设备检测结果
 */
- (void)sendRunningfeedback {

    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.location" request:@"sendRunningfeedback"];
    [dataAccessor sendRequestWithParams:nil success:^(id result) {
    
        DebugLog(@"发送设备检测结果成功:%@",  result);
        
    } failure:^(NSError *error) {
        
        DebugLog(@"发送设备检测结果:%@", error);
    }];
}

/**
 *  发送设备运行情况
 */
- (void)sendResultfeedback {
    
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.location" request:@"sendResultfeedback"];
    [dataAccessor sendRequestWithParams:nil success:^(id result) {
    
        DebugLog(@"发送设备运行情况成功:%@",  result);
        
    } failure:^(NSError *error) {
        
        DebugLog(@"发送设备运行情况失败:%@", error);
    }];
}

/**
 *  发送最后一次定位信息
 */
- (void)sendLastLocation {
    [self sendLocation];
}

@end
