//
//  EMMDocument.h
//  DocumentDemo
//
//  Created by Chenly on 16/6/21.
//  Copyright © 2016年 iUapMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMDocument : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *type;

@property (nonatomic, readonly) UIImage *image;

@end
