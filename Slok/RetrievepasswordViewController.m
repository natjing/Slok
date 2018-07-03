//
//  RetrievepasswordViewController.m
//  Slok
//
//  Created by 刘昊 on 2017/12/12.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "RetrievepasswordViewController.h"
#import "LHPushController.h"
#import "LHNet.h"
@interface RetrievepasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *layoutname;
@property (weak, nonatomic) IBOutlet UITextField *emailfield;
@property (weak, nonatomic) IBOutlet UIButton *getcodebt;
@property (weak, nonatomic) IBOutlet UITextField *codefield;
@property (weak, nonatomic) IBOutlet UITextField *passwordfield;
@property (weak, nonatomic) IBOutlet UITextField *conpassword;
@property (weak, nonatomic) IBOutlet UIButton *subimtbt;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSInteger timeCount;
@property (weak, nonatomic) MBProgressHUD *hud;
@end

@implementation RetrievepasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.layoutname.text = (NSString *)[LHToolManager keyPath:LHRetrievepassword withTarget:self];
    self.emailfield.placeholder = (NSString *)[LHToolManager keyPath:LHEnterEmail withTarget:self];
    [self.emailfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.codefield.placeholder = (NSString *)[LHToolManager keyPath:LHAuthCode withTarget:self];
    [self.codefield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.passwordfield.placeholder = (NSString *)[LHToolManager keyPath:LHPassword withTarget:self];
    [self.passwordfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.conpassword.placeholder = (NSString *)[LHToolManager keyPath:LHLoginConpassword withTarget:self];
    [self.conpassword setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    //设置边框颜色
//    self.subimtbt.layer.borderColor = [[UIColor whiteColor] CGColor];
//    //设置边框宽度
//    self.subimtbt.layer.borderWidth = 1.0f;
//    //    //给按钮设置角的弧度
//    self.subimtbt.layer.cornerRadius = 25.0f;
    [self.subimtbt setTitle:(NSString *)[LHToolManager keyPath:LHSeetingPassSub withTarget:self] forState:UIControlStateNormal];
    
    [self.getcodebt setTitle:(NSString *)[LHToolManager keyPath:LHGetauthcode withTarget:self] forState:UIControlStateNormal];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
- (IBAction)Returnevent:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)GetCodeevent:(id)sender {
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            [self gainCodeInViewController:sender];
            
        }else{
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
        
        
    }];
}
-(void)gainCodeInViewController:(id)sender
{
    if(![XWRegularExpression detectionIsEmailQualified:self.emailfield.text])
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        
        return;
    }
    
    [self.view endEditing:YES];
    
    
    
    self.getcodebt.enabled = NO;
    
    self.getcodebt.userInteractionEnabled = NO;
    
        
    [self gainCodeNumberToNet];
    
}
-(void)gainCodeNumberToNet
{
    LHShowHUB(hud);
    self.emailfield.text = [LHToolManager removeSpaceAndNewline:self.emailfield.text];
    [LHNetworkManager PostCodeByEmail:self.emailfield.text handle:^(id result, NSError *error) {
        LHHideHUB(hud);
        IF_RESPOSE_SUCCESS(result, error)
        {
       
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHSendSuccessfully withTarget:self]);
            self.timeCount = 60;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(codeTime:) userInfo:nil repeats:YES];
            NSString *title = [NSString stringWithFormat:@"%ldS",(long)self.timeCount];
            [self.getcodebt setTitle:title  forState:UIControlStateNormal];
        }else{
            self.timeCount = 0;
            self.getcodebt.enabled = YES;
            
            self.getcodebt.userInteractionEnabled = YES;
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHCaptchaFailure withTarget:self]);
        }
    }];
}
-(void)codeTime:(NSTimer *)timer
{
    --self.timeCount;
    
    NSString *title = self.timeCount > 0 ? [NSString stringWithFormat:@"%ldS",(long)self.timeCount]: (NSString *)[LHToolManager keyPath:LHAuthCode withTarget:self];
    
    [self.getcodebt setTitle:title forState:UIControlStateNormal];
    
    if(self.timeCount <= 0 && [self.timer isValid])
    {
        [self.timer invalidate];
        
        self.getcodebt.enabled = YES;
        
        self.getcodebt.userInteractionEnabled = YES;
        
        self.timeCount = 60;
        [self.getcodebt setTitle:(NSString *)[LHToolManager keyPath:LHGetauthcode withTarget:self] forState:UIControlStateNormal];
    }
}
- (IBAction)Submitevent:(id)sender {
    
    [self.view endEditing:YES];
    
    self.emailfield.text = [LHToolManager removeSpaceAndNewline:self.emailfield.text];
    self.codefield.text = [LHToolManager removeSpaceAndNewline:self.codefield.text];
    self.passwordfield.text = [LHToolManager removeSpaceAndNewline:self.passwordfield.text];
    self.conpassword.text = [LHToolManager removeSpaceAndNewline:self.conpassword.text];
    if(![XWRegularExpression detectionIsEmailQualified:self.emailfield.text])
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        
        return;
    }
    if(self.codefield.text.length<4)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHCodeError withTarget:self]);
        return;
    }
    if(!self.passwordfield.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterPassword withTarget:self]);
        return;
    }
    if (self.passwordfield.text!=self.conpassword.text) {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHLoginInconsistentpassword withTarget:self]);
        return;
    }
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postGetbackpassword:self.emailfield.text dcode:[self.codefield.text md5] password:[self.passwordfield.text md5] handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                    LHUser *user = [[LHUser alloc] init];
                    user.userPass = [self.passwordfield.text md5];
                    user.userId = result[LHUserId];
                    user.userIsLogin = @"1";
                    user.userType = self.emailfield.text;
                    user.userEmail = self.emailfield.text;
                    [self saveUseToFmdb:user];
                   
                    [LHToolManager.rootViewController reloadDataInViewController];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }else{
                    NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHLoginFailure withTarget:self]];
                    
                    LHProgressHUD(message);
                }
            }];
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}



-(void)saveUseToFmdb:(LHUser *)user
{
    if([LHDataManager LH_ExistenceFmdb:LHLockFmdb] && [LHDataManager LH_ExistenceFmdb:LHUserFmdb] && ![user.userId isEqualToString:[LHToolManager getUserId]])
    {
        NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
        
        for (LHLock *key in locks) {
            
            if(!([key.lockVipUse isEqualToString:@"0"] && [key.lockUseTimes isEqualToString:@"0"]))
            {
                key.lockVipUse  = @"0";
                
                key.lockUseTimes = @"0";
                
                [LHDataManager LH_UpdataFmdbId:key withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(key, lockId) value:key.lockId];
            }
        }
    }
    
    [LHDataManager LH_CreatFmdb:[LHUser class] withFmdbKey:LHUserFmdb];
    
    [LHDataManager LH_DeletFmdbKey:LHUserFmdb];
    
    [LHDataManager LH_InserFmdb:user withFmdbKey:LHUserFmdb];
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
   // [self.conpassword resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
