

#ifndef _SPSECUREAPI_H
#define _SPSECUREAPI_H

#ifdef WIN32
#include <windows.h>
#else
typedef unsigned int UINT;
typedef unsigned char BYTE;
#endif
#ifdef __cplusplus
extern "C"{
#endif
    
    UINT SpcInitEnvEx();
    
    UINT SpcClearEnv();
    
    UINT SpcVerifyPIN(BYTE* szPIN, UINT nPINLen, UINT* retryTimes);
    
    UINT SpcChangePIN (BYTE* szOldPIN, UINT nOldPINLen, BYTE* szNewPIN, UINT nNewPINLen, UINT* retryTimes);
    
    UINT SpcGetRandom(BYTE* szRandom, UINT nRandomLen);
    
    UINT SpcSignData(BYTE* szInData, UINT nInDataLen,
                     BYTE* szSignData, UINT* nSignDataLen);
    
    UINT SpcSignDataNoHash(BYTE* szInData, UINT nInDataLen,
                           BYTE* szSignData, UINT* nSignDataLen);
    
    UINT SpcVerifySignData(BYTE* szCert, UINT nCertLen,
                           BYTE* szInData, UINT nInDataLen,
                           BYTE* szSignData, UINT nSignDataLen);
    
    UINT SpcVerifySignDataNoHash(BYTE* szCert, UINT nCertLen,
                                 BYTE* szInData, UINT nInDataLen,
                                 BYTE* szSignData, UINT nSignDataLen);
    
    UINT SpcSHA1Digest(BYTE* szInfo, UINT nInfoLen, BYTE* szSha1, UINT* nSha1Len);
    
    UINT SpcEncodePEM(BYTE* szInData, UINT nInDataLen,
                      BYTE* szOutData, UINT* nOutDataLen);
    
    UINT SpcDecodePEM(BYTE* szInData, UINT nInDataLen,
                      BYTE* szOutData, UINT* nOutDataLen);
    
    char* SpcGetErrMsg(UINT errCode);
    
    
    UINT SpcGetCardID(BYTE* szCardID, UINT* nCardIDLen);
    
    
    UINT SpcGetSignCert(BYTE *szCert, UINT* nCertLen);
    
    
    UINT SpcGetEnvCert(BYTE *szEnvCert, UINT* nEnvCertLen);
    
    UINT SpcGetCardUserInfo(char* szInfo, UINT* nInfoLen);
    
    
    UINT SpcSymEncrypt(UINT nFlag, BYTE* szInData, UINT nInDataLen,
                       BYTE* szOutData, UINT* nOutDataLen, BYTE* szKey);
    
    
    UINT SpcSymDecrypt(UINT nFlag, BYTE* szInData, UINT nInDataLen,
                       BYTE* szOutData, UINT* nOutDataLen, BYTE* szKey);
    
#ifdef __cplusplus
}
#endif
#endif

