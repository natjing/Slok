//
//  LHNet+Action.h
//  Slok
//
//  Created by LiuHao on 2017/5/23.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHNet.h"

@interface LHNet (Action)
-(void)weChatAccessToken:(NSString *)authorizationCode handle:(NetworkHandler)handler;
-(void)weChatUserInfo:(NSString *)accessToken openId:(NSString *)openId handle:(NetworkHandler)handle;
#pragma mark - 邮箱注册
-(void)postEmailRegistered:(NSString *)email username:(NSString *)username dcode:(NSString *)dcode password:(NSString *)password handle:(NetworkHandler)handle;
#pragma mark - 登录
-(void)postLogin:(NSString *)type userIdentity:(NSString *)userIdentity handle:(NetworkHandler)handle;
#pragma mark - 获取钥匙列表
-(void)postGainLockhandle:(NetworkHandler)handle;
#pragma mark - 添加锁
-(void)postAddlock:(NSString *)lockNum lockMac:(NSString *)lockMac lockName:(NSString *)lockName handle:(NetworkHandler)handle;
#pragma mark - 分享锁列表
-(void)postShareLockList:(NSString *)lockId handle:(NetworkHandler)handle;
#pragma mark - 删除锁
-(void)postDeleteLock:(NSString *)lockId handle:(NetworkHandler)handle;
#pragma mark - 分享锁
-(void)postShareLock:(NSString *)shareName lockId:(NSString *)lockId handle:(NetworkHandler)handle;
#pragma mark - 验证码添加锁
-(void)postCodeGainLock:(NSString *)lockName code:(NSString *)code handle:(NetworkHandler)handle;
#pragma mark - 删除分享锁
-(void)postDeleteShareLock:(NSString *)funId handle:(NetworkHandler)handle;
#pragma mark - 记录开锁记录
-(void)postOpenHistory:(NSString *)lockId type:(NSString *)type handle:(NetworkHandler)handle;
#pragma mark - 开锁记录列表
-(void)postHistoryList:(NSString *)offset limit:(NSString *)limit handle:(NetworkHandler)handle;
#pragma mark - 添加pushid
-(void)postSendPushIdhandle:(NSString *)userId handle:(NetworkHandler)handle;
#pragma mark - 删除记录
-(void)postDeletHistory:(NSString *)offset limit:(NSString *)limit handle:(NetworkHandler)handle;
#pragma mark - 分享到邮箱
-(void)postShareToEmail:(NSString *)lockId emailAdress:(NSString *)emailAdrss shareName:(NSString *)shareName handle:(NetworkHandler)handle;
#pragma mark - 邮箱验证码
-(void)PostCodeByEmail:(NSString *)email handle:(NetworkHandler)handle;
#pragma mark - 邮箱登录
-(void)postLoginByEmail:(NSString *)email passWord:(NSString *)passWord handle:(NetworkHandler)handle;
#pragma mark - 手机验证码
-(void)postGainCodeByPhone:(NSString *)phone handle:(NetworkHandler)handle;
#pragma mark - 手机登录
-(void)postLoginByPhone:(NSString *)phone passWord:(NSString *)passWord handle:(NetworkHandler)handle;
#pragma mark - 语音验证码
-(void)postGainVoiceCode:(NSString *)phone handle:(NetworkHandler)handle;
#pragma mark - 激活锁
-(void)postActionLock:(NSString *)lockId handle:(NetworkHandler)handle;
#pragma mark - 修改密码
-(void)postChangePassword:(NSString *)dcode Password:(NSString *)password handle:(NetworkHandler)handle;
#pragma mark - 绑定邮箱
-(void)PostSubmitEmail:(NSString *)email handle:(NetworkHandler)handle;
#pragma mark - 忘记密码重新设置
-(void)postGetbackpassword:(NSString *)email dcode:(NSString *)dcode password:(NSString *)password handle:(NetworkHandler)handle;
#pragma mark - 好友邀请信息
-(void)postGetfriendrequest:(NetworkHandler)handle;
#pragma mark - 好友列表
-(void)postGetFriendsList:(NetworkHandler)handle;
#pragma mark - 搜索好友
-(void)postSearchFriends:(NSString *)keyword handle:(NetworkHandler)handle;
#pragma mark - 添加好友
-(void)postAddFriends:(NSString *)user_ids handle:(NetworkHandler)handle;
#pragma mark - 获取电话号码对应的用户信息
-(void)postGetFriendsData:(NSString *)phone handle:(NetworkHandler)handle;
#pragma mark - 处理好友请求
-(void)postAcceptInvitation:(NSString *)user_ids friend_status :(NSString *)friend_status handle:(NetworkHandler)handle;
#pragma mark - 删除好友
-(void)postDeletefriend:(NSString *)friends_id handle:(NetworkHandler)handle;
#pragma mark -将钥匙分享给指定的好友
-(void)postShareFriend:(NSString *)user_ids lockid:(NSString *)lock_id handle:(NetworkHandler)handle;
#pragma mark -扫描加锁
-(void)postScanAddLock:(NSString *)lock_type locknum:(NSString *)lock_num lockmac:(NSString *)lock_mac lockname:(NSString *)lock_name lockbei:(NSString *)bei handle:(NetworkHandler)handle;
#pragma mark - 账号注册
-(void)postAccountRegistered:(NSString *)email user_name:(NSString *)user_name phone:(NSString *)phone password:(NSString *)password handle:(NetworkHandler)handle;
#pragma mark - 获取文件信息
-(void)postGetfileversion:(NetworkHandler)handle;
@end
