//
//  EMMCerManager.h
//  SummerDemo
//
//  Created by Chenly on 2016/12/26.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EMMCerManager : NSObject

@property (nonatomic, assign) BOOL allowInvalidCertificates;// 允许自制证书
@property (nonatomic, assign) BOOL validatesDomainName;     // 需要验证证书

@property (nonatomic, copy) NSSet<NSData *> *pinnedCertificates; // 证书，nil 时，从 mainBundle 下读取所有.cer 文件

+ (instancetype)sharedManager;

@end
