//
//  EMMConfigurable.h
//  EMMKitDemo
//
//  Created by Chenly on 16/6/22.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#ifndef EMMProtocol_h
#define EMMProtocol_h

@protocol EMMConfigurable <NSObject>

- (instancetype)initWithConfig:(id)config;

@end

@protocol EMMLoginCompletion <NSObject>

@required
@property (nonatomic, copy) void (^completion)(BOOL success, id result);

@end

#endif
