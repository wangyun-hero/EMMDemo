//
//  SpTestCase.cpp
//  testsp
//
//  Created by eastportsd on 16/9/19.
//  Copyright © 2016年 eastportsd. All rights reserved.
//

#include "SpTestCase.h"
#include <vector>
#include <string>


#define CHECK_RTN   if(rtn != 0) \
                    {\
                        return rtn;\
                    }\


char* getCardUserInfo(){
    UINT rtn;
    SpcInitEnvEx();
    
    char info[1000] = {0};
    UINT infoLen  = 1000;
    rtn = SpcGetCardUserInfo(info, &infoLen);
    if (rtn ==0) {
        printf("USER INFO -- %s", info);
    }
    SpcClearEnv();
    char *rs = new char[infoLen];
    strcpy(rs, info);
    return rs;
}

char* getCardID(){
    UINT rtn;
    SpcInitEnvEx();
    
    BYTE szCardID[20] = {0};
    UINT nCardIDLen = 20;
    rtn = SpcGetCardID(szCardID, &nCardIDLen);
    SpcClearEnv();
    char *rs = new char[nCardIDLen];
    for(int i=0;i<nCardIDLen;i++) {
        rs[i] = szCardID[i];
    }
    return rs;
}

UINT checkPWD(unsigned char *pin){
    UINT rtn;
    rtn = SpcInitEnvEx();
    
    UINT retryTimes;
    // 蓝牙卡验证密码失败
    rtn = SpcVerifyPIN(pin, 8, &retryTimes);
    
    SpcClearEnv();
    return rtn;
}

char* signName(unsigned char *random,unsigned int randomLen,unsigned char *pin){
    UINT rtn;
    rtn = SpcInitEnvEx();
    
    if(rtn != 0){
        // 打开蓝牙失败
        char *rs = new char[5];
        rs[0] = 97; //a
        return rs;
    }
    
    UINT retryTimes;
    rtn = SpcVerifyPIN(pin, 8, &retryTimes);
    if(rtn != 0){
        // 蓝牙卡验证密码失败
        char *rs = new char[5];
        rs[0] = 99; //c
        return rs;
    }

    
    //随机数PEM解码
    BYTE random1[128] = {0};
    UINT randomLen1 = 128;
    rtn = SpcDecodePEM(random, randomLen, random1, &randomLen1);
    if(rtn != 0){
        char *rs = new char[5];
        rs[0] = 98; //b
        return rs;
    }
    
    //签名
    BYTE szSign2[256] ={0};
    UINT nSignLen2 = 256;
    rtn = SpcSignData(random1, randomLen1, szSign2, &nSignLen2);
    if(rtn != 0){
        char *rs = new char[5];
        rs[0] = 98; //b
        return rs;
    }
    
    //签名PEM编码
    BYTE pemSignCert[5000] = {0};
    UINT pemSignCertLen = 5000;
    rtn = SpcEncodePEM(szSign2, nSignLen2, pemSignCert, &pemSignCertLen);
    if(rtn != 0){
        char *rs = new char[5];
        rs[0] = 98; //b
        return rs;
    }
    
    //获取证书
    UINT nCertLen = 5000;
    std::vector<BYTE> szCert(nCertLen, 0);
    rtn = SpcGetSignCert(&szCert[0], &nCertLen);
    if(rtn != 0){
        char *rs = new char[5];
        rs[0] = 98; //b
        return rs;
    }

    //验签
    rtn = SpcVerifySignData(&szCert[0], nCertLen, &random1[0], randomLen1, szSign2, nSignLen2);
    if(rtn != 0){
        char *rs = new char[5];
        rs[0] = 98; //b
        return rs;
    }
    
    SpcClearEnv();
    if (rtn == 0) {
        char *rs = new char[pemSignCertLen];
        for(int i=0;i<pemSignCertLen;i++) {
            rs[i] = pemSignCert[i];
        }
        return rs;
    }else{
        char *rs = new char[5];
        rs[0] = 98; //b
        return rs;
    }
}

char * getCertNo(){
    UINT rtn;
    rtn = SpcInitEnvEx();
    
    BYTE szCertNo[128] = {0};
    UINT nCertNolen = 128;
    rtn = SpcGetCardID(szCertNo, &nCertNolen);
    
    SpcClearEnv();
    char *rs = new char[nCertNolen];
    for(int i=0;i<nCertNolen;i++) {
        rs[i] = szCertNo[i];
    }
    
    return rs;
}

