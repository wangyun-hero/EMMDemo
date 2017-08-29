//
//  SUMViewController.h
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import <Cordova/CDVViewController.h>

@class MBProgressHUD;

@interface SUMViewController : CDVViewController

@property (nonatomic, assign) BOOL opaque;
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, copy) NSString *sumId;
@property (nonatomic, strong) id pageParams;    // 传递页面参数

@property (nonatomic, assign) MBProgressHUD *progressHUD;

- (instancetype)initWithSumId:(NSString *)sumId;

- (void)setAttributes:(NSDictionary *)attributes;
- (void)setAttribute:(id)value forAttributeName:(NSString *)attributeName;

- (void)setRefreshingHeaderWithParams:(NSDictionary *)params refreshingBlock:(void (^)(void))refreshingBlock;
- (void)beginHeaderRefreshing;
- (void)endHeaderRefreshing;
- (void)setRefreshingFooterWithParams:(NSDictionary *)params refreshingBlock:(void (^)(void))refreshingBlock;
- (void)beginFooterRefreshing;
- (void)endFooterRefreshing;

@end
