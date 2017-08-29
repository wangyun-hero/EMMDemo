//
//  HGAppModel.m
//  EMMKitDemo
//
//  Created by zm on 16/7/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HGAppModel.h"

@implementation HGAppModel

- (instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if(self){
        [self setDic:dic];
    }
    return self;
}

// 解析字典
- (void)setDic:(NSDictionary *)dic{
    self.title = [self stringForValue:dic[@"title"]];
    self.applicationId = [self stringForValue:dic[@"applicationId"]];
    self.URL_Scheme = [self stringForValue:dic[@"URL-Scheme"]];
    self.classname = [self stringForValue:dic[@"classname"]];
    self.appgroupname = [self stringForValue:dic[@"appgroupname"]];
    self.appgroupcode = [self stringForValue:dic[@"appgroupcode"]];
    self.appinfoexport = [self stringForValue:dic[@"appinfoexport"]];
    self.scop_type = [self stringForValue:dic[@"scop_type"]];
    
    
    NSInteger type = [self.scop_type integerValue];
    if(type == 1){
        // web
        self.iconurl = [self stringForValue:dic[@"webiconurl"]];
        self.introduction = [self stringForValue:dic[@"webintroduction"]];
        self.url = [self stringForValue:dic[@"weburl"]];
        self.webZipUrl = [self stringForValue:dic[@"webzipurl"]];
        self.version = [self stringForValue:dic[@"webversion"]];
    }
    else if(type==3 || type == 5 || type == 6){
        // iOS 
        self.iconurl = [self stringForValue:dic[@"iosiconurl"]];
        self.introduction = [self stringForValue:dic[@"iosintroduction"]];
        self.version = [self stringForValue:dic[@"iosversion"]];
        self.url = [self stringForValue:dic[@"iosurl"]];
    }
}

// 判空
- (NSString *)stringForValue:(id)value{
    if(value == nil || (NSNull *)value == [NSNull null] || [value isEqualToString:@"null"]){
        value = @"";
    }
    return [NSString stringWithFormat:@"%@",value];
}



@end
