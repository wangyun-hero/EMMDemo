//
//  SUMFrameViewController.m
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMFrameViewController.h"
#import "UIView+SUMLayout.h"
#import "UIColor+HexString.h"

@interface SUMFrameViewController ()

@end

@implementation SUMFrameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.scrollView.bounces = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAttribute:(id)value forAttributeName:(NSString *)attributeName {
    
    NSString *key = [attributeName lowercaseString];
    if (![[self effectiveAttributeNames] containsObject:key]) {
        return;
    }
    else if ([key isEqualToString:@"hidden"]) {
        [self setValue:value forKeyPath:@"view.hidden"];
    }
    else if ([key isEqualToString:@"bounces"]) {
        [self setValue:value forKeyPath:@"webView.scrollView.bounces"];
    }
    else if ([key isEqualToString:@"opaque"]) {
        [self setValue:value forKeyPath:@"opaque"];
    }
    else if ([key isEqualToString:@"bgcolor"]) {
        UIColor *backgroundColor = [UIColor emm_colorWithHexString:value];
        if (backgroundColor) {
            self.backgroundColor = backgroundColor;
        }
    }
}

- (NSArray *)effectiveAttributeNames {
    return @[@"hidden", @"bgcolor", @"opaque", @"bounces"];
}

- (void)setLayoutConstraintsWithPositions:(NSDictionary *)positions {
    
    [self.view setLayoutConstraintsWithPositions:positions];
}

@end
