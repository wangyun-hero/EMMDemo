//
//  ViewControllersMemoryHandle.h
//  EMMKitDemo
//
//  Created by zm on 2016/11/7.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewControllersMemoryHandle : NSObject

+ (ViewControllersMemoryHandle *)sharedInstance;

- (void)setViewControllers:(NSArray *)viewControllers key:(NSString *)appId;
- (NSArray *)getViewControllers:(NSString *)appId;
- (void)removeViewControllesr:(NSString *)appId;
@end
