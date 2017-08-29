//
//  blefacade.h
//  testble
//
//  Created by zhangqiuxiang on 16/4/1.
//  Copyright © 2016年 zhangqiuxiang. All rights reserved.
//
#ifndef _BLEOBJ_H_
#define _BLEOBJ_H_

#import <Foundation/Foundation.h>
#import<CoreBluetooth/CoreBluetooth.h>

//define a protocol
@protocol BTSmartSensorDelegate
@optional
- (void) peripheralFound:(CBPeripheral *)peripheral;
- (void) serialGATTCharValueUpdated: (NSString *)UUID value: (NSData *)data;
- (void) setConnect;
- (void) setDisconnect;
@end

//facade a new ble class,deal ble synchronously
@interface bleobj : NSObject
{
}

@property (strong, nonatomic) NSMutableArray *peripherals;
@property (nonatomic, assign) id <BTSmartSensorDelegate> delegate;
@property(strong, nonatomic)  CBPeripheral*       activePeripheral;


-(void)setTimeOutForScan:(int)sseconds forTransmit:(int)tseconds;

-(int)scanPeripheral;
-(void)stopScan;

-(void)disconnect;
-(int)connect:(CBPeripheral*) peripheral;

-(NSString*)getPeripheralName;//for test

-(int)sendcmd:(unsigned char*)cmd cmdLen:(unsigned long)clen
        receiveResult:(unsigned char*)result resultLen:(unsigned long*) rlen
       cmdTag:(unsigned char)tag;

-(int)resetAtr:(unsigned char*)atr atrLen:(unsigned long*)len;


@end

#endif

