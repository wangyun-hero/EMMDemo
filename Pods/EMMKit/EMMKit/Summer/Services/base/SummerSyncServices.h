//
//  SummerSyncServices.h
//  SummerExample
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@import JavaScriptCore;

@protocol SummerSyncServicesJSExport <JSExport>

JSExportAs(callSync, + (id)callSync:(NSString *)action args:(NSString *)argsJSON);

@end

/**
 *  同步调用服务方法，直接返回值
 */
@interface SummerSyncServices : NSObject <SummerSyncServicesJSExport>

+ (id)callSync:(NSString *)action args:(NSString *)argsJSON;

@end
