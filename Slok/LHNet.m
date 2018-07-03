//
//  LHNet.m
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/11.
//  Copyright © 2017年 supude. All rights reserved.
//

#import "LHNet.h"

@implementation LHNet
+ (instancetype)shareInstence
{
    static LHNet *_manager = nil;
    
    if (_manager == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [[LHNet alloc] init];
        });
    }
    
    return _manager;
}

- (void)postRequest:(NSString *)url param:(NSDictionary *)param handler:(NetworkHandler)handler
{
    AFHTTPSessionManager *networkManger = [AFHTTPSessionManager manager];
    
    NSSet *contentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    networkManger.responseSerializer.acceptableContentTypes = contentTypes;
    
    [self startNetworkActivityAnimating];
    
    [networkManger POST:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
            
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            handler(responseObject,nil);
            
            [self stopNetworkActivityAnimating];
            
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            handler(nil,error);
            
            [self stopNetworkActivityAnimating];
            
    }];
}

- (void)getRequest:(NSString *)url wechatAuthorizationParam:(NSDictionary *)param handler:(NetworkHandler)handler
{
    AFHTTPSessionManager *networkManger = [AFHTTPSessionManager manager];
    networkManger.requestSerializer = [AFJSONRequestSerializer serializer];//请求
    networkManger.responseSerializer = [AFHTTPResponseSerializer serializer];//响应
    networkManger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain", nil, nil];
    
    [self startNetworkActivityAnimating];
    
    [networkManger GET:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        handler(responseObject,nil);
        
        [self stopNetworkActivityAnimating];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        handler(nil,error);
        
        [self stopNetworkActivityAnimating];
        
    }];
}
- (void)getRequest:(NSString *)url wechatUserInfoParam:(NSDictionary *)param handler:(NetworkHandler)handler
{
    AFHTTPSessionManager *networkManger = [AFHTTPSessionManager manager];
    
    networkManger.requestSerializer = [AFJSONRequestSerializer serializer];
    
    networkManger.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self startNetworkActivityAnimating];
    
    [networkManger GET:url parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        handler(responseObject,nil);
        
        [self stopNetworkActivityAnimating];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        handler(nil,error);
        
        [self stopNetworkActivityAnimating];
        
    }];
}
-(void)isNetworkReachability:(ReachabilityStatus)statu
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        statu(status);
        
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)startNetworkActivityAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    });
}

- (void)stopNetworkActivityAnimating
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    });
}


@end
