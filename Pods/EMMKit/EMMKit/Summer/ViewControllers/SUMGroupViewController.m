//
//  SUMGroupViewController.m
//  SummerDemo
//
//  Created by Chenly on 16/9/12.
//  Copyright © 2016年 Yonyou. All rights reserved.
//

#import "SUMGroupViewController.h"
#import "SUMFrameViewController.h"
#import "UIView+SUMLayout.h"
#import "SUMPreRender.h"

@interface SUMGroupViewController () <SUMPreRenderDelegate>

@property (nonatomic, weak) SUMFrameViewController *selectedFrame;
@property (nonatomic, strong) NSMutableDictionary *operations;

@end

@implementation SUMGroupViewController

- (instancetype)initWithSumId:(NSString *)sumId frames:(NSArray<SUMFrameViewController *> *)frames {

    if (self = [super init]) {
        
        _sumId = sumId;
        _frames = [frames copy];
        _operations = [NSMutableDictionary dictionary];
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

- (void)setLayoutConstraintsWithPositions:(NSDictionary *)positions {
    
    [self.view setLayoutConstraintsWithPositions:positions];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {

    _selectedIndex = selectedIndex;
    
    SUMFrameViewController *toFrame = self.frames[selectedIndex];
    if (!toFrame || self.selectedFrame == toFrame) {
        return;
    }
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        if (self.selectedFrame) {
            [self.selectedFrame removeFromParentViewController];
            [self.selectedFrame.view removeFromSuperview];
            self.selectedFrame = nil;
        }
        if (toFrame && toFrame.beenPreRendered) {
            [self addChildViewController:toFrame];
            [self.view addSubview:toFrame.view];
            [toFrame.view setLayoutConstraintsWithPositions:nil];
            self.selectedFrame = toFrame;
        }
    }];
    
    if (toFrame.beenPreRendered) {
    
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
    else {
        [self.operations removeAllObjects];
        NSValue *key = [NSValue valueWithNonretainedObject:toFrame];
        self.operations[key] = operation;
        [[SUMPreRender sharedInstance] beginPreRenderingViewController:toFrame observer:self];
    }
}

- (void)setAttributes:(NSDictionary *)attributes {

    [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj && ![obj isKindOfClass:[NSNull class]]) {
            [self setAttribute:obj forAttributeName:key];
        }
    }];
}

- (void)setAttribute:(id)value forAttributeName:(NSString *)attributeName {
    
    NSString *key = [attributeName lowercaseString];
    if (![[self effectiveAttributeNames] containsObject:key]) {
        return;
    }
    
    if ([key isEqualToString:@"hidden"]) {
        
        [self setValue:value forKeyPath:@"view.hidden"];
    }
    else if ([key isEqualToString:@"index"]) {
    
        NSInteger index = [value integerValue];
        self.selectedIndex = index;
    }
}

- (NSArray *)effectiveAttributeNames {
    return @[@"hidden", @"index"];
}

#pragma mark - preRender

- (void)preRenderWithIndex:(NSInteger)index observer:(id<SUMPreRenderDelegate>)observer {

    [_frames enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == index) {
            
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                
                [[SUMPreRender sharedInstance] finishPreRenderingViewController:self];
                self.selectedIndex = idx;
                
                for (UIViewController *frame in _frames) {
                    
                    if (frame == obj) {
                        continue;
                    }
                    [[SUMPreRender sharedInstance] beginPreRenderingViewController:frame observer:self];
                }
            }];
            
            NSValue *key = [NSValue valueWithNonretainedObject:obj];
            self.operations[key] = operation;
            [[SUMPreRender sharedInstance] beginPreRenderingViewController:obj observer:self];
        }
    }];
    [[SUMPreRender sharedInstance] beginPreRenderingViewController:self observer:observer];
}

#pragma mark - <SUMPreRenderDelegate>

- (void)preRender:(SUMPreRender *)preRender didViewControllerFinishedRender:(UIViewController *)viewController {

    NSValue *key = [NSValue valueWithNonretainedObject:viewController];
    NSOperation *operation = self.operations[key];
    if (operation) {
        [[NSOperationQueue mainQueue] addOperation:operation];
        [self.operations removeObjectForKey:key];
    }
}

@end
