//
//  LHGetCodeViewController.m
//  Slok
//
//  Created by LiuHao on 2017/6/8.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHTGetCodeViewController.h"
#import "LHPushController.h"
@interface LHTGetCodeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *motherView;
@property (weak, nonatomic) IBOutlet UIView *CircleView;
@property (weak, nonatomic) IBOutlet UILabel *showtime;
@property (weak, nonatomic) IBOutlet UIView *passwordview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *voiceWithConstant;
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSInteger timeCount;
@end

@implementation LHTGetCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingSubviewInViewController];
}
-(void)settingSubviewInViewController
{
    
    self.timeCount = 120;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    
    self.passWordTextField.delegate = self;
    //验证码输入框的提示
    self.passWordTextField.placeholder = (NSString *)[LHToolManager keyPath:LHAuthCode withTarget:self];
    [self.passWordTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    //提交按钮的显示
    [self.loginButton setTitle:(NSString *)[LHToolManager keyPath:LHLoginRegistered withTarget:self] forState:UIControlStateNormal];
    
    //设置倒计时边框
    self.CircleView.layer.borderColor = [[UIColor whiteColor] CGColor];
    //设置边框宽度
    self.CircleView.layer.borderWidth = 1.0f;
    //给按钮设置角的弧度
    self.CircleView.layer.cornerRadius = 60.0f;
    //设置验证码边框
    self.passwordview.layer.borderColor = [[UIColor whiteColor] CGColor];
    //设置边框宽度
    self.passwordview.layer.borderWidth = 1.0f;
    //给按钮设置角的弧度
    self.passwordview.layer.cornerRadius = 25.0f;
    
    //设置提交按钮边框
    self.loginButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    //设置边框宽度
    self.loginButton.layer.borderWidth = 1.0f;
    //给按钮设置角的弧度
    self.loginButton.layer.cornerRadius = 25.0f;
    
    
//    self.voiceWithConstant.constant = [LHToolManager isWhatLanguages] ? 230.0 : 140.0;
    self.navTitle.text = (NSString *)[LHToolManager keyPath:LHAuthCode withTarget:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self gainCodeBtn];
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}
- (void)gainCodeBtn{
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            [self gainCodeNumberToNet];
            
        }else{
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
-(void)gainCodeNumberToNet
{
    LHShowHUB(hud);
    [LHNetworkManager PostCodeByEmail:self.emailstr handle:^(id result, NSError *error) {
        LHHideHUB(hud);
        IF_RESPOSE_SUCCESS(result, error)
        {
            [self gainCodeInViewController];

            LHProgressHUD((NSString *)[LHToolManager keyPath:LHSendSuccessfully withTarget:self]);
        }else{
            self.timeCount = 120;
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHCaptchaFailure withTarget:self]);
        }
    }];
}
-(void)gainCodeInViewController
{
  
    [self.view endEditing:YES];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(codeTime:) userInfo:self repeats:YES];
    
    NSString *title = @"02:00";
    
    [self.showtime setText:title];
}


-(void)codeTime:(NSTimer *)timer
{
    --self.timeCount;
    NSInteger fen=self.timeCount/60;
    NSInteger miao=self.timeCount%60;
    NSString *title=nil;
    if(miao<10){
       title = [NSString stringWithFormat:@"%@%d%@%d",@"0",fen,@":0",miao];
        
    }else{
    title = [NSString stringWithFormat:@"%@%d%@%d",@"0",fen,@":",miao];
    }
    
    if(self.timeCount>0)
    {
        [self.showtime setText:title];
 
    }
    
    if(self.timeCount <= 0 && [self.timer isValid])
    {
        [self.timer invalidate];
        self.timeCount = 120;
        [self.showtime setText:@"00:00"];
    }
}
- (IBAction)loginBtn:(id)sender {
    [self.view endEditing:YES];
    
    self.passWordTextField.text = [LHToolManager removeSpaceAndNewline:self.passWordTextField.text];
    
    if(!self.passWordTextField.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterPassword withTarget:self]);
        
        return;
    }
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            [self EmailRegistered];
            
        }else{
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
-(void)EmailRegistered{
    
    if(self.passWordTextField.text.length<4)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHCodeError withTarget:self]);
        return;
    }
    
 LHShowHUB(hud);
        [LHNetworkManager postEmailRegistered:self.emailstr username:self.namestr dcode:[self.passWordTextField.text md5] password:[self.passeordstr md5] handle:^(id result, NSError *error) {
            LHHideHUB(hud);
            If_Respose_Success(result, error)
            {
                LHUser *user = [[LHUser alloc] init];
                user.userPass = [self.passeordstr md5];
                user.userId = result[LHUserId];
                user.userIsLogin = @"1";
                user.userType = self.emailstr;
                [self saveUseToFmdb:user];
                LHPushController *pushController = [[LHPushController alloc] init];
                [pushController sendPushId:result[LHUserId]];
                [LHToolManager.rootViewController reloadDataInViewController];
                [self.navigationController popToRootViewControllerAnimated:YES];
               
            }else{
                NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHLoginFailure withTarget:self]];
    
                LHProgressHUD(message);
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
- (IBAction)endOnExit:(id)sender {
}
#pragma mark - UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.view.gestureRecognizers containsObject:self.tap])
    {
        [self.view removeGestureRecognizer:self.tap];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(![self.view.gestureRecognizers containsObject:self.tap])
    {
        [self.view addGestureRecognizer:self.tap];
    }
}
#pragma mark - NSNotificationCenter
//view上移
- (void)keyboardWillChangeFrame:(NSNotification *)note {
    
    // 取出键盘最终的frame
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 取出键盘弹出需要花费的时间
    double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat markH =[self checkDistanceView:self.loginButton];
    // 修改transform
    [UIView animateWithDuration:duration animations:^{
        
        CGFloat ty = [UIScreen mainScreen].bounds.size.height - rect.origin.y + markH;
        
        if(ty < 0)
        {
            ty = 0;
        }
        
        self.motherView.transform = CGAffineTransformMakeTranslation(0, - ty);
    }];
    
}


#pragma mark - Private
-(CGFloat)checkDistanceView:(UIView *)fieldView
{
    UIView *motherView = fieldView;
    
    CGFloat sum = 0;
    
    while (motherView != self.view && motherView != self.motherView) {
        
        sum = sum + (CGRectGetMaxY(motherView.frame) - motherView.superview.frame.size.height);
        
        motherView = motherView.superview;
        
    }
    return sum;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
