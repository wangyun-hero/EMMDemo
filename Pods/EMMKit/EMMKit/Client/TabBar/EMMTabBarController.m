//
//  EMMTabBarController.m
//  Pods
//
//  Created by Chenly on 16/6/14.
//
//

#import "EMMTabBarController.h"
#import "EMMWebViewController.h"
#import "EMMMediator.h"
#import "UIColor+HexString.h"

@interface EMMTabBarController ()

@end

@implementation EMMTabBarController

- (instancetype)initWithConfig:(id)config {
    if (self = [super init]) {
        
        NSArray *items;
        if ([config isKindOfClass:[NSDictionary class]]) {
            items = config[@"tabs"];
        }
        else if ([config isKindOfClass:[NSArray class]]) {
            items = config;
        }
        
        NSMutableArray *viewControllers = [NSMutableArray array];
        for (NSDictionary *item in items) {
            
            UIViewController *viewController = [self createViewControllerWithInfo:item];
            
            UINavigationController *naviController;
//            [naviController.navigationBar setBackgroundImage:[UIImage imageNamed:@"图层"] forBarMetrics:UIBarMetricsDefault];
//            naviController.navigationBar.barStyle = UIBarStyleBlackOpaque;
            
            
            if ([viewController isKindOfClass:[UINavigationController class]])
            {
                naviController = (UINavigationController *)viewController;
            }
            else {
                naviController = [[UINavigationController alloc] initWithRootViewController:viewController];
                
            }
            [viewControllers addObject:naviController];
            
            BOOL navigationBarHidden = [item[@"navigation-bar-hidden"] boolValue];
            naviController.navigationBarHidden = navigationBarHidden;
            
            // navigation下线的颜色
//            NSString *labelColor = item[@"navigation-lineColor"];
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(naviController.navigationBar.frame), CGRectGetWidth(naviController.navigationBar.frame), 0.5)];
//            self.label = label;
//            [label setBackgroundColor:[UIColor emm_colorWithHexString:labelColor]];
//            [naviController.navigationBar addSubview:label];
//            naviController.navigationBar.backgroundColor = [UIColor redColor];
        }
        self.viewControllers = viewControllers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)createViewControllerWithInfo:(NSDictionary *)info {
    
    NSString *title = info[@"title"];
    NSString *imageName = info[@"icon"];
    NSString *selectedImageName = info[@"selected-icon"];
    NSString *titleColor = info[@"textcolor"];
    NSString *selectedTitleColor = info[@"textcolor-selected"];
    
    NSString *type = info[@"type"];
    NSString *className = info[@"class"];
    NSDictionary *configs = info[@"configs"];
    
    UIViewController *viewController = [EMMMediator instanceWithClassName:className type:type config:configs];
    viewController.title = title;
    
    [viewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor emm_colorWithHexString:titleColor]} forState:UIControlStateNormal];
    [viewController.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor emm_colorWithHexString:selectedTitleColor]} forState:UIControlStateSelected];
    
    viewController.tabBarItem.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    viewController.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return viewController;
}



@end
