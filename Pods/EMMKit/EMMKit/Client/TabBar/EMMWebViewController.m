//
//  EMMWebViewController.m
//  Pods
//
//  Created by Chenly on 16/6/14.
//
//

#import "EMMWebViewController.h"

@interface EMMWebViewController ()
{
    BOOL _needReloadPage;
}

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation EMMWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];    
    self.webView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPageIfNeed];
}

- (void)setStartPage:(NSString *)startPage {
    _startPage = [startPage copy];
    _needReloadPage = YES;
    [self loadPageIfNeed];
}

- (void)loadPageIfNeed {
    if (!_needReloadPage) {
        return;
    }
    [self loadPage];
}

- (void)loadPage {
    if (!self.webView) {
        return;
    }
    NSURL *url = [NSURL URLWithString:self.startPage];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    _needReloadPage = NO;
}

@end
