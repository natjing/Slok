//
//  AppDelegate.h
//  Slok
//
//  Created by LiuHao on 2017/5/20.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
 
@interface AppDelegate : UIResponder <UIApplicationDelegate, GeTuiSdkDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) CGFloat sysVolume;
@property (nonatomic,strong)MPVolumeView *volumeView;
@property (strong, nonatomic)UISlider *volumeSlider;
@end

