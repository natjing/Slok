//
//  LoginControllerView.m
//  Slok
//
//  Created by user on 2018/4/4.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "LoginControllerView.h"

@interface LoginControllerView ()

@end

@implementation LoginControllerView

-(void)settingLoginControllerView
{
      self.loginstr.text=(NSString *)[LHToolManager keyPath:LHLogin withTarget:self];
    self.accountfield.placeholder = (NSString *)[LHToolManager keyPath:TJAccounttip withTarget:self];
    self.passwordfield.placeholder = (NSString *)[LHToolManager keyPath:LHPassword withTarget:self];
    //[self.accountfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    //[self.passwordfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.loginbutton setTitle:(NSString *)[LHToolManager keyPath:LHLogin withTarget:self] forState:UIControlStateNormal];
    
    [self.registerbutton setTitle:(NSString *)[LHToolManager keyPath:LHLoginRegistered withTarget:self] forState:UIControlStateNormal];
    
    self.forgetpassword.text=(NSString *)[LHToolManager keyPath:LHRetrievepassword withTarget:self];
    
     self.Continuewith.text=(NSString *)[LHToolManager keyPath:LHLoginContinuewith withTarget:self];
}

@end
