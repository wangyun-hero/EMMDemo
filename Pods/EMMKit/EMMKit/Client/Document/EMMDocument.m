//
//  EMMDocument.m
//  DocumentDemo
//
//  Created by Chenly on 16/6/21.
//  Copyright © 2016年 iUapMobile. All rights reserved.
//

#import "EMMDocument.h"

@implementation EMMDocument

- (UIImage *)image {
    
    NSString *type = self.type;
    if ([type isEqualToString:@"docx"]) {
        type = @"word";
    }
    else if ([type isEqualToString:@"txt"]) {
        type = @"other";
    }
    
    UIImage *icon = [UIImage imageNamed:[NSString stringWithFormat:@"emm_%@.png", type]];
    
    CGRect rect = CGRectMake(0, 0, 44.f, 44.f);
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, [UIScreen mainScreen].scale);
    [icon drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
