//
//  MessageModel.h
//  EMMPortalDemo
//
//  Created by zm on 16/6/17.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, strong) NSString *messageName;
@property (nonatomic, strong) NSString *messageInfo;
@property (nonatomic, strong) NSString *messageDate;
@property (nonatomic, strong) NSString *messageImage;
@property (nonatomic,copy) NSString *messageUrl;
@property (nonatomic,copy) NSString *appId;
@property (nonatomic,assign)  NSInteger isRead;

- (void)parseDic:(NSDictionary *)dict;

@end
