//
//  LHShareViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/31.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHShareViewController.h"
#import "LHShareNameViewController.h"
#import "LHShareListViewController.h"
#define LHLogImageUrl @"http://slok.spdkey.com/Api/public/images/slok.png"
@interface LHShareViewController ()<UITextFieldDelegate,FBSDKSharingDelegate>
 
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UIView *shareFacebookView;
@property (weak, nonatomic) IBOutlet UIView *shareWeChatView;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *shareFacebookLable;
@property (weak, nonatomic) IBOutlet UILabel *shareWechatLable;
@property (weak, nonatomic) IBOutlet UILabel *shareEmailLable;
@property (weak, nonatomic) IBOutlet UIView *shareEmailView;
@end

@implementation LHShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self settingSubViewInViewController];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    LHDataManager.isWechatShare = YES;
}
-(void)settingSubViewInViewController
{
    LHShadowColor(self.shareWeChatView);
    
    LHShadowColor(self.shareFacebookView);
    
    LHShadowColor(self.shareEmailView);
    
 
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKingboard:)];
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHShareLock withTarget:self];
    
    self.shareFacebookLable.text = (NSString *)[LHToolManager keyPath:LHShareFacebook withTarget:self];
    
    self.shareWechatLable.text = (NSString *)[LHToolManager keyPath:LHShareWechat withTarget:self];
    
    self.shareEmailLable.text = (NSString *)[LHToolManager keyPath:LHShareEmail withTarget:self];
    
 
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatNotice:) name:LHWechatNotice object:nil];
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)backKingboard:(id)sender {
}
-(void)closeKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}
- (IBAction)shareToEmail:(id)sender {
    [self.view endEditing:YES];
   
        [self shareToEmailAction];
}
-(void)shareToEmailAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHEmail withTarget:self] message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHShareCancel withTarget:self] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHConfirm withTarget:self] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *emailTextField = [alert.textFields firstObject];
        
        emailTextField.text = [LHToolManager removeSpaceAndNewline:emailTextField.text];
        
        if([XWRegularExpression detectionIsEmailQualified:emailTextField.text])
        {
            [self emailShareToNet:emailTextField.text];
            
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        }
        
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = (NSString *)[LHToolManager keyPath:LHEnterEmail withTarget:self];
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)emailShareToNet:(NSString *)email
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postShareToEmail:self.currenLock.lockId emailAdress:email shareName:self.sharename handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                   [self ShareSuccess];
                    
                }else{
                    NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHShareError withTarget:self]];
                    
                    LHProgressHUD(message);
                }
            }];
            
        }else{
            
           LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
- (IBAction)shareToFacebook:(id)sender {
    [self.view endEditing:YES];
   
        [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
            if(status)
            {
                LHShowHUB(hud);
                [LHNetworkManager postShareLock:self.sharename lockId:self.currenLock.lockId handle:^(id result, NSError *error) {
                    LHHideHUB(hud);
                    If_Respose_Success(result, error)
                    {
                        NSDictionary *infoDic = result[LHInfo];
                        
                        NSString *url = [NSString stringWithFormat:@"http://www.spdkey.com/down/slok.php?name=%@&code=%@&oder=%ld",self.currenLock.lockName,infoDic[LHCptcha],[LHToolManager isWhatLanguages]];
                        
                        [self wechatShareUrl:url withCode:infoDic[LHCptcha]];
                        
                    }else{
                        NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHShareError withTarget:self]];
                        
                        LHProgressHUD(message);
                    }
                }];
                
            }else{
                
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
            }
        }];
        
    
}
- (IBAction)shareToWeChat:(id)sender {
    
    [self.view endEditing:YES];
    
   
        
        [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
            if(status)
            {
                LHShowHUB(hud);
                [LHNetworkManager postShareLock:self.sharename lockId:self.currenLock.lockId handle:^(id result, NSError *error) {
                    LHHideHUB(hud);
                    If_Respose_Success(result, error)
                    {
                        NSDictionary *infoDic = result[LHInfo];
                        
                        NSString *url = [NSString stringWithFormat:@"http://www.spdkey.com/down/slok.php?name=%@&code=%@&oder=%ld",self.currenLock.lockName,infoDic[LHCptcha],[LHToolManager isWhatLanguages]];
                        
                        [self wechatShareUrl:url withCode:infoDic[LHCptcha]];
                        
                    }else{
                        NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHShareError withTarget:self]];
                        
                        LHProgressHUD(message);
                    }
                }];
                
            }else{
                
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
            }
        }];
   
}

