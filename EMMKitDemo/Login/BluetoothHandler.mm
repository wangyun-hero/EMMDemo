//
//  BluetoothHandler.m
//  EMMKitDemo
//
//  Created by zm on 2016/11/29.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "BluetoothHandler.h"
#import "bleobj.h"
#import"blec.h"
#import <vector>
#import <string>
#import "spsecureapi.h"

@implementation BluetoothHandler

+ (void)getCardUserInfo:(bluetoothBlock)block{
    UINT rtn;
    rtn = SpcInitEnvEx();
    if(rtn != 0){
        block(NO,@"打开蓝牙失败");
        return;
    }
    
    char info[1000] = {0};
    UINT infoLen  = 1000;
    rtn = SpcGetCardUserInfo(info, &infoLen);
    if (rtn !=0) {
         SpcClearEnv();
        char *c = SpcGetErrMsg(rtn);
        block(NO,[BluetoothHandler enCodingFromChar:c]);
        return;
    }
    SpcClearEnv();
    char *rs = new char[infoLen];
    strcpy(rs, info);
    
    block(YES,[BluetoothHandler enCodingFromChar:rs]);

}

+ (void)getCardID:(bluetoothBlock)block{
    UINT rtn;
    rtn = SpcInitEnvEx();
    if(rtn != 0){
        block(NO,@"打开蓝牙失败");
         return;
    }
    
    BYTE szCardID[20] = {0};
    UINT nCardIDLen = 20;
    rtn = SpcGetCardID(szCardID, &nCardIDLen);
    if(rtn != 0){
        char *c = SpcGetErrMsg(rtn);
        SpcClearEnv();
        block(NO,[BluetoothHandler enCodingFromChar:c]);
         return;
    }
    SpcClearEnv();
    char *rs = new char[nCardIDLen];
    for(int i=0;i<nCardIDLen;i++) {
        rs[i] = szCardID[i];
    }
    block(YES,[BluetoothHandler enCodingFromChar:rs]);
}

+ (void)checkPWD:(unsigned char *)pin resultBlock:(bluetoothBlock)block;{
    UINT rtn;
    rtn = SpcInitEnvEx();
    if(rtn != 0){
        block(NO,@"打开蓝牙失败");
         return;
    }

    UINT retryTimes;
    // 蓝牙卡验证密码失败
    rtn = SpcVerifyPIN(pin, 8, &retryTimes);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验证密码失败");
         return;
    }
    
    SpcClearEnv();
    block(YES,@"");

}

+ (void)signName:(unsigned char *)random randomLen:(unsigned int)randomLen pin:(unsigned char *)pin resultBlock:(bluetoothBlock)block{
    UINT rtn;
    rtn = SpcInitEnvEx();
    
    if(rtn != 0){
        // 打开蓝牙失败
        block(NO,@"打开蓝牙失败");
        return;
    }
    
    UINT retryTimes;
    rtn = SpcVerifyPIN(pin, 8, &retryTimes);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验证密码失败");
         return;
    }

    
    //随机数PEM解码
    BYTE random1[128] = {0};
    UINT randomLen1 = 128;
    rtn = SpcDecodePEM(random, randomLen, random1, &randomLen1);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
         return;
    }
    
    //签名
    BYTE szSign2[256] ={0};
    UINT nSignLen2 = 256;
    rtn = SpcSignData(random1, randomLen1, szSign2, &nSignLen2);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
         return;
    }
    
    //签名PEM编码
    BYTE pemSignCert[5000] = {0};
    UINT pemSignCertLen = 5000;
    rtn = SpcEncodePEM(szSign2, nSignLen2, pemSignCert, &pemSignCertLen);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
         return;
    }
    
    //获取证书
    UINT nCertLen = 5000;
    std::vector<BYTE> szCert(nCertLen, 0);
    rtn = SpcGetSignCert(&szCert[0], &nCertLen);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
         return;
    }
    
    //验签
    rtn = SpcVerifySignData(&szCert[0], nCertLen, &random1[0], randomLen1, szSign2, nSignLen2);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
         return;
    }
    
    SpcClearEnv();
    if (rtn == 0) {
        char *rs = new char[pemSignCertLen];
        for(int i=0;i<pemSignCertLen;i++) {
            rs[i] = pemSignCert[i];
        }
        block(YES,[NSString stringWithCString:rs encoding:NSASCIIStringEncoding]);
    }else{
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
         return;
    }

}

+ (void)signData:(unsigned char *)random randomLen:(unsigned int)randomLen pin:(unsigned char *)pin resultBlock:(bluetoothBlock)block{
    UINT rtn;
    rtn = SpcInitEnvEx();
    
    if(rtn != 0){
        // 打开蓝牙失败
        block(NO,@"打开蓝牙失败");
        return;
    }
    
    UINT retryTimes;
    rtn = SpcVerifyPIN(pin, 8, &retryTimes);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验证密码失败");
        return;
    }
    
    
    //签名
    BYTE szSign2[256] ={0};
    UINT nSignLen2 = 256;
    rtn = SpcSignData(random, randomLen, szSign2, &nSignLen2);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
        return;
    }
    
    //签名PEM编码
    BYTE pemSignCert[5000] = {0};
    UINT pemSignCertLen = 5000;
    rtn = SpcEncodePEM(szSign2, nSignLen2, pemSignCert, &pemSignCertLen);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
        return;
    }
    
    //获取证书
    UINT nCertLen = 5000;
    std::vector<BYTE> szCert(nCertLen, 0);
    rtn = SpcGetSignCert(&szCert[0], &nCertLen);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
        return;
    }
    
    //验签
    rtn = SpcVerifySignData(&szCert[0], nCertLen, &random[0], randomLen, szSign2, nSignLen2);
    if(rtn != 0){
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
        return;
    }
    
    SpcClearEnv();
    if (rtn == 0) {
        char *rs = new char[pemSignCertLen];
        for(int i=0;i<pemSignCertLen;i++) {
            rs[i] = pemSignCert[i];
        }
        block(YES,[BluetoothHandler enCodingFromChar:rs]);
    }else{
        SpcClearEnv();
        block(NO,@"蓝牙卡验签失败");
        return;
    }
    
}


+ (NSString *)enCodingFromChar:(char *)c{
    NSData *data = [[NSData alloc] initWithBytes:c length:strlen(c)];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *string = [[NSString alloc] initWithData:data encoding:enc];
    return string;
}

+ (unsigned char *)enCodingFromString:(NSString *)string{
    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    const char* ss = [string cStringUsingEncoding:enc];
    unsigned long len = strlen(ss);
    unsigned char* rr = new unsigned  char[len];
    for(int i=0;i<len;i++) {
        rr[i] = ss[i];
    }
    return rr;
}

@end
