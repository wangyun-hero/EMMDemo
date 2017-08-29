//
//  SparseDictionary.m
//  UMIOSControls
//
//  Created by gct on 16/4/25.
//  Copyright © 2016年 yyuap. All rights reserved.
//

#import "SparseDictionary.h"

@interface SparseDictionary()

@property (nonatomic,strong,readonly) NSMutableArray * keysOfArray;
@property (nonatomic,strong,readonly) NSMutableArray * valuesOfArray;

@end


@implementation SparseDictionary


-(instancetype) init{
    
    self = [super init];
    
    if(self)
    {
        _keysOfArray = [NSMutableArray array];
        _valuesOfArray = [NSMutableArray array];
    }
    
    return self;
}
+(instancetype)initWidthDictionary:(NSDictionary *) dict
{
    SparseDictionary * instance  = [[SparseDictionary alloc] init];
    if(instance)
    {
        if(dict!=nil)
        {
            for(NSObject * key in dict.allKeys)
            {
                [instance putValue:dict[key] Key:key];
            }
        }
    }
    
    return instance;
}
-(void) addEntryDictonary:(NSDictionary *) dict
{
    
    if(dict!=nil)
    {
        for(NSObject * key in dict.allKeys)
        {
            [self putValue:dict[key] Key:key];
        }
    }
}

-(void) putValue:(NSObject *) value Key:(NSObject *)key
{
    
    if([_keysOfArray indexOfObject:key]==NSNotFound)
    {
        [_keysOfArray addObject:key];
    }
    
    if([_keysOfArray indexOfObject:key]<_valuesOfArray.count)
    {
        [_valuesOfArray removeObjectAtIndex:[_keysOfArray indexOfObject:key]];
        [_valuesOfArray insertObject:value atIndex:[_keysOfArray indexOfObject:key]];
    }else{
        [ _valuesOfArray addObject:value];
    }
    
}
-(NSObject *) getValueOfKey:(NSObject *)key{
    
    if([_keysOfArray indexOfObject:key]==NSNotFound)
    {
        return nil;
    }
    return [_valuesOfArray objectAtIndex:[_keysOfArray indexOfObject:key]];
}
-(NSArray *) keys
{
    
    return [_keysOfArray copy];
}
-(NSArray *) values
{
    return [_valuesOfArray copy];
}

-(NSObject *) keyAtIndex:(NSInteger) index
{
    
    return  _keysOfArray[index];
}
-(NSObject *) valueAtIndex:(NSInteger) index{
    return _valuesOfArray[index];
}
-(NSInteger) indexOfKey:(NSObject *) key{
    return [_keysOfArray indexOfObject:key];
}
-(NSInteger) indexOfValue:(NSObject *) value
{
    return [_valuesOfArray indexOfObject:value];
}
-(NSObject *) remove:(NSObject *) key
{
    NSObject * value = nil;
    
    if([_keysOfArray indexOfObject:key]!=NSNotFound)
    {
        NSInteger index = [_keysOfArray indexOfObject:key];
        value = [self getValueOfKey:key];
        [_keysOfArray removeObjectAtIndex:index];
        [_valuesOfArray removeObjectAtIndex:index];
    }
    return value;
}
-(NSInteger) size
{
    return _keysOfArray.count;
}
-(NSObject *) deleteAtIndex:(NSInteger ) index
{
    NSObject * key =  [self  keyAtIndex: index];
    NSObject * value = nil;
    if(key!=nil)
    {
        value = [self getValueOfKey:key];
        [_keysOfArray removeObjectAtIndex:index];
        [_valuesOfArray removeObjectAtIndex:index];
    }
    
    return value;
}
-(void) clear
{
    [_keysOfArray removeAllObjects];
    [_valuesOfArray removeAllObjects];
}

-(NSString *) description{
    
    NSString * desc = @"(\n";
    for(int i=0;i<_keysOfArray.count;i++)
    {
        if(i<(_keysOfArray.count-1))
        {
            desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%@=%@,\n",_keysOfArray[i],_valuesOfArray[i]]];
        }else{
            desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%@=%@\n",_keysOfArray[i],_valuesOfArray[i]]];
        }
    }
    desc = [desc stringByAppendingString:@")\n"];
    
    return desc;
}

-(void) dealloc
{
    [self clear];
}

@end