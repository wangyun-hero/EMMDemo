//
//  HGBandCardViewController.h
//  EMMKitDemo
//
//  Created by 振亚 姜 on 16/11/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
// 绑定蓝牙卡
@interface HGBandCardViewController : UIViewController

@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *userName;
@property (nonatomic,copy) NSString *userPw;
@property (nonatomic,copy) NSString *deptNm;
@property (nonatomic,copy) NSString *etpsNm;
@property (nonatomic,copy) NSString *istNm;
@property (nonatomic,copy) NSString *istNum;
@property (nonatomic,copy) NSString *orgIstcdFromRegister;
@property (nonatomic,copy) NSString *socialCrecdFromRegister;
@property (nonatomic, copy) NSString *fromSet;

@end
