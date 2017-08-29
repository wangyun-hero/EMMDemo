//
//  IUMAPM.h
//  IUMAPM
//
//  Created by zm on 2017/5/24.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IUMAPM : NSObject

@property (nonatomic) BOOL logCollectLocation;

@property (nonatomic) BOOL logSendWiFiOnly;

@property (nonatomic, copy) NSString *logUploadServiceUrl;

@property (nonatomic, copy) NSArray *ignoreViewControllers;

@property (nonatomic, copy) NSArray *ignoreRequestUrls;

+ (IUMAPM *)defaultIUMAPM;

- (void)startWithappKey:(NSString *)appKey channelKey:(NSString *)channelKey;

- (void)logEvent:(NSString *)eventId eventParams:(NSString *)eventParams;


@end
