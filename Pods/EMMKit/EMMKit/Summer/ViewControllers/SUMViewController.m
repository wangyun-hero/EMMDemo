//
//  SUMViewController.m
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMViewController.h"
#import "JSContext+Summer.h"
#import "SummerSyncServices.h"
#import "UIColor+HexString.h"
#import "SUMPreRender.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJRefresh/MJRefresh.h>

@interface SUMViewController ()

@property (nonatomic, strong) JSContext *webJSContext;

@end

@implementation SUMViewController

#pragma mark - getter & setter

- (void)setOpaque:(BOOL)opaque {
    
    _opaque = opaque;
    self.view.opaque = opaque;
    self.webView.opaque = opaque;
    if (opaque) {
        self.webView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:opaque];
        self.view.backgroundColor = [UIColor whiteColor];
    }
    else {
        self.webView.backgroundColor = [self.backgroundColor colorWithAlphaComponent:opaque];
        self.view.backgroundColor = [UIColor clearColor];
    }    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.webView.backgroundColor = [backgroundColor colorWithAlphaComponent:self.opaque];
}

#pragma mark - life cycle

- (instancetype)init {
    return [self initWithSumId:@"root"];
}

- (instancetype)initWithSumId:(NSString *)sumId {

    if (self = [super init]) {
        _sumId = sumId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageStartLoad:) name:CDVPluginResetNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageFinishLoad:) name:CDVPageDidLoadNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageStartLoad:)
                                                 name:CDVPluginResetNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageFinishLoad:)
                                                 name:CDVPageDidLoadNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark page load notification

static NSString * const kJSBridgeName = @"summerBridge";

- (void)pageStartLoad:(NSNotification *)notification {
    
    // 将 summerBridge 类注入到 Javascript 中
    JSValue *summerBridge = [self.webJSContext objectForKeyedSubscript:kJSBridgeName];
    if (summerBridge.isUndefined) {
        self.webJSContext[kJSBridgeName] = [SummerSyncServices class];
    }
}

- (void)pageFinishLoad:(NSNotification *)notification {
    [[SUMPreRender sharedInstance] finishPreRenderingViewController:self];
    if (self.progressHUD) {
        [self.progressHUD hideAnimated:YES];
    };
}

#pragma mark - Attribute

- (void)setAttributes:(NSDictionary *)attributes {
    
    [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && ![obj isKindOfClass:[NSNull class]]) {
            [self setAttribute:obj forAttributeName:key];
        }
    }];
}

- (void)setAttribute:(id)value forAttributeName:(NSString *)attributeName {

    // 显示加载框
    if ([[attributeName lowercaseString] isEqualToString:@"showprogress"]) {
        BOOL showProgress = [value boolValue];
        if (showProgress) {
            self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        }
    }
}

#pragma mark - MJRefresh

- (void)setRefreshingHeaderWithParams:(NSDictionary *)params refreshingBlock:(void (^)(void))refreshingBlock {
    
    NSString *bgColor   = [params objectForKey:@"bgColor"];
    NSString *textColor = [params objectForKey:@"textColor"];
    NSString *textUp    = [params objectForKey:@"textUp"];
    NSString *textDown  = [params objectForKey:@"textDown"];
    NSString *textDo    = [params objectForKey:@"textDo"];
    
    UIColor *tintColor = [UIColor emm_colorWithHexString:textColor] ?: [UIColor blackColor];
    UIColor *backgroundColor = [UIColor emm_colorWithHexString:bgColor] ?: [UIColor clearColor];
    
    UIScrollView *scrollView = self.webView.scrollView;
    MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)scrollView.mj_header;
    
    if (!scrollView.mj_header) {
        header = [MJRefreshNormalHeader headerWithRefreshingBlock:refreshingBlock];
        scrollView.mj_header = header;
    }
    else {
        header.refreshingBlock = refreshingBlock;
    }
    
    [header setTitle:textDown forState:MJRefreshStateIdle];
    [header setTitle:textUp forState:MJRefreshStatePulling];
    [header setTitle:textDo forState:MJRefreshStateRefreshing];
    [header setTintColor:tintColor];
    [header setBackgroundColor:backgroundColor];
}

- (void)beginHeaderRefreshing {
    
    UIScrollView *scrollView = self.webView.scrollView;
    MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)scrollView.mj_header;
    [header beginRefreshing];
}

- (void)endHeaderRefreshing {
    
    UIScrollView *scrollView = self.webView.scrollView;
    MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)scrollView.mj_header;
    [header endRefreshing];
}

- (void)setRefreshingFooterWithParams:(NSDictionary *)params refreshingBlock:(void (^)(void))refreshingBlock {
    
    NSString *bgColor   = [params objectForKey:@"bgColor"];
    NSString *textColor = [params objectForKey:@"textColor"];
    NSString *textUp    = [params objectForKey:@"textUp"];
    NSString *textDown  = [params objectForKey:@"textDown"];
    NSString *textDo    = [params objectForKey:@"textDo"];
    
    UIColor *tintColor = [UIColor emm_colorWithHexString:textColor] ?: [UIColor blackColor];
    UIColor *backgroundColor = [UIColor emm_colorWithHexString:bgColor] ?: [UIColor clearColor];
    
    UIScrollView *scrollView = self.webView.scrollView;
    MJRefreshBackStateFooter *footer = (MJRefreshBackStateFooter *)scrollView.mj_footer;
    
    if (!scrollView.mj_footer) {
        footer = [MJRefreshBackStateFooter footerWithRefreshingBlock:refreshingBlock];
        scrollView.mj_footer = footer;
    }
    else {
        footer.refreshingBlock = refreshingBlock;
    }
    
    [footer setTitle:textDown forState:MJRefreshStateIdle];
    [footer setTitle:textUp forState:MJRefreshStatePulling];
    [footer setTitle:textDo forState:MJRefreshStateRefreshing];
    [footer setTintColor:tintColor];
    [footer setBackgroundColor:backgroundColor];
}

- (void)beginFooterRefreshing {
    
    UIScrollView *scrollView = self.webView.scrollView;
    MJRefreshNormalHeader *footer = (MJRefreshNormalHeader *)scrollView.mj_footer;
    [footer beginRefreshing];
}

- (void)endFooterRefreshing {
    
    UIScrollView *scrollView = self.webView.scrollView;
    MJRefreshNormalHeader *footer = (MJRefreshNormalHeader *)scrollView.mj_footer;
    [footer endRefreshing];
}

#pragma mark - getter & setter

- (JSContext *)webJSContext {
    if (!_webJSContext) {
        _webJSContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        _webJSContext.sender = self;
    }
    return _webJSContext;
}

@end
