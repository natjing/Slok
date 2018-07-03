//
//  LHShareNameViewController.m
//  Slok
//
//  Created by 刘昊 on 2017/12/1.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHShareNameViewController.h"
#import "LHShareViewController.h"
#import "LHShareListViewController.h"
@interface LHShareNameViewController ()
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UITextField *sharenamefield;

@property (weak, nonatomic) IBOutlet UITextField *emialfield;

@property (weak, nonatomic) IBOutlet UIButton *nextbutton;

@property (weak, nonatomic) IBOutlet UIButton *sharebutton;
@property (weak, nonatomic) IBOutlet UIView *hidedataview;



@end

@implementation LHShareNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.sharenamefield.placeholder = (NSString *)[LHToolManager keyPath:LHEnterNote withTarget:self];
    self.emialfield.placeholder = (NSString *)[LHToolManager keyPath:LHEmail withTarget:self];
 
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHShareLock withTarget:self];
    
    [self.nextbutton setTitle:(NSString *)[LHToolManager keyPath:LHLoginNext withTarget:self] forState:UIControlStateNormal];
    [self.sharebutton setTitle:(NSString *)[LHToolManager keyPath:LHShare withTarget:self] forState:UIControlStateNormal];
    
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextClickevent:(id)sender {
    
    self.sharenamefield.text = [LHToolManager removeSpaceAndNewline:self.sharenamefield.text];
    if(self.sharenamefield.text.length)
    {
    self.hidedataview.hidden=NO;
    }else{
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterNote withTarget:self]);
    }
}

- (IBAction)sharebutton:(id)sender {
    
    self.emialfield.text = [LHToolManager removeSpaceAndNewline:self.emialfield.text];
    
        if([XWRegularExpression detectionIsEmailQualified:self.emialfield.text])
        {
            [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
                if(status)
                {
                    LHShowHUB(hud);
                    [LHNetworkManager postShareToEmail:self.currenLock.lockId emailAdress:self.emialfield.text shareName:self.sharenamefield.text handle:^(id result, NSError *error) {
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
            
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterCorrectMailbox withTarget:self]);
        }
       
//        LHShareViewController *viewController = [[LHShareViewController alloc] init];
//        
//        viewController.currenLock = self.currenLock;
//        
//        viewController.sharename=self.sharenamefield.text;
//        [self.navigationController pushViewController:viewController animated:YES];
        
   
  
}
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
