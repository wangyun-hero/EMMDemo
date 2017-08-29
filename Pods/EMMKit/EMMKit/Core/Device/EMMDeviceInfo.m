//
//  EMMDeviceInfo.m
//  EMMFoundationDemo
//
//  Created by Chenly on 16/6/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMDeviceInfo.h"
#import "SAMKeychain.h"
#import <SystemConfiguration/CaptiveNetwork.h>

static NSString * const EMMKeychainService = @"UUID";
static NSString * const EMMKeychainAccessGroup = @"MCZPGE73NK.com.ufida.uap";

@implementation EMMDeviceInfo

+ (instancetype)currentDeviceInfo {
    static dispatch_once_t onceToken;
    static EMMDeviceInfo *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMDeviceInfo alloc] init];
    });
    return sSharedInstance;
}

#pragma mark - UUID

- (void)keychain_setPassword:(NSString *)password {
    
    NSError *error;
    [SAMKeychain setPassword:password forService:EMMKeychainService account:EMMKeychainAccessGroup error:&error];
}

- (NSString *)keychain_password {
    
    NSError *error;
    NSString *password = [SAMKeychain passwordForService:EMMKeychainService account:EMMKeychainAccessGroup error:&error];
    return password;
}

/**
 *  将 UUID 存入到 keychain 中作为唯一设备码使用
 *
 *  @return 硬件码
 */
- (NSString *)UUID {

    NSString *UUIDString = [self keychain_password];
    if (!UUIDString) {
        UUIDString = [NSUUID UUID].UUIDString;
        [self keychain_setPassword:UUIDString];
    }
    return UUIDString;
}

- (NSString *)SSID {
    
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [[dctySSID objectForKey:@"SSID"] lowercaseString];
    return ssid;
}

@end
