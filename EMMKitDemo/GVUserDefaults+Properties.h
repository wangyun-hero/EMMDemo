//
//  GVUserDefaults+Properties.h
//  CreditInvestigation
//
//  Created by 缺月梧桐 on 2016/12/19.
//  Copyright © 2016年 yishilvren. All rights reserved.
//


#import "GVUserDefaults.h"
#define WYUserDefault [GVUserDefaults standardUserDefaults]

@interface GVUserDefaults (Properties)

// 是否是首次登陆
@property(nonatomic,assign) BOOL notFirstLog;
@property(nonatomic,copy) NSString *version;
@property(nonatomic,copy) NSString *USER_NAME;
@property(nonatomic,copy) NSString *typeString;
@property(nonatomic,copy) NSString *email;
@property(nonatomic,copy) NSString *USER_MOBNUM;
@end
