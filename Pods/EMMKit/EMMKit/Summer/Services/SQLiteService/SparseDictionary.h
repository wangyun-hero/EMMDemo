//
//  SparseDictionary.h
//  UMIOSControls
//
//  Created by gct on 16/4/25.
//  Copyright © 2016年 yyuap. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SparseDictionary : NSObject

-(instancetype) init;
+(instancetype)initWidthDictionary:(NSDictionary *) dict;

-(void) addEntryDictonary:(NSDictionary *) dict;
-(void) putValue:(NSObject *) value Key:(NSObject *)key;
-(NSObject *) getValueOfKey:(NSObject *)key;
-(NSArray *) keys;
-(NSArray *) values;
-(NSObject *) keyAtIndex:(NSInteger) index;
-(NSObject *) valueAtIndex:(NSInteger) index;
-(NSInteger) indexOfKey:(NSObject *) value;
-(NSInteger) indexOfValue:(NSObject *) value;
-(NSObject *) remove:(NSObject *) key;
-(NSObject *) deleteAtIndex:(NSInteger ) index;
-(NSInteger) size;
-(void) clear;

@end;