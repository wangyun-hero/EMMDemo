//
//  SpTestCase.hpp
//  testsp
//
//  Created by eastportsd on 16/9/19.
//  Copyright © 2016年 eastportsd. All rights reserved.
//

#ifndef SpTestCase_hpp
#define SpTestCase_hpp

#include "spsecureapi.h"

UINT testGeneral();
UINT testSign();
char* getCardUserInfo();
char* getCardID();
char* signName(unsigned char *random,unsigned int randomLen,unsigned char *pin);
char * getCertNo();
UINT checkPWD(unsigned char *pin);

#endif /* SpTestCase_hpp */
