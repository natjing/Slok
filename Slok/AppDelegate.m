//
//  AppDelegate.m
//  Slok
//
//  Created by LiuHao on 2017/5/20.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "AppDelegate.h"
 
#define WechatAppID @"wxabeda6699af7f7c1"
#define WechatSecret @"e5d01dbc1dcb651b9d2e35b5a10a846e"
#define FacebookID @"fb801185880040042"
#define kGtAppId           @"L33N2eE8NB7Mri6VszFrc"
#define kGtAppKey          @"CLwPWgADvz9XfGM9h3l8k7"
#define kGtAppSecret       @"trkK8FXJlJ7ALFDLgvjiQ1"
#define TWConsumerKey @"g38txZ4iAB8LF7r3dV5JO9f2c"
#define TWConsumerSecret @"Tr4j8uMQU7xhfGXyDay23DsmXMLoRDhK9E13XO5raJLDrrESPh"
#define USHARE_DEMO_APPKEY @"5941f39c677baa4b880002ce"
@interface AppDelegate ()<WXApiDelegate>
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //********************语言管理
    [self manageLanguage];
    //********************微信
    [WXApi registerApp:WechatAppID enableMTA:false];
    //********************facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    //********************Twitter
    [[Twitter sharedInstance] startWithConsumerKey:TWConsumerKey consumerSecret:TWConsumerSecret];
    //********************友盟
    [[UMSocialManager defaultManager] openLog:YES];
    
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_DEMO_APPKEY];
    
    [self configUSharePlatforms];
    
    [self confitUShareSettings];
    //********************个推
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    // 注册 APNs
    [self registerRemoteNotification];
    
    [self cleanBugInAppIcon];
    //在这里显示导航栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //设置声音
    [self initVolumeViewInAppDelegate];
    return YES;
    
}
-(void)initVolumeViewInAppDelegate
{
    _volumeSlider = [[UISlider alloc] init];
    
    [self.window addSubview:_volumeSlider];
    
    _volumeView = [[MPVolumeView alloc] init];
    
    _volumeView.showsRouteButton = NO;
    //默认YES，这里为了突出，故意设置一遍
    _volumeView.showsVolumeSlider = YES;
    
    [_volumeView sizeToFit];
    [_volumeView setFrame:CGRectMake(-1000, -1000, 10, 10)];
    
    [self.window addSubview:_volumeView];
    [_volumeView userActivity];
    
    for (UIView *view in [_volumeView subviews]){
        if ([[view.class description] isEqualToString:@"MPVolumeSlider"]){
            _volumeSlider = (UISlider*)view;
            break;
        }
    }
}
-(void)backUserVolume
{
    if(self.volumeSlider.value != self.sysVolume)
    {
        self.volumeSlider.value = self.sysVolume;
    }
}
#pragma mark - 语言管理
-(void)manageLanguage
{
    BOOL isManual = [LHDataManager getBoolValue:LHIsManualLanguage];
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"] || !isManual) {
        
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        
        if ([language hasPrefix:@"zh-Hans"]) {//开头匹配
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
        }else if([language hasPrefix:@"it"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"it" forKey:@"appLanguage"];
        }else if([language hasPrefix:@"fr"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"fr" forKey:@"appLanguage"];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
        }
        
    }
}
#pragma mark - 请除通知
-(void)cleanBugInAppIcon
{
    UIApplication *app = [UIApplication sharedApplication];
    app.applicationIconBadgeNumber = 0;
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [app registerUserNotificationSettings:setting];
}
#pragma mark - 友盟
- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

- (void)configUSharePlatforms
{
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WechatAppID appSecret:WechatSecret redirectURL:@"http://mobile.umeng.com/social"];
}
#pragma mark - 个推
- (void)registerRemoteNotification {
    /*
     警告：Xcode8 需要手动开启"TARGETS -> Capabilities -> Push Notifications"
     */
    
    /*
     警告：该方法需要开发者自定义，以下代码根据 APP 支持的 iOS 系统不同，代码可以对应修改。
     以下为演示代码，注意根据实际需要修改，注意测试支持的 iOS 系统都能获取到 DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert |
                                                                       UIRemoteNotificationTypeSound |
                                                                       UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}
#pragma mark - Facebook登录/微信登录
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    BOOL isHandle = NO;
    
    if(!LHDataManager.isWechatShare)
    {
        isHandle = [[UMSocialManager defaultManager] handleOpenURL:url];
    }
    
    if(!isHandle)
    {
    if ([url.absoluteString hasPrefix:WechatAppID])
    {
        isHandle =  [WXApi handleOpenURL:url delegate:self];
    }
    }
    
    return isHandle;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL isHandle = NO;
    
    if(!LHDataManager.isWechatShare)
    {
        isHandle = [[UMSocialManager defaultManager] handleOpenURL:url];
    }
    
    if(!isHandle)
    {
    
    if ([url.absoluteString hasPrefix:WechatAppID])
    {
        isHandle =  [WXApi handleOpenURL:url delegate:self];
        
    }else if([url.absoluteString hasPrefix:FacebookID])
    {
        isHandle = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    
                    ];
    }
    }
    
   
   return isHandle;
}

-(void)onReq:(BaseReq *)req {
    
    
}
-(void)onResp:(BaseResp *)resp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:LHWechatNotice object:resp];
}
#pragma mark - witter登录

#pragma mark - Facebook登录/微信登录/
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {

    BOOL isHandle = NO;
    
    if(!LHDataManager.isWechatShare)
    {
    isHandle = [[UMSocialManager defaultManager] handleOpenURL:url];
    }
    
    if(!isHandle)
    {
    
        if([[LHToolManager getLoginType] isEqualToString:@"1"]){
            isHandle = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                        openURL:url
                                                            sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                                   annotation:options[UIApplicationOpenURLOptionsAnnotationKey]
                        
                        ];
        }else if([[LHToolManager getLoginType] isEqualToString:@"3"]){
            isHandle = [WXApi handleOpenURL:url delegate:self];
        }else  if([[LHToolManager getLoginType] isEqualToString:@"4"]){
             isHandle = [[Twitter sharedInstance] application:application openURL:url options:options];
        }else if([[LHToolManager getLoginType] isEqualToString:@"8"]){
            
        }
    }
    return isHandle;
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    //fb登录
    [FBSDKAppEvents activateApp];
    //获取声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    CGFloat volume = audioSession.outputVolume;
    
    
    self.sysVolume = volume;
    
    if(volume < 0.9)
    {
        self.volumeSlider.value = 0.9;
    }
    
    }
#pragma mark - 个推
/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
      //NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", token);
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", token);
    // 向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}
/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    
    [LHToolManager.rootViewController reloadDataInViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:LHPushNotice object:[LHToolManager dictionaryWithJsonString:payloadMsg]];
}
/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    // 处理APNs代码，通过userInfo可以取到推送的信息（包括内容，角标，自定义参数等）。如果需要弹窗等其他操作，则需要自行编码。
    NSLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n",userInfo);
    
    //静默推送收到消息后也需要将APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
     [self backUserVolume];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       [[NSNotificationCenter defaultCenter]postNotificationName:@"controllerreconnectBluetooth"object:nil];
     [[NSNotificationCenter defaultCenter]postNotificationName:@"htconnectionPeripehrals"object:nil];
     [self backUserVolume];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  
}

@end
