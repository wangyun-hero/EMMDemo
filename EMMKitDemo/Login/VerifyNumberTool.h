//
//  VerifyNumberTool.h
//  EMMKitDemo
//
//  Created by zm on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VerifyNumberTool : NSObject
/**
 *  验证手机号
 *
 *  @param number
 *
 *  @return
 */
+ (BOOL)verifyPhoneNumber:(NSString *)number;

/**
 *  验证身份证
 *
 *  @param number
 *
 *  @return 
 */
+ (BOOL)verifyIdentityNumber:(NSString *)number;

/**
 *  验证护照
 *
 *  @param number
 *
 *  @return 
 */
+ (BOOL)verifyPassportNumber:(NSString *)number;
/**
 *  验证密码
 *
 *  规则:必须包含字母数字且大于8位
 *
 *  @return
 */
+(BOOL)verifyPasswordNumber:(NSString *)number;
/**
 *  验证用户名
 *
 *  规则:只能是字母或数字
 *
 *  @return
 */
+(BOOL)verifyUserName:(NSString *)username;

/**
 *  验证组织机构代码
 *
 *  规则:9位数字或字母
 *
 *  @return
 */
+(BOOL)verifyOrganizationNumber:(NSString *)number;

/**
 *  统一社会信用代码
 *
 *  规则:18位数字或字母
 *
 *  @return
 */
+(BOOL)verifyCreditNumber:(NSString *)number;
@end