UINT testGeneral()
{
    UINT rtn;
    rtn = SpcInitEnvEx();
    CHECK_RTN
    
    
    //pay attention: cardinfo is coded by gb2312
    char info[1000] = {0};
    UINT infoLen  = 1000;
    rtn = SpcGetCardUserInfo(info, &infoLen);
    CHECK_RTN
    
    BYTE szCardID[20] = {0};
    UINT nCardIDLen = 20;
    rtn = SpcGetCardID(szCardID, &nCardIDLen);
    CHECK_RTN
    
    
    
    BYTE oldPIN[] = "88888888";
    BYTE newPIN[] = "12345678";
    UINT retryTimes;
    //—È÷§¥ÌŒÛø⁄¡Ó
    rtn = SpcVerifyPIN((BYTE*)"7777777", 7, &retryTimes);
    //BOOST_REQUIRE_NE(rtn, 0);
    //BOOST_REQUIRE_EQUAL(retryTimes, 4);
    
    //—È÷§’˝»∑ø⁄¡Ó
    rtn = SpcVerifyPIN(oldPIN, 7, &retryTimes);
    CHECK_RTN
    
    
    //–ﬁ∏ƒø⁄¡Ó
    rtn = SpcChangePIN(oldPIN, 8, newPIN, 8, &retryTimes);
    CHECK_RTN
    
    
    //”√–¬ø⁄¡Ó—È÷§PIN
    rtn = SpcVerifyPIN(newPIN, 8, &retryTimes);
    CHECK_RTN
    
    //∏ƒªÿ‘≠¿¥ø⁄¡Ó
    rtn = SpcChangePIN(newPIN, 8, oldPIN, 8, &retryTimes);
    CHECK_RTN
    
    //ªÒ»°øÿº˛∞Ê±æ∫≈
    char version[10] = {0};
//    rtn = SpcGetModuleVer(version);
    CHECK_RTN
    
    //ªÒ»°¥ÌŒÛ–≈œ¢
    char* err1 = SpcGetErrMsg(50820);
    char* err2 = SpcGetErrMsg(0x0A000015);
    //πÿ±’…Ë±∏
    rtn = SpcClearEnv();
    CHECK_RTN
    
    return rtn;
}

UINT testSign()
{
    //¥Úø™ø®
    UINT rtn;
    rtn = SpcInitEnvEx();
    CHECK_RTN
    
    //…˙≥…ÀÊª˙ ˝
    std::vector<BYTE> random(8, 0);
    rtn = SpcGetRandom(&random[0], 8);
    CHECK_RTN
    
    
    //’™“™
    BYTE digest[128] = {0};
    UINT digestLen = 128;
    rtn = SpcSHA1Digest(&random[0], 8, digest, &digestLen);
    CHECK_RTN
    //BOOST_REQUIRE_EQUAL(digestLen, 20);
    
    
    //—È÷§ø⁄¡Ó
    BYTE szPIN[] = "88888888";
    UINT retryTimes;
    rtn = SpcVerifyPIN(szPIN, 8, &retryTimes);
    CHECK_RTN
    
    //«©√˚nohash
    BYTE szSign1[256] = {0};
    UINT nSignLen1 = 256;
    rtn = SpcSignDataNoHash(digest, digestLen, szSign1, &nSignLen1);
    CHECK_RTN
    //BOOST_REQUIRE_EQUAL(nSignLen1, 128);
    
    
    //«©√˚plain
    BYTE szSign2[256] ={0};
    UINT nSignLen2 = 256;
    rtn = SpcSignData(&random[0], 8, szSign2, &nSignLen2);
    CHECK_RTN
    //BOOST_CHECK_EQUAL(nSignLen2, 128);

   // for(UINT i = 0; i < nSignLen2; i++)
   // {
   //     BOOST_CHECK_EQUAL(std::equal(szSign1, szSign1 + nSignLen1, szSign2);
   // }
    
    bool b = std::equal(szSign1, szSign1 + nSignLen1, szSign2);
    

    //ªÒ»°«©√˚÷§ È
    BYTE szCert[5000] = {0};
    UINT nCertLen = 5000;
    rtn = SpcGetSignCert(szCert, &nCertLen);
    CHECK_RTN
    
    //pem±‡¬Î
    BYTE pemSignCert[5000] = {0};
    UINT pemSignCertLen = 5000;
    rtn = SpcEncodePEM(szCert, nCertLen, pemSignCert, &pemSignCertLen);
    CHECK_RTN

    std::string strSignCert;
    strSignCert.assign(pemSignCert, pemSignCert + pemSignCertLen);
    
    //ªÒ»°º”√‹÷§ È//崩溃,,指向被释放的指针
    BYTE szEnvCert[5000] = {0};
    UINT nEnvCertLen = 5000;
//    rtn = SpcGetEnvCert(szEnvCert, &nEnvCertLen);
//    CHECK_RTN
    
    //pem±‡¬Î
    BYTE pemEnvCert[5000] = {0};
    UINT pemEnvCertLen = 5000;
    rtn = SpcEncodePEM(szEnvCert, nEnvCertLen, pemEnvCert, &pemEnvCertLen);
    CHECK_RTN

    
    std::string strEnvCert;
    strEnvCert.assign(pemEnvCert, pemEnvCert + pemEnvCertLen);
    
    
    //”√÷§ È—È«© nohash//失败,返回值7
//    rtn = SpcVerifySignDataNoHash(szCert, nCertLen, digest, digestLen, szSign1, nSignLen1);
//    CHECK_RTN
    
    //”√÷§ È—È«© plain
    rtn = SpcVerifySignData(szCert, nCertLen, &random[0], 8, szSign2, nSignLen2);
    CHECK_RTN
    
    //πÿ±’…Ë±∏
    rtn = SpcClearEnv();
    CHECK_RTN
    
    return rtn;
}


