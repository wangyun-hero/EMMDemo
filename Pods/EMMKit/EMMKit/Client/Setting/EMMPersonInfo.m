//
//  EMMPersonInfo.m
//  EMMKitDemo
//
//  Created by Chenly on 16/7/23.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "EMMPersonInfo.h"

@implementation EMMPersonInfo

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {

    return YES;
}

// YYModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"department" : @"orgname"
             };
}

// YYModel
+ (NSArray *)modelPropertyBlacklist {
    return @[@"avatarImage"];
}

@end
