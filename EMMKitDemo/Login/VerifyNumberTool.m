//
//  VerifyNumberTool.m
//  EMMKitDemo
//
//  Created by zm on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "VerifyNumberTool.h"

@implementation VerifyNumberTool

+ (BOOL)verifyPhoneNumber:(NSString *)number{
    //  前三位为以下数值组合开头：130、131、132、133、134、135、136、137、138、139、150、151、152、153、155、156、157、158、159、170、171、176、178、180、181、182、183、184、185、186、187、188、189
    NSString* regex = @"^((13|15|18)[0-9]|170|171|176|177|178)\\d{8}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:number];
}

+(BOOL)verifyUserName:(NSString *)username{
    NSString *regex = @"[a-zA-Z\u4e00-\u9fa5| |·]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:username];
}

+ (BOOL)verifyIdentityNumber:(NSString *)number{
    //1. 长度必须是18位，前17位必须是数字，第十八位可以是数字或X
    //2. 前两位必须是以下情形中的一种：11,12,13,14,15,21,22,23,31,32,33,34,35,36,37,41,42,43,44,45,46,50,51,52,53,54,61,62,63,64,65,71,81,82,91
    //3. 第7到第14位出生年月日。第7到第10位为出生年份；11到12位表示月份，范围为01-12；13到14位为合法的日期
    //4. 第17位表示性别，双数表示女，单数表示男
    //5. 第18位为前17位的校验位
    //算法如下：
    //（1）校验和 = (n1 + n11) * 7 + (n2 + n12) * 9 + (n3 + n13) * 10 + (n4 + n14) * 5 + (n5 + n15) * 8 + (n6 + n16) * 4 + (n7 + n17) * 2 + n8 + n9 * 6 + n10 * 3，其中n数值，表示第几位的数字
    //（2）余数 ＝ 校验和 % 11
    //（3）如果余数为0，校验位应为1，余数为1到10校验位应为字符串“0X98765432”(不包括分号)的第余数位的值（比如余数等于3，校验位应为9）
    //6. 出生年份的前两位必须是19或20
    number = [number stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([number length] != 18) {
        return NO;
    }
    NSString *mmdd = @"(((0[13578]|1[02])(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)(0[1-9]|[12][0-9]|30))|(02(0[1-9]|[1][0-9]|2[0-8])))";
    NSString *leapMmdd = @"0229";
    NSString *year = @"(19|20)[0-9]{2}";
    NSString *leapYear = @"(19|20)(0[48]|[2468][048]|[13579][26])";
    NSString *yearMmdd = [NSString stringWithFormat:@"%@%@", year, mmdd];
    NSString *leapyearMmdd = [NSString stringWithFormat:@"%@%@", leapYear, leapMmdd];
    NSString *yyyyMmdd = [NSString stringWithFormat:@"((%@)|(%@)|(%@))", yearMmdd, leapyearMmdd, @"20000229"];
    NSString *area = @"(1[1-5]|2[1-3]|3[1-7]|4[1-6]|5[0-4]|6[1-5]|82|[7-9]1)[0-9]{4}";
    NSString *regex = [NSString stringWithFormat:@"%@%@%@", area, yyyyMmdd  , @"[0-9]{3}[0-9Xx]"];
    NSPredicate *regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![regexTest evaluateWithObject:number]) {
        return NO;
    }
//    int summary = ([number substringWithRange:NSMakeRange(0,1)].intValue + [number substringWithRange:NSMakeRange(10,1)].intValue) *7
//    + ([number substringWithRange:NSMakeRange(1,1)].intValue + [number substringWithRange:NSMakeRange(11,1)].intValue) *9
//    + ([number substringWithRange:NSMakeRange(2,1)].intValue + [number substringWithRange:NSMakeRange(12,1)].intValue) *10
//    + ([number substringWithRange:NSMakeRange(3,1)].intValue + [number substringWithRange:NSMakeRange(13,1)].intValue) *5
//    + ([number substringWithRange:NSMakeRange(4,1)].intValue + [number substringWithRange:NSMakeRange(14,1)].intValue) *8
//    + ([number substringWithRange:NSMakeRange(5,1)].intValue + [number substringWithRange:NSMakeRange(15,1)].intValue) *4
//    + ([number substringWithRange:NSMakeRange(6,1)].intValue + [number substringWithRange:NSMakeRange(16,1)].intValue) *2
//    + [number substringWithRange:NSMakeRange(7,1)].intValue *1 + [number substringWithRange:NSMakeRange(8,1)].intValue *6
//    + [number substringWithRange:NSMakeRange(9,1)].intValue *3;
//    NSInteger remainder = summary % 11;
//    NSString *checkBit = @"";
//    NSString *checkString = @"10X98765432";
//    checkBit = [checkString substringWithRange:NSMakeRange(remainder,1)];// 判断校验位
//    return [checkBit isEqualToString:[[number substringWithRange:NSMakeRange(17,1)] uppercaseString]];
    return YES;
}

+ (BOOL)verifyPassportNumber:(NSString *)number{
//    护照号码的格式：
//    因私普通护照号码格式有:14/15+7位数,G+8位数；因公普通的是:P.+7位数；
//    公务的是：S.+7位数 或者 S+8位数,以D开头的是外交护照.D=diplomatic
    NSString* regex = @"^1[45][0-9]{7}|G[0-9]{8}|P[0-9]{7}|S[0-9]{7,8}|D[0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:number];
}

/**
 *  验证密码
 *
 *  规则:必须包含字母数字且大于8位
 *
 *  @return
 */
+(BOOL)verifyPasswordNumber:(NSString *)number{
    BOOL result = false;
    if ([number length] >= 8){
        // 判断长度大于8位后再接着判断是否同时包含数字和字符
        NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:number];
    }
    return result;
}

/**
 *  验证组织机构代码
 *
 *  规则:9位数字或字母
 *
 *  @return
 */
+(BOOL)verifyOrganizationNumber:(NSString *)number{
    BOOL result = false;
    if ([number length] == 9){
        // 判断长度大于8位后再接着判断是否同时包含数字和字符
        NSString * regex = @"[a-zA-Z|0-9]*";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:number];
    }
    return result;
}

/**
 *  统一社会信用代码
 *
 *  规则:18位数字或字母
 *
 *  @return
 */
+(BOOL)verifyCreditNumber:(NSString *)number{
    BOOL result = false;
    if ([number length] == 18){
        // 判断长度大于8位后再接着判断是否同时包含数字和字符
        NSString * regex = @"[a-zA-Z|0-9]*";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        result = [pred evaluateWithObject:number];
    }
    return result;
}

@end
