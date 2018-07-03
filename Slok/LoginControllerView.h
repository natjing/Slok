//
//  LoginControllerView.h
//  Slok
//
//  Created by user on 2018/4/4.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginControllerView : UIView
@property (weak, nonatomic) IBOutlet UILabel *loginstr;
@property (weak, nonatomic) IBOutlet UIView *Outloginview;

@property (weak, nonatomic) IBOutlet UITextField *accountfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordfield;
@property (weak, nonatomic) IBOutlet UIButton *loginbutton;
@property (weak, nonatomic) IBOutlet UIButton *registerbutton;
@property (weak, nonatomic) IBOutlet UILabel *forgetpassword;
@property (weak, nonatomic) IBOutlet UIView *wechatview;
@property (weak, nonatomic) IBOutlet UIView *googleview;
@property (weak, nonatomic) IBOutlet UIView *twitterview;
@property (weak, nonatomic) IBOutlet UIView *facebookview;
@property (weak, nonatomic) IBOutlet UILabel *Continuewith;


-(void)settingLoginControllerView;
@end
