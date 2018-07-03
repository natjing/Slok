//
//  SubmitemailViewController.m
//  Slok
//
//  Created by 刘昊 on 2017/12/12.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "SubmitemailViewController.h"
#import "LHNet.h"
#import "ViewController.h"
#import "LHLoginViewController.h"
@interface SubmitemailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *layoutname;
@property (weak, nonatomic) IBOutlet UITextField *emailfield;
@property (weak, nonatomic) IBOutlet UIButton *submitbt;
@property (weak, nonatomic) IBOutlet UIView *loginout;

@end

@implementation SubmitemailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.layoutname.text = (NSString *)[LHToolManager keyPath:LHSubmitEmail withTarget:self];
    self.emailfield.placeholder = (NSString *)[LHToolManager keyPath:LHEnterEmail withTarget:self];
 
    [self.emailfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
   
    //设置边框颜色
//    self.submitbt.layer.borderColor = [[UIColor whiteColor] CGColor];
//    //设置边框宽度
//    self.submitbt.layer.borderWidth = 1.0f;
//    //    //给按钮设置角的弧度
//    self.submitbt.layer.cornerRadius = 25.0f;
    [self.submitbt setTitle:(NSString *)[LHToolManager keyPath:LHBindEmail withTarget:self] forState:UIControlStateNormal];
    UITapGestureRecognizer *logoutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isBtnLogout:)];
    
    [self.loginout addGestureRecognizer:logoutTap];
}
//退出提示框
-(void)isBtnLogout:(UITapGestureRecognizer *)tap
{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHLogout withTarget:self] message:(NSString *)[LHToolManager keyPath:LHExitaccount withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    
    __weak typeof(alert) weakAlert = alert;
    // 添加确认按钮
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHConfirm withTarget:self] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [LHToolManager logout];
        ViewController *viewController=nil;
        
        for (UIViewController *tempVc in self.navigationController.viewControllers) {
            
            if ([tempVc isKindOfClass:[ViewController class]]) {
                
                viewController=tempVc;
                
            }
        }
       [self.navigationController popToViewController:viewController animated:YES];
    }]];
    // 添加取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHShareCancel withTarget:self] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)postsubmitemail:(id)sender {
    
    if(![XWRegularExpression detectionIsEmailQualified:self.emailfield.text])
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        
        return;
    }

  
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager PostSubmitEmail:self.emailfield.text handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                IF_RESPOSE_SUCCESS(result, error)
                {
                    //取出数据
                    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
                    LHUser *user = [fmdbData lastObject];
                    //修改邮箱
                    user.userEmail = self.emailfield.text;
                    //重新保存
                    [self saveUseToFmdb:user];
                    ViewController *viewController=nil;
                    
                    for (UIViewController *tempVc in self.navigationController.viewControllers) {
                        
                        if ([tempVc isKindOfClass:[ViewController class]]) {
                            
                            viewController=tempVc;
                            
                        }
                    }
                    [LHToolManager.rootViewController reloadDataInViewController];
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
