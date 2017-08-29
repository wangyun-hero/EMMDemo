//
//  CustomerServiceModel.h
//  EMMKitDemo
//
//  Created by zm on 16/9/22.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerServiceModel : NSObject

@property (nonatomic,copy) NSString *image;
@property (nonatomic,copy) NSString *title;
@property (nonatomic, copy) NSString *key;

@property (nonatomic,copy) NSString *phoneNumber;

@end

@interface OnlineHelpModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *url;

@end
