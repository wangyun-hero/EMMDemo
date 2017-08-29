//
//  UIColor+HexString.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/1.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

/**
 *  将 16 进制的字符串转化成 UIColor，格式为 0XFFEE08 or # FFEE08
 */
+ (UIColor *)emm_colorWithHexString:(NSString *)hexString;

@end
