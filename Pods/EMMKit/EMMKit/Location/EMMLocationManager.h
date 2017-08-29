//
//  EMMLocationManager.h
//  LocationInBackground
//
//  Created by Chenly on 16/6/17.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface EMMLocationManager : NSObject

@property (nonatomic, readonly) CLAuthorizationStatus status;
@property (nonatomic, readonly) BOOL isUpdating;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) NSDate *dateLastLocate;

+ (instancetype)sharedManager;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