//
//#ifndef _SPSECUREAPI_H_H_
//#define _SPSECUREAPI_H_H_
//
//#ifdef __cplusplus
//extern "C"{
//#endif
//    
//    
//    /**
//     * @brief  设置硬件设备的优先级
//     *
//     * @method:	SpcSetInitEnvPriority
//     * @access:	private
//     * @param: 	char * szInitEnvPriority
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/9/7   15:15
//     */
//    //UINT __stdcall SpcSetInitEnvPriority(char* szInitEnvPriority);
//    
//    
//    /**
//     * @brief    打开卡
//     *
//     * @method:	SpcInitEnvEx
//     * @access:	private
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:00
//     */
//    UINT __stdcall SpcInitEnvEx();
//    /**
//     * @brief    关闭卡
//     *
//     * @method:	SpcClearEnv
//     * @access:	private
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:00
//     */
//    UINT __stdcall SpcClearEnv();
//    /**
//     * @brief     验证口令
//     *
//     * @method:	SpcVerifyPIN
//     * @access:	private
//     * @param: 	BYTE * szPIN
//     * @param: 	UINT nPINLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:00
//     */
//    UINT __stdcall SpcVerifyPIN(BYTE* szPIN, UINT nPINLen, UINT* retryTimes);
//    /**
//     * @brief    修改口令
//     *
//     * @method:	SpcChangePIN
//     * @access:	private
//     * @param: 	BYTE * szOldPIN
//     * @param: 	UINT nOldPINLen
//     * @param: 	BYTE * szNewPIN
//     * @param: 	UINT nNewPINLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:01
//     */
//    UINT __stdcall SpcChangePIN (BYTE* szOldPIN, UINT nOldPINLen,
//                                 BYTE* szNewPIN, UINT nNewPINLen, UINT* retryTimes);
//    /**
//     * @brief    取随机数
//     *
//     * @method:	SpcGetRandom
//     * @access:	private
//     * @param: 	BYTE * szRandom
//     * @param: 	UINT nRandomLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:01
//     */
//    UINT __stdcall SpcGetRandom(BYTE* szRandom, UINT nRandomLen);
//    /**
//     * @brief    数据签名
//     *
//     * @method:	SpcSignData
//     * @access:	private
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szSignData
//     * @param: 	UINT * nSIgnDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:01
//     */
//    UINT __stdcall SpcSignData(BYTE* szInData, UINT nInDataLen,
//                               BYTE* szSignData, UINT* nSIgnDataLen);
//    /**
//     * @brief    NoHash签名
//     *
//     * @method:	SpcSignDataNoHash
//     * @access:	private
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szSignData
//     * @param: 	UINT * nSIgnDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:02
//     */
//    UINT __stdcall SpcSignDataNoHash(BYTE* szInData, UINT nInDataLen,
//                                     BYTE* szSignData, UINT* nSIgnDataLen);
//    /**
//     * @brief     验签
//     *
//     * @method:	SpcVerifySignData
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szSignData
//     * @param: 	UINT nSignDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:02
//     */
//    UINT __stdcall SpcVerifySignData(BYTE* szCert, UINT nCertLen,
//                                     BYTE* szInData, UINT nInDataLen,
//                                     BYTE* szSignData, UINT nSignDataLen);
//    /**
//     * @brief     NoHash验签
//     *
//     * @method:	SpcVerifySignDataNoHash
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szSignData
//     * @param: 	UINT nSignDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:02
//     */
//    UINT __stdcall SpcVerifySignDataNoHash(BYTE* szCert, UINT nCertLen,
//                                           BYTE* szInData, UINT nInDataLen,
//                                           BYTE* szSignData, UINT nSignDataLen);
//    /**
//     * @brief    sha1摘要
//     *
//     * @method:	SpcSHA1Digest
//     * @access:	private
//     * @param: 	BYTE * szInfo
//     * @param: 	UINT nInfoLen
//     * @param: 	BYTE * szSha1
//     * @param: 	UINT * nSha1Len
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:03
//     */
//    UINT __stdcall SpcSHA1Digest(BYTE* szInfo, UINT nInfoLen, BYTE* szSha1, UINT* nSha1Len);
//    /**
//     * @brief    PEM编码
//     *
//     * @method:	SpcEncodePEM
//     * @access:	private
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:04
//     */
//    UINT __stdcall SpcEncodePEM(BYTE* szInData, UINT nInDataLen,
//                                BYTE* szOutData, UINT* nOutDataLen);
//    /**
//     * @brief    PEM解码
//     *
//     * @method:	SpcDecodePEM
//     * @access:	private
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:04
//     */
//    UINT __stdcall SpcDecodePEM(BYTE* szInData, UINT nInDataLen,
//                                BYTE* szOutData, UINT* nOutDataLen);
//    /**
//     * @brief     获取错误信息
//     *
//     * @method:	SpcGetErrMsg
//     * @access:	private
//     * @param: 	UINT errCode
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:04
//     */
//    char* __stdcall SpcGetErrMsg(UINT errCode);
//    /**
//     * @brief    取安全模块版本号
//     *
//     * @method:	SpcGetModuleVer
//     * @access:	private
//     * @param: 	char * szVersion
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:04
//     */
//    UINT __stdcall SpcGetModuleVer(char* szVersion);
//    /**
//     * @brief    验证证书
//     *
//     * @method:	SpcVerifyCert
//     * @access:	private
//     * @param: 	BYTE * szRootCert
//     * @param: 	UINT nRootCertLen
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szTime
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:05
//     */
//    UINT __stdcall SpcVerifyCert(BYTE* szRootCert, UINT nRootCertLen,
//                                 BYTE* szCert, UINT nCertLen, BYTE* szTime);
//    /**
//     * @brief    获取证书的有效期
//     *
//     * @method:	SpcGetValidTimeFromCert
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szStartTime
//     * @param: 	BYTE * szEndTime
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:05
//     */
//    UINT __stdcall SpcGetValidTimeFromCert(BYTE* szCert, UINT nCertLen,
//                                           char* szStartTime, char* szEndTime);
//    /**
//     * @brief    数字信封加密
//     *
//     * @method:	SpcSealEnvelope
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:05
//     */
//    UINT __stdcall SpcSealEnvelope(BYTE* szCert, UINT nCertLen,
//                                   BYTE* szInData, UINT nInDataLen,
//                                   BYTE* szOutData, UINT* nOutDataLen);
//    /**
//     * @brief    数字信封解密
//     *
//     * @method:	SpcOpenEnvelope
//     * @access:	private
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:06
//     */
//    UINT __stdcall SpcOpenEnvelope(BYTE* szInData, UINT nInDataLen,
//                                   BYTE* szOutData, UINT* nOutDataLen);
//    /**
//     * @brief    取申请者名称
//     *
//     * @method:	SpcGetUName
//     * @access:	private
//     * @param: 	BYTE * szUserName
//     * @param: 	UINT * nUserNameLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:07
//     */
//    UINT __stdcall SpcGetUName(BYTE* szUserName, UINT* nUserNameLen);
//    
//    /**
//     * @brief    获得IC卡号
//     *
//     * @method:	SpcGetCardID
//     * @access:	private
//     * @param: 	BYTE * szCardID
//     * @param: 	UINT * nCardIDLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:08
//     */
//    UINT __stdcall SpcGetCardID(BYTE* szCardID, UINT* nCardIDLen);
//    /**
//     * @brief    获得所在单位名称
//     *
//     * @method:	SpcGetEntName
//     * @access:	private
//     * @param: 	BYTE * szEntName
//     * @param: 	UINT * nEntNameLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:08
//     */
//    UINT __stdcall SpcGetEntName(BYTE* szEntName, UINT* nEntNameLen);
//    /**
//     * @brief    获得单位代码
//     *
//     * @method:	SpcGetEntID
//     * @access:	private
//     * @param: 	BYTE * szEntID
//     * @param: 	UINT * nEntIDLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:08
//     */
//    UINT __stdcall SpcGetEntID(BYTE* szEntID, UINT* nEntIDLen);
//    /**
//     * @brief    获得证书号
//     *
//     * @method:	SpcGetCertNo
//     * @access:	private
//     * @param: 	BYTE * szCertNo
//     * @param: 	UINT * nCertNoLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:09
//     */
//    UINT __stdcall SpcGetCertNo(BYTE* szCertNo, UINT* nCertNoLen);
//    /**
//     * @brief    获得所在单位类别
//     *
//     * @method:	SpcGetEntMode
//     * @access:	private
//     * @param: 	BYTE * szEntMode
//     * @param: 	UINT * nEntModeLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:09
//     */
//    UINT __stdcall SpcGetEntMode(BYTE* szEntMode, UINT* nEntModeLen);
//    /**
//     * @brief    用公钥验签
//     *
//     * @method:	SpcVerifySignWithPubKey
//     * @access:	private
//     * @param: 	BYTE * szPubKey
//     * @param: 	UINT nPubKeyLen
//     * @param: 	BYTE * szIn
//     * @param: 	UINT nInLen
//     * @param: 	BYTE * szSign
//     * @param: 	UINT nSignLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:09
//     */
//    UINT __stdcall SpcVerifySignWithPubKey(BYTE *szPubKey, UINT nPubKeyLen,
//                                           BYTE *szIn, UINT nInLen,
//                                           BYTE *szSign, UINT nSignLen);
//    
//    /**
//     * @brief  用公钥验签
//     *
//     * @method:	SpcVerifySignNohashWithPubKey
//     * @access:	private
//     * @param: 	BYTE * szPubKey
//     * @param: 	UINT nPubKeyLen
//     * @param: 	BYTE * szIn
//     * @param: 	UINT nInLen
//     * @param: 	BYTE * szSign
//     * @param: 	UINT nSignLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/9/7   15:15
//     */
//    UINT __stdcall SpcVerifySignNohashWithPubKey(BYTE *szPubKey, UINT nPubKeyLen,
//                                                 BYTE *szIn, UINT nInLen,
//                                                 BYTE *szSign, UINT nSignLen);
//    
//    /**
//     * @brief    取证书中的公钥
//     *
//     * @method:	SpcGetCertPubKey
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szPubKey
//     * @param: 	UINT * nPubKeyLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:10
//     */
//    UINT __stdcall SpcGetCertPubKey(BYTE *szCert,  UINT nCertLen,
//                                    BYTE *szPubKey, UINT *nPubKeyLen);
//    
//    /**
//     * @brief    取签名证书
//     *
//     * @method:	SpcGetSignCert
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT * nCertLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:10
//     */
//    UINT __stdcall SpcGetSignCert(BYTE *szCert, UINT* nCertLen);
//    
//    /**
//     * @brief    取加密证书
//     *
//     * @method:	SpcGetEnvCert
//     * @access:	private
//     * @param: 	BYTE * szEnvCert
//     * @param: 	UINT * nEnvCertLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:10
//     */
//    UINT __stdcall SpcGetEnvCert(BYTE *szEnvCert, UINT* nEnvCertLen);
//    /**
//     * @brief    获得用户信息
//     *
//     * @method:	SpcGetCardUserInfo
//     * @access:	private
//     * @param: 	char * szInfo
//     * @param: 	UINT * nInfoLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:10
//     */
//    UINT __stdcall SpcGetCardUserInfo(char* szInfo, UINT* nInfoLen);
//    /**
//     * @brief    取证书中的某项信息
//     *
//     * @method:	SpcGetCertInfo
//     * @access:	private
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	UINT nIndex
//     * @param: 	BYTE * szOut
//     * @param: 	UINT * nOutLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:11
//     */
//    UINT __stdcall SpcGetCertInfo(BYTE *szCert, UINT nCertLen, 
//                                  UINT nIndex, BYTE *szOut, UINT *nOutLen);
//    /**
//     * @brief    对称算法加密
//     * 
//     * @method:	SpcSymEncrypt
//     * @access:	private 
//     * @param: 	UINT nFlag
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @param: 	BYTE * szKey
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:11	
//     */
//    UINT __stdcall SpcSymEncrypt(UINT nFlag, BYTE* szInData, UINT nInDataLen,
//                                 BYTE* szOutData, UINT* nOutDataLen, BYTE* szKey);
//    
//    /**
//     * @brief    对称算法解密
//     * 
//     * @method:	SpcSymDecrypt
//     * @access:	private 
//     * @param: 	UINT nFlag
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @param: 	BYTE * szKey
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:11	
//     */
//    UINT __stdcall SpcSymDecrypt(UINT nFlag, BYTE* szInData, UINT nInDataLen,
//                                 BYTE* szOutData, UINT* nOutDataLen, BYTE* szKey);
//    /**
//     * @brief    RSA 加密
//     * 
//     * @method:	SpcRSAEncrypt
//     * @access:	private 
//     * @param: 	BYTE * szCert
//     * @param: 	UINT nCertLen
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:12	
//     */
//    UINT __stdcall SpcRSAEncrypt(BYTE* szCert, UINT nCertLen,
//                                 BYTE* szInData, UINT nInDataLen,
//                                 BYTE* szOutData, UINT* nOutDataLen);
//    /**
//     * @brief    RSA 解密
//     * 
//     * @method:	SpcRSADecrypt
//     * @access:	private 
//     * @param: 	BYTE * szInData
//     * @param: 	UINT nInDataLen
//     * @param: 	BYTE * szOutData
//     * @param: 	UINT * nOutDataLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:12	
//     */
//    UINT __stdcall SpcRSADecrypt(BYTE* szInData, UINT nInDataLen,
//                                 BYTE* szOutData, UINT* nOutDataLen);
//    /**
//     * @brief    取卡状态,100代表卡在,200代表卡不在读卡器中
//     * 
//     * @method:	SpcGetCardState
//     * @access:	private 
//     * @param: 	UINT nType
//     * @param: 	UINT nIndex
//     * @param: 	UINT * nState
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:12	
//     */
//    UINT __stdcall SpcGetCardState(UINT nType, UINT nIndex,UINT *nState);
//    /**
//     * @brief     取统一RA写入的附加信息
//     * 
//     * @method:	SpcGetCardAttachInfo
//     * @access:	private 
//     * @param: 	BYTE * szAttachInfo
//     * @param: 	UINT * nAttachInfoLen
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:13	
//     */
//    UINT __stdcall SpcGetCardAttachInfo(BYTE *szAttachInfo, UINT *nAttachInfoLen);
//    /**
//     * @brief    取发卡的RA类别
//     * 
//     * @method:	SpcGetRaType
//     * @access:	private 
//     * @param: 	UINT * nType
//     * @Return:	函数执行情况
//     * @retval:	0表示成功，非0表示失败
//     * @author:	吴超
//     * @since:	2016/8/1   17:13	
//     */
//    UINT __stdcall SpcGetRaType(UINT *nType);
//    
//#ifdef __cplusplus
//}
//#endif
//
//#endif
