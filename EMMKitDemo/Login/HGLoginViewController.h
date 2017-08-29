//
//  HGLoginViewController.h
//  EMMKitDemo
//
//  Created by 振亚 姜 on 16/6/24.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMProtocol.h"

@interface HGLoginViewController : UIViewController <EMMLoginCompletion>

typedef enum {
    HGLoginType_User = 0,  // 普通
    HGLoginType_Anonymity, // 匿名
    HGLoginType_Bluetooth  // 蓝牙
} HGLoginType;



@property (nonatomic,assign) NSInteger loginType; //操作类型
@property(nonatomic,copy) NSString *userName;
@property (nonatomic, readonly) NSDictionary *settings;
@property (nonatomic, copy) void (^completion)(BOOL success, id result);

- (instancetype)initWithSettings:(NSDictionary *)settings completion:(void (^)(BOOL success, id result))completion;
@end
