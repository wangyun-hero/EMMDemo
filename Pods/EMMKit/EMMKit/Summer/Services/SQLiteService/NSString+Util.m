//
//  NSString+Util.m
//  UMContainer
//
//  Created by dingheng on 13-12-11.
//  Copyright (c) 2013年 UFIDA. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)
/*
 函数描述：字符串筛选,去掉不需要的特殊字符串
 参数描述：target         原字符串
 replacement   需要替换的字符串
 options       默认传2:NSLiteralSearch,区分大小写
 _replaceArray 需要排除的Array
 返回值： 筛选完的String
 备注:   使用方法:replaceOccurrencesOfString:@"1(2*3" withString:@"" options:2 replaceArray:[NSArray arrayWithObjects:@"(",@"*", nil]
 输出:123
 */
+ (NSString *)replaceOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options replaceArray:(NSArray *)_replaceArray {
    NSMutableString *tempStr = [NSMutableString stringWithString:target];
    NSArray *replaceArray = [NSArray arrayWithArray:_replaceArray];
    for(int i = 0; i < [replaceArray count]; i++){
        NSRange range = [target rangeOfString: [replaceArray objectAtIndex:i]];
        if(range.location != NSNotFound){
            [tempStr replaceOccurrencesOfString: [replaceArray objectAtIndex:i]
                                     withString: replacement
                                        options: options
                                          range: NSMakeRange(0, [tempStr length])];
        }
    }
    return tempStr;
}

+(NSString *)randFileName
{
    // 获取系统时间
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyMMddHHmmssSSSSSS"];
    
    // 时间字符串
    NSString *datestr = [dateFormatter stringFromDate:[NSDate date]];
    //[dateFormatter release];
    
    // 随机5位字符串
    NSMutableString *randstr = [[NSMutableString alloc]init];
    for(int i = 0 ; i < 5 ; i++)
    {
        int val= arc4random()%10;
        [randstr appendString:[NSString stringWithFormat:@"%d",val]];
    }
    
    // 生成文件名
    NSString *string = [NSString stringWithFormat:@"F%@%@",datestr,randstr];
    //[randstr release];
    
    NSLog(@"Date:::::::::%@", string);
    
    
    return string;
}

+ (NSString*)encodeURL:(NSString *)string
{
    NSString *newString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                                kCFAllocatorDefault,
                                                                                                (CFStringRef)string, NULL, CFSTR("?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
                                                                                                CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    if (newString) {
        return newString;
    }
    return string;
}

+ (NSString*)decodeURL:(NSString *)string{
    if(string == nil){return  @"";}
    NSMutableString *outputStr = [NSMutableString stringWithString:string];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}


-(BOOL)isValidString{
    if (self && self.length > 0) {
        return YES;
    }
    return NO;
}
+(NSString *) trim:(NSString *)str
{
    if(![[self class] isEmptyOrNil:str])
    {
        return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    return str;
}

+(BOOL) isEmptyOrNil:(NSString *)str
{
    if(str==nil || str.length==0)
    {
        return YES;
    }
    
    return NO;
}


@end
