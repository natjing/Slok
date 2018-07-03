//
//  LHLoginViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/20.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHLoginViewController.h"
#import "AppDelegate.h"
#import "LHPushController.h"
#import "LHEmailLoginViewController.h"
#import "LHTGetCodeViewController.h"
#import "SubmitemailViewController.h"
#import "RetrievepasswordViewController.h"
#define LHLiClientId @"86x0yn21dkbfck"
#define LHLiClientSecret @"6FdCoK3HYcF6zaaj"
#define LHLiRedirectUrl @"http://slok.spdkey.com/Api/public/css/linkedin.php"
@interface LHLoginViewController ()

@property (weak, nonatomic) IBOutlet GIDSignInButton *signbutton;


@property (weak, nonatomic) IBOutlet UIButton *loginbt;
@property (weak, nonatomic) IBOutlet UIButton *registeredbt;

@property (weak, nonatomic) IBOutlet UIView *layoutview;

@property (weak, nonatomic) IBOutlet UITextField *accountfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordfield;
@property (weak, nonatomic) IBOutlet UILabel *Continuewith;

@property (weak, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) BOOL isIntoLog;
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UILabel *Getbackpass;
@end

@implementation LHLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingInViewController];
    
    [self initSubViewInViewController];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    LHDataManager.isWechatShare = NO;
}
#pragma mark - 视图
-(void)initSubViewInViewController
{
    [self initLableInViewController];
}
-(void)initLableInViewController
{
    
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    self.tap.cancelsTouchesInView = NO;
  
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:self.tap];
    self.accountfield.placeholder = (NSString *)[LHToolManager keyPath:LHEmail withTarget:self];
    self.passwordfield.placeholder = (NSString *)[LHToolManager keyPath:LHPassword withTarget:self];
    [self.accountfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.passwordfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.loginbt setTitle:(NSString *)[LHToolManager keyPath:LHLogin withTarget:self] forState:UIControlStateNormal];
    
    [self.registeredbt setTitle:(NSString *)[LHToolManager keyPath:LHLoginRegistered withTarget:self] forState:UIControlStateNormal];
    
    self.Continuewith.text=(NSString *)[LHToolManager keyPath:LHLoginContinuewith withTarget:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.Getbackpass.text=(NSString *)[LHToolManager keyPath:LHRetrievepassword withTarget:self];
    self.Getbackpass.userInteractionEnabled=YES;
    UITapGestureRecognizer *getbackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isBtngetback)];
    
    [self.Getbackpass addGestureRecognizer:getbackTap];
}
-(void) isBtngetback{
   RetrievepasswordViewController *viewController = [[RetrievepasswordViewController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void)settingInViewController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatNotice:) name:LHWechatNotice object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}
#pragma mark - 点击事件
//登录按钮点击事件
- (IBAction)loginbutton:(id)sender {
    [self.view endEditing:YES];
    
    self.accountfield.text = [LHToolManager removeSpaceAndNewline:self.accountfield.text];
    
    self.passwordfield.text = [LHToolManager removeSpaceAndNewline:self.passwordfield.text];
    
    if(![XWRegularExpression detectionIsEmailQualified:self.accountfield.text])
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        
        return;
    }
    
    if(!self.passwordfield.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterPassword withTarget:self]);
        
        return;
    }
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            [self loginByEmailToNet];
            
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}

