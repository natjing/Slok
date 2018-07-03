//
//  LHSeettingPasswordViewController.m
//  Slok
//
//  Created by 刘昊 on 2017/12/2.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHSeettingPasswordViewController.h"
#import "LHNet.h"
#import "LHSettingViewController.h"
@interface LHSeettingPasswordViewController ()
@property (weak, nonatomic) IBOutlet UILabel *namelabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordfield;
@property (weak, nonatomic) IBOutlet UITextField *conpasswordfield;
@property (weak, nonatomic) IBOutlet UIButton *Submitbuton;

@end

@implementation LHSeettingPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.namelabel.text = (NSString *)[LHToolManager keyPath:LHSeetingPassName withTarget:self];
   
     self.passwordfield.placeholder = (NSString *)[LHToolManager keyPath:LHPassword withTarget:self];
     self.conpasswordfield.placeholder = (NSString *)[LHToolManager keyPath:LHLoginConpassword withTarget:self];
 
    
    [self.Submitbuton setTitle:(NSString *)[LHToolManager keyPath:LHSeetingPassSub withTarget:self] forState:UIControlStateNormal];
    //[self getcode];
}
- (IBAction)Returnevent:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)Submitincident:(id)sender {
    [self.view endEditing:YES];
    self.passwordfield.text = [LHToolManager removeSpaceAndNewline:self.passwordfield.text];
    self.conpasswordfield.text = [LHToolManager removeSpaceAndNewline:self.conpasswordfield.text];
    
    
    if(!self.passwordfield.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterPassword withTarget:self]);
        return;
    }
    NSString *fuiveo=self.passwordfield.text;
     NSString *fuiveoq=self.conpasswordfield.text;
    if (self.passwordfield.text!=self.conpasswordfield.text) {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHLoginInconsistentpassword withTarget:self]);
        return;
    }
  
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postChangePassword:@"123" Password:[self.passwordfield.text md5] handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                    //取出数据
                    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
                    LHUser *user = [fmdbData lastObject];
                    //修改密码
                    user.userPass = [self.passwordfield.text md5];
                    //重新保存
                    [self saveUseToFmdb:user];
                    LHSettingViewController *viewController=nil;
                    
                    for (UIViewController *tempVc in self.navigationController.viewControllers) {
                        
                        if ([tempVc isKindOfClass:[LHSettingViewController class]]) {
                            
                            viewController=tempVc;
                            viewController.ifshow= YES;
                        }
                    }
                    [self.navigationController popToViewController:viewController animated:YES];
                    
                }else{
                    NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHAddError withTarget:self]];
                    
                    LHProgressHUD(message);
                }
            }];
        }else{
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}

-(void)getcode{
    
    [LHNetworkManager PostCodeByEmail:[LHToolManager getUserType] handle:^(id result, NSError *error) {
       
        IF_RESPOSE_SUCCESS(result, error)
        {
             
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHCaptchaFailure withTarget:self]);
        }
    }];
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
