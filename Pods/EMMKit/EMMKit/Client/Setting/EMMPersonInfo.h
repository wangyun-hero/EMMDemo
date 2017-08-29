//
//  EMMPersonInfo.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/23.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMMPersonInfo : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *department;
@property (nonatomic, copy) NSString *imgurl;

@property (nonatomic, strong) UIImage *avatarImage;

@end