-(void)loginByEmailToNet
{
    LHShowHUB(hud);
    [LHNetworkManager postLoginByEmail:self.accountfield.text passWord:[self.passwordfield.text md5] handle:^(id result, NSError *error) {
        LHHideHUB(hud);
        If_Respose_Success(result, error)
        {
            LHUser *user = [[LHUser alloc] init];
            user.userPass = [self.passwordfield.text md5];
            user.userId = result[LHUserId];
            user.userIsLogin = @"1";
            user.userType = self.accountfield.text;
            user.userEmail= self.accountfield.text;
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

//进入注册页面
- (IBAction)registeredbutton:(id)sender {
    
    LHEmailLoginViewController *viewController = [[LHEmailLoginViewController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    
}


//微信登录
- (IBAction)loginWithWechat:(id)sender {
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            LHShowHUB(hud);
            self.hud = hud;
            [self getAuthWithUserInfoFromWechat];
            
        }else{
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
- (void)getAuthWithUserInfoFromWechat
{
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:UMSocialPlatformType_WechatSession currentViewController:nil completion:^(id result, NSError *error) {
        if (error) {
            LHHideHUB(self.hud);
            LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
            
        } else {
            
            UMSocialUserInfoResponse *resp = result;
            
            NSString *pass = resp.openid;
            
            [self loginUserId:[pass md5] withType:@"3"];
        }
    }];
}

//Twitter登录
- (IBAction)loginWithSwitter:(id)sender {
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHPrompt withTarget:self] message:(NSString *)[LHToolManager keyPath:LHSureTwitter withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self loginByTwitter];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            
            [self presentViewController:alert animated:YES completion:nil ];
            
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
-(void)loginByTwitter
{
    LHShowHUB(hud);
    self.hud = hud;
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            [self loginUserId:[[session userID] md5] withType:@"4"];
        } else {
            LHHideHUB(hud);
            LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
        }
    }];
}


//Facebook登录
- (IBAction)loginWithFacebook:(id)sender {
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            LHShowHUB(hud);
            self.hud = hud;
            [login logInWithReadPermissions: @[@"public_profile"]fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (error) {
                    LHHideHUB(hud);
                    LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
                } else if (result.isCancelled) {
                    LHHideHUB(hud);
                    LHProgressHUD((NSString *)[LHToolManager keyPath:LHCancel   withTarget:self]);
                }else{
                    [self faceBookAuthorizationSuccessByToken:result];
                }
            }];
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
    
    
}

//原linkedin登录，现为Google登录
- (IBAction)loginWithLinkedin:(id)sender {
    //google firebase 登录
    if ([FIRApp defaultApp] == nil) {
        [FIRApp configure];
    }
   
    [GIDSignIn sharedInstance].clientID=[FIRApp defaultApp].options.clientID;
    [GIDSignIn sharedInstance].delegate=self;
    [GIDSignIn sharedInstance].uiDelegate=self;
    [[GIDSignIn sharedInstance] signIn];
    
}

//google登录
- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    LHShowHUB(hud);
    self.hud = hud;
    if (error == nil) {
        GIDAuthentication *authentication = user.authentication;
        [self loginUserId:[authentication.clientID md5] withType:@"8"];
    } else {
        LHHideHUB(hud);
        LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    
}
//登录请求
-(void)loginUserId:(NSString *)userId withType:(NSString *)type
{
    self.isIntoLog = YES;
    [LHNetworkManager postLogin:type userIdentity:userId handle:^(id result, NSError *error) {
        LHHideHUB(self.hud);
        If_Respose_Success(result, error)
        {
            LHUser *user = [[LHUser alloc] init];
            user.userPass = userId;
            user.userId = result[LHUserId];
            user.userIsLogin = @"1";
            user.userType = [self codeChangeString:type];
            user.userEmail = result[LHEmail];
            [self saveUseToFmdb:user];
            LHPushController *pushController = [[LHPushController alloc] init];
            [pushController sendPushId:result[LHUserId]];
            
            if(user.userEmail.length<2){
                SubmitemailViewController *viewController = [[SubmitemailViewController alloc] init];
                
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                [LHToolManager.rootViewController reloadDataInViewController];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            
        }else{
            NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHFailureAuthorize withTarget:self]];
            
            LHProgressHUD(message);
        }
    }];
}
-(NSString *)codeChangeString:(NSString *)type
{
    NSString *loginStr = nil;
    
    switch ([type intValue]) {
        case 1:
            loginStr = @"Facebook";
            break;
        case 2:
            loginStr = @"Linkedin";
            break;
        case 3:
            loginStr = @"Wechat";
            break;
        case 4:
            loginStr = @"Twitter";
            break;
        case 5:
            loginStr = @"Email";
            break;
        case 6:
            loginStr = @"Phone";
            break;
        case 8:
            loginStr = @"Google";
            break;
        default:
            loginStr = @"";
            break;
    }
    return loginStr;
}
//保存登录返回的数据
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
#pragma mark - NSNotificationCenter
-(void)weChatNotice:(NSNotification *)notice
{
    BaseResp *resp = notice.object;
    
    if([resp isKindOfClass:[SendAuthResp class]]) {
        
        SendAuthResp *authResp = (SendAuthResp *)resp;
        switch (resp.errCode) {
            case 0:
            {
                [self wechatLoginSuccessByCode:authResp.code];
            }
                break;
            case -2:
            {
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHCancel   withTarget:self]);
            }
                break;
            default:
            {
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHFailureAuthorize withTarget:self]);
            }
                break;
        }
        
    }
}
-(void)willEnterForeground:(NSNotification *)notice
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(!self.isIntoLog && self.hud)
        {
            LHHideHUB(self.hud);
        }
    });
}
#pragma mark - Private ways
-(void)wechatLoginSuccessByCode:(NSString *)code
{
    LHShowHUB(hub);
    self.hud = hub;
    [LHNetworkManager weChatAccessToken:code handle:^(id result, NSError *error) {
        IF_WECHAT_SUCCESS(result, error)
        {
            NSDictionary *authorizationDic = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
            
            [self weChatAuthorizationSuccessByToken:authorizationDic[LHAccessToken] withOpenid:authorizationDic[LHOpenid]];
        }else{
            LHHideHUB(hub);
            LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
        }
    }];
}
-(void)weChatAuthorizationSuccessByToken:(NSString *)accessToken withOpenid:(NSString *)openId
{
    [LHNetworkManager weChatUserInfo:accessToken openId:openId handle:^(id result, NSError *error) {
        
        IF_WECHAT_SUCCESS(result, error)
        {
            NSDictionary *useInfoDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
            
            NSString *pass = useInfoDic[LHOpenid];
            
            [self loginUserId:[pass md5] withType:@"3"];
            
        }else{
            LHHideHUB(self.hud);
            LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
        }
    }];
}
-(void)faceBookAuthorizationSuccessByToken:(FBSDKLoginManagerLoginResult *)result
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:result.token.userID parameters:@{@"fields": @"id,name,email"}HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result,NSError *error) {
        IF_FACEBOOK_SUCCESS(result, error)
        {
            [self loginUserId:[result[LHId] md5] withType:@"1"];
            
        }else{
            LHHideHUB(self.hud);
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
        }
    }];
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
    
    CGFloat markH =[self checkDistanceView:self.passwordfield];
    // 修改transform
    [UIView animateWithDuration:duration animations:^{
        
        CGFloat ty = [UIScreen mainScreen].bounds.size.height - rect.origin.y + markH-100;
        
        if(ty < 0)
        {
            ty = 0;
        }
        
        self.layoutview.transform = CGAffineTransformMakeTranslation(0, - ty);
    }];
    
}
#pragma mark - Private
-(CGFloat)checkDistanceView:(UIView *)fieldView
{
    UIView *motherView = fieldView;
    
    CGFloat sum = 0;
    
    while (motherView != self.view && motherView != self.layoutview) {
        
        sum = sum + (CGRectGetMaxY(motherView.frame) - motherView.superview.frame.size.height);
        
        motherView = motherView.superview;
        
    }
    return sum;
}
-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 系统状态栏
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
