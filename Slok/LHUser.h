//
//  LHUser.h
//  Slok
//
//  Created by LiuHao on 2017/5/31.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LHUser : NSObject
@property(nonatomic,strong)NSString *userAccount;
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)NSString *userPass;
@property(nonatomic,strong)NSString *userIsLogin;
@property(nonatomic,strong)NSString *userType;
@property(nonatomic,strong)NSString *userEmail;
@property(nonatomic,strong)NSString *userPhone;
@property(nonatomic,strong)NSString *FileVersion;
@property(nonatomic,strong)NSString *VersionName;
@end
