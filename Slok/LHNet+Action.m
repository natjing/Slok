
//
//  LHNet+Action.m
//  Slok
//
//  Created by LiuHao on 2017/5/23.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHNet+Action.h"
#import "LHNetKeyPathManager.h"
#define WechatAppID @"wx79448ec025725513"
#define WechatSecret @"000ea93d504177827c3246b721d03f1d"

@implementation LHNet (Action)
-(void)weChatAccessToken:(NSString *)authorizationCode handle:(NetworkHandler)handler
{
    NSString *tokenUrl = @"https://api.weixin.qq.com/sns/oauth2/access_token";
    
    NSDictionary *param = @{
                            LHAppIdKey : WechatAppID,
                            LHSecretKey : WechatSecret,
                            LHCodeKey : authorizationCode,
                            LHGrantTypeKey : LHAuthCodeValue
    };
    
    [self getRequest:tokenUrl wechatAuthorizationParam:param handler:handler];
}
-(void)weChatUserInfo:(NSString *)accessToken openId:(NSString *)openId handle:(NetworkHandler)handle
{
    NSString *userInfoUrl = @"https://api.weixin.qq.com/sns/userinfo";
    
    NSDictionary *param = @{
                            LHAccessTokenKey : accessToken,
                            LHOpenidkey : openId
                            };
    
    [self getRequest:userInfoUrl wechatUserInfoParam:param handler:handle];
}
-(void)postLogin:(NSString *)type userIdentity:(NSString *)userIdentity handle:(NetworkHandler)handle
{
    NSDictionary *param = @{
                            LHCodeKey : LHLoginVaule,
                            LHTypeKey : type,
                            LHNameKey : @"",
                            LHUserIdentityKey: userIdentity
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
-(void)postGainLockhandle:(NetworkHandler)handle
{
    NSString *language = [NSString stringWithFormat:@"%d",![LHToolManager isWhatLanguages]];
    
    IF_NO_USEFUL_RETURN([LHToolManager getUserId]);
    IF_NO_USEFUL_RETURN(language);
    
    NSDictionary *param = @{
                            LHCodeKey : LHLockListVaule,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLanguageKey : language
                            };
    NSLog(@"The%@\n",param);
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
    
}
-(void)postAddlock:(NSString *)lockNum lockMac:(NSString *)lockMac lockName:(NSString *)lockName handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockNum);
    IF_NO_USEFUL_RETURN(lockMac);
    IF_NO_USEFUL_RETURN(lockName);

    NSDictionary *param = @{
                            LHCodeKey : LHAddLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockNumKey : lockNum,
                            LHLockMacKey : lockMac,
                            LHLockNameKey : lockName
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postShareLockList:(NSString *)lockId handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockId);
    
    NSDictionary *param = @{
                            LHCodeKey : LHShareListValue,
                            LHLockIdKey : lockId,
                            LHUserIdKey : [LHToolManager getUserId]
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postDeleteLock:(NSString *)lockId handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockId);
    
    NSDictionary *param = @{
                            LHCodeKey : LHDeleteLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockIdKey : lockId
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postShareLock:(NSString *)shareName lockId:(NSString *)lockId handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockId);
    IF_NO_USEFUL_RETURN(shareName);
    
    NSDictionary *param = @{
                            LHCodeKey : LHShareLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockIdKey : lockId,
                            LHShareNameKey :shareName
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postCodeGainLock:(NSString *)lockName code:(NSString *)code handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockName);
    IF_NO_USEFUL_RETURN(code);
    NSDictionary *param = @{
                            LHCodeKey : LHCodeAddLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockNameKey : lockName,
                            LHCaptchaKey : code
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postDeleteShareLock:(NSString *)funId handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(funId);
    NSDictionary *param = @{
                            LHCodeKey : LHDeletShareLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHFunIdKey : funId
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postOpenHistory:(NSString *)lockId type:(NSString *)type handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockId);
    IF_NO_USEFUL_RETURN(type);
    NSDictionary *param = @{
                            LHCodeKey : LHOpenHistoryValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockIdKey : lockId,
                            LHTypeKey : type
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postHistoryList:(NSString *)offset limit:(NSString *)limit handle:(NetworkHandler)handle
{
    NSDictionary *param = @{
                            LHCodeKey : LHHistoryListValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHOffsetKey : offset,
                            LHLimitKey : limit
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postSendPushIdhandle:(NSString *)userId handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN([GeTuiSdk clientId]);
    
    NSDictionary *param = @{
                            LHCodeKey : LHpushIdValue,
                            LHUserIdKey : userId,
                            LHPushIdKey : [GeTuiSdk clientId]
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postDeletHistory:(NSString *)offset limit:(NSString *)limit handle:(NetworkHandler)handle
{
    NSDictionary *param = @{
                            LHCodeKey : LHDeleteHistoryValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHOffsetKey : offset,
                            LHLimitKey : limit
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postShareToEmail:(NSString *)lockId emailAdress:(NSString *)emailAdrss shareName:(NSString *)shareName handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockId);
    IF_NO_USEFUL_RETURN(emailAdrss);
    IF_NO_USEFUL_RETURN(shareName);
    NSDictionary *param = @{
                            LHCodeKey : LHShareEmailValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockIdKey : lockId,
                            LHShareNameKey :shareName,
                            LHToKey : emailAdrss
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)PostCodeByEmail:(NSString *)email handle:(NetworkHandler)handle
{
    NSString *language = [NSString stringWithFormat:@"%d",![LHToolManager isWhatLanguages]];
    if([language isEqualToString:@"0"]){
        language=@"1";
    }else if([language isEqualToString:@"1"]){
        language=@"0";
    }
    IF_NO_USEFUL_RETURN(language);
    IF_NO_USEFUL_RETURN(email);
    
    NSDictionary *param = @{
                            LHCodeKey : LHCodeByEmailValue,
                            LHEmail : email,
                            LHLanguageKey : language
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
-(void)postEmailRegistered:(NSString *)email username:(NSString *)username dcode:(NSString *)dcode password:(NSString *)password handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(email);
    IF_NO_USEFUL_RETURN(password);
    NSDictionary *param = @{
                            LHCodeKey : LHEmailRegistered,
                            LHemailKey : email,
                            LHUsername : username,
                            LHDcode : dcode,
                            LHPassWordKey : password
                            
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}

-(void)postLoginByEmail:(NSString *)email passWord:(NSString *)passWord handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(email);
    IF_NO_USEFUL_RETURN(passWord);
    NSDictionary *param = @{
                            LHCodeKey : LHLoginVaule,
                            LHTypeKey : @"5",
                            LHNameKey : @"",
                            LHPassWordKey : passWord,
                            LHPassWordId: passWord,
                            LHemailKey : email
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
-(void)postGainCodeByPhone:(NSString *)phone handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(phone);
    
    NSDictionary *param = @{
                            LHCodeKey : LHCodeByPhoneValue,
                            LHPhoneKey : phone
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
-(void)postLoginByPhone:(NSString *)phone passWord:(NSString *)passWord handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(phone);
    IF_NO_USEFUL_RETURN(passWord);
    NSDictionary *param = @{
                            LHCodeKey : LHLoginVaule,
                            LHTypeKey : @"6",
                            LHNameKey : @"",
                            LHPassWordKey : passWord,
                            LHPhoneKey : phone
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
-(void)postGainVoiceCode:(NSString *)phone handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(phone);
    
    NSDictionary *param = @{
                            LHCodeKey : LHCodeByPhoneVoiceValue,
                            LHPhoneKey : phone
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
-(void)postActionLock:(NSString *)lockId handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(lockId);
    
    NSDictionary *param = @{
                            LHCodeKey : LHActionLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockIdKey : lockId
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
-(void)postChangePassword:(NSString *)dcode Password:(NSString *)password handle:(NetworkHandler)handle
{
  
    
    NSDictionary *param = @{
                            LHCodeKey : LHChangePassword,
                            LHDcode : dcode,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHPassWordKey: password
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
//绑定邮箱
-(void)PostSubmitEmail:(NSString *)email handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(email);
    
    NSDictionary *param = @{
                            LHCodeKey : LHSubmitEmail,
                            LHEmail : email,
                            LHUserIdKey : [LHToolManager getUserId]
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
//忘记密码
-(void)postGetbackpassword:(NSString *)email dcode:(NSString *)dcode password:(NSString *)password handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(email);
    IF_NO_USEFUL_RETURN(password);
    NSDictionary *param = @{
                            LHCodeKey : LHGetbackPassword,
                            LHemailKey : email,
                            LHDcode : dcode,
                            LHPassWordKey : password
                            
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}
//获取好友请求
-(void)postGetfriendrequest:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN([LHToolManager getUserId]);
    NSDictionary *param = @{
                            LHCodeKey : TJGetFriendRequest,
                            LHUserIdKey : [LHToolManager getUserId]
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
    
}

//获取好友列表
-(void)postGetFriendsList:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN([LHToolManager getUserId]);
    NSDictionary *param = @{
                            LHCodeKey : TJGetFriendsList,
                            LHUserIdKey : [LHToolManager getUserId]
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
    
}
//搜索好友
-(void)postSearchFriends:(NSString *)keyword handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(keyword);
    NSDictionary *param = @{
                            LHCodeKey : TJGetSearchFriends,
                            LHUserIdKey : [LHToolManager getUserId],
                            @"keyword" : keyword
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}

//添加好友
-(void)postAddFriends:(NSString *)user_ids handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(user_ids);
    NSDictionary *param = @{
                            LHCodeKey : TJPostAddFriends,
                            LHUserIdKey : [LHToolManager getUserId],
                            @"user_ids" : user_ids
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}

//获取通讯录对应的好友信息
-(void)postGetFriendsData:(NSString *)phone handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(phone);
    NSDictionary *param = @{
                            LHCodeKey : TJGetFriendsData,
                            LHUserIdKey : [LHToolManager getUserId],
                            @"phone" : phone
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
//处理好友邀请
-(void)postAcceptInvitation:(NSString *)user_ids friend_status :(NSString *)friend_status handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(user_ids);
    NSDictionary *param = @{
                            LHCodeKey : TJAcceptInvitation,
                            LHUserIdKey : [LHToolManager getUserId],
                            @"user_ids" : user_ids,
                            @"friend_status":friend_status//1为接受，2为不接受
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}


//将钥匙分享给指定的好友
-(void)postShareFriend:(NSString *)user_ids lockid:(NSString *)lock_id handle:(NetworkHandler)handle
{
    IF_NO_USEFUL_RETURN(user_ids);
    NSDictionary *param = @{
                            LHCodeKey : TJShareFriend,
                            LHUserIdKey : [LHToolManager getUserId],
                            @"user_ids" : user_ids,
                            @"lock_id":lock_id
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
//删除好友
-(void)postDeletefriend:(NSString *)friends_id handle:(NetworkHandler)handle
{
    NSDictionary *param = @{
                            LHCodeKey : TJPostDeletefriend,
                            LHUserIdKey : [LHToolManager getUserId],
                            @"friends_id" : friends_id
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}

//扫描加锁
-(void)postScanAddLock:(NSString *)lock_type locknum:(NSString *)lock_num lockmac:(NSString *)lock_mac lockname:(NSString *)lock_name lockbei:(NSString *)bei handle:(NetworkHandler)handle
{
 
    NSDictionary *param = @{
                            LHCodeKey : TJScanAddLockValue,
                            LHUserIdKey : [LHToolManager getUserId],
                            LHLockNum : lock_num,
                            LHLockMac:lock_mac,
                            LHLocksName:lock_name,
                            TJLockType:lock_type,
                            @"bei":bei
                            };
    
    [self postRequest:LHBaseUrl param:[LHToolManager secrecyParam:param] handler:handle];
}
//账号注册
-(void)postAccountRegistered:(NSString *)email user_name:(NSString *)user_name phone:(NSString *)phone password:(NSString *)password handle:(NetworkHandler)handle
{
     
    NSDictionary *param = @{
                            LHCodeKey : TJAccountRegistered,
                            LHemailKey : email,
                            TJUsername : user_name,
                            LHPhone : phone,
                            LHPassWordKey : password
                            
                            };
    
    [self postRequest:LHBaseUrl param:param handler:handle];
}

//获取文件信息
-(void)postGetfileversion:(NetworkHandler)handle
{
    NSDictionary *param = @{
                            LHCodeKey : TJAccountRegistered};
    
    // [self postRequest:@"http://dl.spdkey.com/slok_device_version/version.xml" param:param handler:handle];
    [self getRequest:@"http://dl.spdkey.com/slok_device_version/version.xml" wechatUserInfoParam:param handler:handle];
}

@end










