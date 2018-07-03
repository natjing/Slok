//
//  LHEmailLoginViewController.m
//  Slok
//
//  Created by LiuHao on 2017/6/6.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHEmailLoginViewController.h"
#import "LHPushController.h"
#import "LHTGetCodeViewController.h"
@interface LHEmailLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UITextField *firstname;
@property (weak, nonatomic) IBOutlet UITextField *emailfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordfield;
@property (weak, nonatomic) IBOutlet UITextField *conpasswordfield;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *motherView;

@property (weak, nonatomic) IBOutlet UITextField *accountname;
@property (weak, nonatomic) IBOutlet UITextField *Phonenum;

@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSInteger timeCount;
@end

@implementation LHEmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingSubviewInViewController];
    //设置边框颜色
//    self.loginButton.layer.borderColor = [[UIColor whiteColor] CGColor];
//    //设置边框宽度
//    self.loginButton.layer.borderWidth = 1.0f;
//    //    //给按钮设置角的弧度
//    self.loginButton.layer.cornerRadius = 25.0f;
    
    
    //self.loginButton.layer.masksToBounds = YES;
    
    
}
-(void)settingSubviewInViewController
{
    self.timeCount = 60;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    
    self.accountname.delegate = self;
    self.Phonenum.delegate = self;
    self.emailfield.delegate = self;
    self.passwordfield.delegate = self;
    self.conpasswordfield.delegate = self;
    
    self.accountname.placeholder = (NSString *)[LHToolManager keyPath:LHLoginFirstname withTarget:self];
    self.Phonenum.placeholder = (NSString *)[LHToolManager keyPath:LHLoginLastname withTarget:self];
    self.emailfield.placeholder = (NSString *)[LHToolManager keyPath:LHEmail withTarget:self];
    self.passwordfield.placeholder = (NSString *)[LHToolManager keyPath:LHPassword withTarget:self];
    self.conpasswordfield.placeholder = (NSString *)[LHToolManager keyPath:LHLoginConpassword withTarget:self];
    
    [self.accountname setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.Phonenum setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.emailfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.conpasswordfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    self.navTitle.text = (NSString *)[LHToolManager keyPath:LHLoginRegistered withTarget:self];
    
    
    [self.loginButton setTitle:(NSString *)[LHToolManager keyPath:LHSeetingPassSub withTarget:self] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)loginBtn:(id)sender {
    [self.view endEditing:YES];
    self.accountname.text = [LHToolManager removeSpaceAndNewline:self.accountname.text];
    self.Phonenum.text = [LHToolManager removeSpaceAndNewline:self.Phonenum.text];
    self.emailfield.text = [LHToolManager removeSpaceAndNewline:self.emailfield.text];
    
    self.passwordfield.text = [LHToolManager removeSpaceAndNewline:self.passwordfield.text];
    self.conpasswordfield.text = [LHToolManager removeSpaceAndNewline:self.conpasswordfield.text];
    if(![XWRegularExpression detectionIsEmailQualified:self.emailfield.text])
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        
        return;
    }
    
    if(!self.passwordfield.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterPassword withTarget:self]);
        return;
    }
    if (![self.passwordfield.text isEqualToString:self.conpasswordfield.text]) {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHLoginInconsistentpassword withTarget:self]);
        return;
    }
    if(!self.accountname.text.length)
    {
        return;
    }
    
//    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
//        
//        if(status)
//        {
//            LHTGetCodeViewController *viewController = [[LHTGetCodeViewController alloc] init];
//            viewController.emailstr=self.emailfield.text;
//            viewController.passeordstr=self.passwordfield.text;
//            [self.navigationController pushViewController:viewController animated:YES];
//        }else{
//            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
//        }
//    }];
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            
            LHShowHUB(hud);
            [LHNetworkManager postAccountRegistered:self.emailfield.text user_name:self.accountname.text phone:self.Phonenum.text password:[self.passwordfield.text md5] handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                    LHUser *user = [[LHUser alloc] init];
                    user.userPass = [self.passwordfield.text md5];
                    user.userId = result[LHUserId];
                    user.userIsLogin = @"1";
                    user.userType = self.accountname.text;
                    user.userAccount = self.accountname.text;
                    user.userPhone = self.Phonenum.text;
                    user.userEmail = self.emailfield.text;
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
- (IBAction)endOnExit:(id)sender {
}
-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
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
#pragma mark - 事件/响应
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
#pragma mark - private
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

#pragma mark - 系统状态栏
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
