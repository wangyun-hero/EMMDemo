//
//  EMMDocumentDetailViewController.m
//  DocumentDemo
//
//  Created by Chenly on 16/6/21.
//  Copyright © 2016年 iUapMobile. All rights reserved.
//

#import "EMMDocDetailViewController.h"
#import "UINavigationController+Extension.h"

@interface EMMDocDetailViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation EMMDocDetailViewController
{
    BOOL _needReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.webView = [[UIWebView alloc] init];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    
    [self.navigationController initNavBarBackBtnWithSystemStyle];
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)setURLString:(NSString *)URLString {
    
    _URLString = [URLString copy];
    _needReload = YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    rect.origin.y = [self.topLayoutGuide length];
    rect.size.height -= rect.origin.y;
    self.webView.frame = rect;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_needReload) {
        
        NSURL *URL;
        if ([self.URLString hasPrefix:@"http"]) {
            URL = [NSURL URLWithString:self.URLString];
        }
        else {
            URL = [[NSBundle mainBundle] URLForResource:self.URLString withExtension:nil];
        }
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // 禁用长按事件，防拷贝
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

@end
