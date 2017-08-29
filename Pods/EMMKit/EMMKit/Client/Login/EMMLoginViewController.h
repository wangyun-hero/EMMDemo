//
//  LoginViewController.h
//  appDemo
//
//  Created by zm on 16/6/2.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMProtocol.h"

@interface EMMLoginViewController : UIViewController <EMMLoginCompletion, EMMConfigurable>

@property (nonatomic, copy) void (^completion)(BOOL success, id result);

- (instancetype)initWithConfig:(id)config;

@end
