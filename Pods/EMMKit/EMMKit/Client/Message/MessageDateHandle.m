//
//  MessageDateHandle.m
//  EMMKitDemo
//
//  Created by zm on 16/9/9.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "MessageDateHandle.h"

@implementation MessageDateHandle

+ (NSString *)conversionFromDate:(NSString *)messageDate{
    
    NSArray *messageDateArray = [messageDate componentsSeparatedByString:@"-"];
    NSString *messageDateYMD = messageDateArray[0];
    NSString *messageDateTime = messageDateArray[1];
    NSArray *messageYMDArray = [messageDateYMD componentsSeparatedByString:@"/"];
    NSInteger messageYear = [messageYMDArray[0] integerValue];
    NSInteger messageMonth = [messageYMDArray[1] integerValue];
    NSInteger messageDay = [messageYMDArray[2] integerValue];
    
    if(([self currentDay] == messageDay) && ([self currentMonth]==messageMonth) && ([self currentYear]==messageYear)){
        // 同年同月同日 显示时间
        return messageDateTime;
    }
    
    if(([self currentYear] == messageYear) && ([self currentMonth] == messageMonth)){
        // 同年同月
        NSInteger valueDays = [self currentDay] - messageDay;
        if(valueDays == 1){
            // 前一天 显示昨天
            return [NSString stringWithFormat:@"昨天 %@",messageDateTime];
        }
        if (valueDays > 6) {
            // 大于一周显示年月日
            return [NSString stringWithFormat:@"%@ %@",messageDateYMD,messageDateTime];
        }
        else{
            // 小于一周显示星期
            NSInteger weekDay = (long)[self currentWeekDay] - valueDays + 7;
            weekDay = weekDay >7?weekDay-7:weekDay;
            NSString *weekDayString = @"";
            if(weekDay == 1) weekDayString = @"一";
            if(weekDay == 2) weekDayString = @"二";
            if(weekDay == 3) weekDayString = @"三";
            if(weekDay == 4) weekDayString = @"四";
            if(weekDay == 5) weekDayString = @"五";
            if(weekDay == 6) weekDayString = @"六";
            if(weekDay == 7) weekDayString = @"日";
            
            return [NSString stringWithFormat:@"星期%@ %@",weekDayString,messageDateTime];
        }
    }
    
    if([self currentYear] == messageYear){
        // 同年
        NSInteger valueMonths = [self currentMonth] - messageMonth;
        if(valueMonths > 1){
            // 两个月以上 显示年月日
            return [NSString stringWithFormat:@"%@ %@",messageDateYMD,messageDateTime];
        }
        // 上个月天数
        NSInteger messageDays = [self getDaysInYear:messageYear Month:messageMonth];
        NSInteger valueDays = messageDays - messageDay;
        if((valueDays >= 6) || (valueDays + messageDay) >= 6){
            return [NSString stringWithFormat:@"%@ %@",messageDateYMD,messageDateTime];;
        }
        if(valueDays == 1){
            return [NSString stringWithFormat:@"昨天 %@",messageDateTime];
        }
        
        NSInteger weekDay = (long)[self currentWeekDay] - valueDays + 7;
        NSString *weekDayString = @"";
        if(weekDay == 1) weekDayString = @"一";
        if(weekDay == 2) weekDayString = @"二";
        if(weekDay == 3) weekDayString = @"三";
        if(weekDay == 4) weekDayString = @"四";
        if(weekDay == 5) weekDayString = @"五";
        if(weekDay == 6) weekDayString = @"六";
        if(weekDay == 7) weekDayString = @"日";
        
        return [NSString stringWithFormat:@"星期%@ %@",weekDayString,messageDateTime];
        
    }
    return messageDateYMD;
}

+ (NSInteger)currentYear
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cps = [cal components:NSCalendarUnitYear fromDate:[NSDate date]];
    return cps.year;
}

+ (NSInteger)currentMonth
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cps = [cal components:NSCalendarUnitMonth fromDate:[NSDate date]];
    return cps.month;
}

+ (NSInteger)currentDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cps = [cal components:NSCalendarUnitDay fromDate:[NSDate date]];
    return cps.day;
}

// 周天-1 周六-7
+ (NSInteger)currentWeekDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cps = [cal components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    if(cps.weekday == 1){
        return 7;
    }
    return cps.weekday - 1;
}

/**
 *  获取某个月天数
 *
 *  @param year  年
 *  @param month 月
 *
 *  @return 天数
 */
+ (NSInteger)getDaysInYear:(NSInteger)year Month:(NSInteger)month{
    if((month == 1)||(month == 3)||(month ==5)||(month == 7)||(month == 8)||(month == 10)||(month == 12)){
        return 31;
    }
    if((month == 4)||(month == 6)||(month == 9)||(month == 11)){
        return 30;
    }
    if((year%4 == 1)||(year%4 == 2)||(year%4 == 3)){
        return 28;
    }
    if(year%400 == 0){
        return 29;
    }
    if(year%100 == 0){
        return 28;
    }
    
    return 29;
}


+ (NSString *)getCurrentDate{
    
    NSString* date;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"yyyy/MM/dd-HH:mm"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString * timeNow = [[NSString alloc] initWithFormat:@"%@", date];
    
    return timeNow;
}

+ (NSString *)mainShowTime:(NSString *)date{
    NSArray *dates = [date componentsSeparatedByString:@" "];
    if(dates.count > 1){
        if([dates[0] rangeOfString:@"/"].length == 0) return dates[0];
        return [dates[0] substringFromIndex:2];//只显示后两位年份
    }
    return date;
}

+ (NSString *)detailShowTime:(NSString *)date{
    NSArray *dates = [date componentsSeparatedByString:@"/"];
    if(dates.count > 1){
        NSArray *times = [dates[2] componentsSeparatedByString:@"-"];
//#warning - Debug
//        times = @[@"11", @"15:32"];
        date = [NSString stringWithFormat:@"%@年%@月%@日 %@",dates[0],dates[1],times[0],times[1]];
    }
    
    return date;
}

@end