-(void)wechatShareUrl:(NSString *)url withCode:(NSString *)code
{
    if([WXApi isWXAppInstalled])
    {
        NSString *kLinkTitle = (NSString *)[LHToolManager keyPath:LHShareSlok withTarget:self];
        NSString *kLinkDescription = [NSString stringWithFormat:@"%@ %@",(NSString *)[LHToolManager keyPath:LHVerificationCode withTarget:self],code];
        SendMessageToWXReq *req1 = [[SendMessageToWXReq alloc]init];
             // 是否是文档
        req1.bText =  NO;
        req1.scene = WXSceneSession;
             //创建分享内容对象
        WXMediaMessage *urlMessage = [WXMediaMessage message];
        urlMessage.title = kLinkTitle;//分享标题
        urlMessage.description = kLinkDescription;//分享描述
        [urlMessage setThumbImage:[UIImage imageNamed:@"SLOK_LOGO"]];//分享图片,使用SDK的setThumbImage方法可压缩图片大小
             //创建多媒体对象
        WXWebpageObject *webObj = [WXWebpageObject object];
             webObj.webpageUrl = url;//分享链接
             //完成发送对象实例
        urlMessage.mediaObject = webObj;
        req1.message = urlMessage;
             //发送分享信息
        [WXApi sendReq:req1];
        
    }else{
     
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHWechatNoInstall withTarget:self]);
             
    }
}
-(void)facebookShareUrl:(NSString *)url withCode:(NSString *)code
{
    NSString *kLinkTitle = (NSString *)[LHToolManager keyPath:LHShareSlok withTarget:self];
    NSString *kLinkDescription = [NSString stringWithFormat:@"%@ %@",(NSString *)[LHToolManager keyPath:LHVerificationCode withTarget:self],code];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:url];
    
    content.contentTitle = kLinkTitle;
    content.contentDescription = kLinkDescription;
    content.quote = kLinkDescription;
    content.imageURL = [NSURL URLWithString:LHLogImageUrl];
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.shareContent = content;
    dialog.fromViewController = self;
    dialog.delegate = self;
    dialog.mode = FBSDKShareDialogModeNative;
    [dialog show];
}

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(![self.view.gestureRecognizers containsObject:self.tap])
    {
        [self.view addGestureRecognizer:self.tap];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    if([self.view.gestureRecognizers containsObject:self.tap])
    {
        [self.view removeGestureRecognizer:self.tap];
    }
}
#pragma mark - FaceBook Share Delegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSString *postId = results[@"postId"];
    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;
    if (dialog.mode == FBSDKShareDialogModeBrowser && (postId == nil || [postId isEqualToString:@""])) {
        // 如果使用webview分享的，但postId是空的，
        // 这种情况是用户点击了『完成』按钮，并没有真的分享
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHCancel withTarget:self]);
    } else {
        
       [self ShareSuccess];
    }
    
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    FBSDKShareDialog *dialog = (FBSDKShareDialog *)sharer;
    if (error == nil && dialog.mode == FBSDKShareDialogModeNative) {
        // 如果使用原生登录失败，但error为空，那是因为用户没有安装Facebook app
        // 重设dialog的mode，再次弹出对话框
        dialog.mode = FBSDKShareDialogModeBrowser;
        [dialog show];
    } else {
        
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHShareFailure withTarget:self]);
    }
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
    LHProgressHUD(LHCancel);
}
#pragma mark - NSNotification
-(void)weChatNotice:(NSNotification *)notice
{
    BaseResp *resp = notice.object;
    
    //把返回的类型转换成与发送时相对于的返回类型,这里为SendMessageToWXResp
    SendMessageToWXResp *sendResp = (SendMessageToWXResp *)resp;
    
    switch (sendResp.errCode) {
        case 0:
        {
            
            [self ShareSuccess];
            
        }
            break;
        case -2:
        {
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHCancel withTarget:self]);
        }
            break;
        default:
        {
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHShareFailure withTarget:self]);
        }
            break;
    }
}

/*
WXSuccess           = 0,    *< 成功    
WXErrCodeCommon     = -1,   *< 普通错误类型    
WXErrCodeUserCancel = -2,   *< 用户点击取消并返回    
WXErrCodeSentFail   = -3,   *< 发送失败    
WXErrCodeAuthDeny   = -4,   *< 授权失败    
WXErrCodeUnsupport  = -5,   *< 微信不支持    
*/


//分享成功回到分享列表界面
-(void)ShareSuccess{
    LHShareListViewController *viewController=nil;
    
    for (UIViewController *tempVc in self.navigationController.viewControllers) {
        
        if ([tempVc isKindOfClass:[LHShareListViewController class]]) {
            
            viewController=tempVc;
            viewController.ifRefresh= YES;
        }
    }
    [self.navigationController popToViewController:viewController animated:YES];
  
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
