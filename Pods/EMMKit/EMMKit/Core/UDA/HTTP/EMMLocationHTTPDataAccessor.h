//
//  EMMLocationHTTPDataAccessor.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMHTTPDataAccessor.h"

@interface EMMLocationHTTPDataAccessor : EMMHTTPDataAccessor

/**
 获取定位指令:requestCommand
 发送坐标信息:sendLocationInfo
 {
    "location": <CLLocation *>,
    "command": "cmd",
    "track": @(YES),
 }
 发送设备获取策略方案:sendStrategyprogram
 发送设备检测结果:sendResultfeedback
 发送设备运行情况:sendRunningfeedback
 发送 Wifi 信息:sendWifiInfo
 */

@end
