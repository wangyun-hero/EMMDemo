//
//  EMMSettingsViewController.h
//  EMMPortalDemo
//
//  Created by zm on 16/6/16.
//  Copyright © 2016年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMProtocol.h"
#import <EMMPersonInfo.h>
@interface EMMSettingsViewController : UIViewController <EMMConfigurable>
@property (nonatomic, strong) EMMPersonInfo *personInfo;
@property (nonatomic, copy) NSArray *settingSections;

- (instancetype)initWithConfig:(id)config;
- (void)logout;
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) UILabel *label;
@end
