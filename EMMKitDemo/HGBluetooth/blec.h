//
//  blec.hpp
//  device
//
//  Created by eastportsd on 16/4/20.
//  Copyright © 2016年 eastportsd. All rights reserved.
//

#ifndef _BLE_C_H
#define _BLE_C_H

void ble_setdelegate(void*delegate);
//void setble(void*ble);
//int scan(int suuid, int ruuid, int wuuid);
int ble_sendAndreceive(unsigned char* cmd,  unsigned long clen,
                   unsigned char* result, unsigned long* rlen,
                   unsigned char tag);
int ble_reset(unsigned char* atr, unsigned long* atrlen);
//void settimeout(int s, int t);
char* ble_getperipheralname();

#endif /* blec_hpp */
