//
//  LHCodeLockViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/27.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHCodeLockViewController.h"

@interface LHCodeLockViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UILabel *scanstring;

@property (weak, nonatomic) IBOutlet UITextField *lockNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *motherView;
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@end

@implementation LHCodeLockViewController
{
    NSString *lock_type;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingsubViewInViewController];
    lock_type= [self.scanNumber substringToIndex:1];
    if(self.scanMac.length==12){
       
        NSMutableString *string = [self.scanMac mutableCopy];
        for (NSInteger i = string.length - 2; i > 0; i -= 2) {
            [string insertString:@":" atIndex:i];
        }
        self.scanMac=string;
    
    }else{
        self.scanMac=@"111111111";
    }
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
}
-(void)settingsubViewInViewController
{
    LHCornerRadius(self.addButton, 6.0);
    self.lockNameTextField.delegate = self;
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingBoard:)];
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHNavTitle withTarget:self];
    self.scanstring.text=self.scanNumber;
    self.lockNameTextField.placeholder = (NSString *)[LHToolManager keyPath:LHLockName withTarget:self];
    
    [self.addButton setTitle:(NSString *)[LHToolManager keyPath:LHAdd withTarget:self] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
#pragma mark - 事件
- (IBAction)didEndOnExit:(id)sender {
}
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)addLock:(id)sender {
    [self.view endEditing:YES];
    
    [self addCodeLockWithNet];
}
-(void)addCodeLockWithNet
{
    self.lockNameTextField.text = [LHToolManager removeSpaceAndNewline:self.lockNameTextField.text];
    if(!self.lockNameTextField.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoLockName withTarget:self]);
        
        return;
    }
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            [LHNetworkManager postScanAddLock:lock_type locknum:self.scanstring.text lockmac:self.scanMac lockname:self.lockNameTextField.text lockbei:@"" handle:^(id result, NSError *error) {
                If_Respose_Success(result, error)
                {
                    [LHToolManager.rootViewController reloadDataInViewController];
                    //遍历控制器
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[ViewController class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                   // [self.navigationController popViewControllerAnimated:YES];
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
-(void)backKingBoard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}
#pragma mark - delegate
#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(![self.view.gestureRecognizers containsObject:self.tap])
    {
        [self.view addGestureRecognizer:self.tap];
    }
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if([self.view.gestureRecognizers containsObject:self.tap])
    {
        [self.view removeGestureRecognizer:self.tap];
    }
}
#pragma mark - NSNotificationCenter
//view上移
- (void)keyboardWillChangeFrame:(NSNotification *)note {
    
    // 取出键盘最终的frame
    CGRect rect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 取出键盘弹出需要花费的时间
    double duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGFloat markH =[self checkDistanceView:self.addButton];
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
