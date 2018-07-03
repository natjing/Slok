//
//  LHSettingViewController.h
//  Slok
//
//  Created by LiuHao on 2017/5/27.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LHSwitchLanguageDelegate<NSObject>
-(void)isRefreshViewToChangeLanguage;
@end
@interface LHSettingViewController : UIViewController
@property(nonatomic,assign)id<LHSwitchLanguageDelegate> languageDelegate;
@property Boolean ifshow;
@end
