//
//  LHNet.h
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/11.
//  Copyright © 2017年 supude. All rights reserved.
//

#import <Foundation/Foundation.h>
#define LHNetworkManager [LHNet shareInstence]
typedef void(^NetworkHandler)(id result, NSError *error);
typedef void(^ReachabilityStatus)(AFNetworkReachabilityStatus status);
@interface LHNet : NSObject
+ (instancetype)shareInstence;
- (void)postRequest:(NSString *)url param:(NSDictionary *)param handler:(NetworkHandler)handler;
- (void)getRequest:(NSString *)url wechatAuthorizationParam:(NSDictionary *)param handler:(NetworkHandler)handler;
- (void)getRequest:(NSString *)url wechatUserInfoParam:(NSDictionary *)param handler:(NetworkHandler)handler;
-(void)isNetworkReachability:(ReachabilityStatus)statu;
@end
