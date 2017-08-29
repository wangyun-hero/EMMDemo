//
//  EMMLocationManager.m
//  LocationInBackground
//
//  Created by Chenly on 16/6/17.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMLocationManager.h"
#import "UIAlertController+EMM.h"

@interface EMMLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, readonly) CLLocationManager *locationManager;

@end

@implementation EMMLocationManager

@synthesize locationManager = _locationManager;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static EMMLocationManager *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[EMMLocationManager alloc] init];
    });
    return sSharedInstance;
}

- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (CLAuthorizationStatus)status {
    return [CLLocationManager authorizationStatus];
}

- (void)requestAlwaysAuthorizationAndStart {
    
    switch (self.status) {
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager requestAlwaysAuthorization];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            [UIAlertController showAlertWithTitle:@"未允许后台定位" message:@"请打开设置开启后台定位" cancelButtonTitle:@"取消" otherButtonTitle:@"打开设置" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
                
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)startUpdatingLocation {
    [self requestAlwaysAuthorizationAndStart];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
    _isUpdating = NO;
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0) {
            self.locationManager.allowsBackgroundLocationUpdates = YES;
        }
        [self.locationManager startUpdatingLocation];
        _isUpdating = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    self.lastLocation = [locations objectAtIndex:0];
    self.dateLastLocate = [NSDate date];
}

@end
