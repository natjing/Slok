//
//  LHBleAddLockViewController.m
//  Slok
//
//  Created by LiuHao on 2017/7/29.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHBleAddLockViewController.h"
#import "TJBluetoothManager.h"
#import "AddlockTableViewCell.h"
#define LHPeripheralKey @"peripheralKey"
@interface LHBleAddLockViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *buleNameLable;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *motherView;
@property (weak, nonatomic) IBOutlet UIView *showlocks;
@property (weak, nonatomic) IBOutlet UITableView *sacnlocktable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableheight;
@property (weak, nonatomic) IBOutlet UILabel *blenamelable;

@property (strong,nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic,strong) NSString *lockIdKey;
@property (nonatomic,strong) NSString *lockMacAdress;
@property (weak, nonatomic) MBProgressHUD *hud;

@property(nonatomic,strong)NSMutableArray *buleTooths;

@end

@implementation LHBleAddLockViewController{
    TJBluetoothManager *mTJBluetoothManager;
    NSUInteger *Sorting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    Sorting=-1;
    // Do any additional setup after loading the view from its nib.
    [self settingViewInViewController];
    mTJBluetoothManager=[TJBluetoothManager shareTJBluetoothManager];
    [mTJBluetoothManager BluetoothDisconnect];
    [mTJBluetoothManager SetViewController:2];
   
    if([mTJBluetoothManager getcentralManager].state == CBCentralManagerStatePoweredOff)
    {
        [self openBlueToothToSetting];
    }else{
        [mTJBluetoothManager scanPeripehrals];
    }
    [mTJBluetoothManager setBluetoothScanReturnedDataBlock:^(NSUInteger *selectIndex, NSMutableDictionary *peripheralDic) {
        for (NSMutableDictionary *bleDic in self.buleTooths) {
            if(bleDic[kCBAdvDataLocalName]==
               peripheralDic[kCBAdvDataLocalName]){
                return;
            }
        }
        [self.buleTooths addObject:peripheralDic];
        
      //  [self showBlueToothList:self.showlocks];
        _tableheight.constant=self.buleTooths.count*62.0f;
        [self.sacnlocktable reloadData];
        
    }];
    
    [mTJBluetoothManager setReturnBluetoothStatusBlock:^(NSUInteger *status,NSString *mac) {
        if(status==0){
            //未连接
        }else if(status==1){
            //已连接,获取ID
            [mTJBluetoothManager BluetoothSendData:[LHBLEDataManager gainLockIdKey:@"0000000000000000"]];
            
        }else if(status==2){
            //通讯成功
        }
    }];
    [mTJBluetoothManager setBluetoothReturnsDataBlock:^(NSUInteger *status, NSData *ReturnsData,NSString *mac) {
        if(status==-2){
            BOOL isTure = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:@"0810151308107781"];
            
            if(isTure)
            {
                self.lockIdKey = LHBLEDataManager.lockId;
                
                if(self.hud.hidden == NO)
                {
                    LHHideHUB(self.hud);
                }
            }
            
        }
    }];
}
 
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"controllerreconnectBluetooth"object:nil];
}
-(void)settingViewInViewController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification  object:nil];
    
    LHCornerRadius(self.addButton, 6.0);
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHNavTitle withTarget:self];
    
    self.nameTextField.placeholder = (NSString *)[LHToolManager keyPath:LHInput withTarget:self];
    
    self.nameTextField.delegate = self;
    self.buleNameLable.text=
    (NSString *)[LHToolManager keyPath:LHSelectBluetooth withTarget:self];
    
    [self.addButton setTitle:(NSString *)[LHToolManager keyPath:LHAdd withTarget:self] forState:UIControlStateNormal];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    
 
    
    self.sacnlocktable.dataSource = self;
    
    self.sacnlocktable.delegate = self;
    
    [self.sacnlocktable registerNib:[UINib nibWithNibName:NSStringFromClass([AddlockTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
}
//F6:E6:88:E9:F3:C1
-(void)addlockInViewController
{
    self.nameTextField.text = [LHToolManager removeSpaceAndNewline:self.nameTextField.text];
    
   
    if(self.nameTextField.text.length == 0)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoLockName withTarget:self]);
        
        return;
    }
    
    if([self.buleNameLable.text isEqualToString:(NSString *)[LHToolManager keyPath:LHSelectBluetooth withTarget:self]])
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHSelectBluetooth withTarget:self]);
        
        return;
    }
    
//    if(self.lockIdKey.length == 0)
//    {
//        LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoEquipmentCode withTarget:self]);
//        
//        return;
//    }
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postAddlock:self.lockIdKey lockMac:self.buleNameLable.text lockName:self.nameTextField.text handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                    [LHToolManager.rootViewController reloadDataInViewController];
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
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

#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)addLock:(id)sender {
    [self.view endEditing:YES];
    
    [self addlockInViewController];
}
- (IBAction)doneButton:(id)sender {
}
-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.nameTextField resignFirstResponder];
}

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
-(void)willEnterForegroundNotification:(NSNotificationCenter *)notice
{
    if([mTJBluetoothManager getcentralManager].state == CBCentralManagerStatePoweredOff)
    {
        [self openBlueToothToSetting];
    }else{
        [mTJBluetoothManager scanPeripehrals];
    }
}

#pragma mark - Private
-(CGFloat)checkDistanceView:(UIView *)fieldView
{
    UIView *motherView = fieldView;
    
    CGFloat sum = 0;
    
    while (motherView != self.view && motherView != self.nameTextField) {
        
        sum = sum + (CGRectGetMaxY(motherView.frame) - motherView.superview.frame.size.height);
        
        motherView = motherView.superview;
        
    }
    return sum;
}

//打开蓝牙
-(void)openBlueToothToSetting
{
    UIAlertController *alet = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHPrompt withTarget:self] message:(NSString *)[LHToolManager keyPath:LHTurnBluetooth withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alet addAction:yesAction];
    [self presentViewController:alet animated:YES completion:nil];
}

-(NSMutableArray *)buleTooths
{
    if(_buleTooths == nil)
    {
        _buleTooths = [NSMutableArray array];
    }
    
    return _buleTooths;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.buleTooths.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.0f;
}

#pragma mark - UITableViewDelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     NSDictionary *blueNameDic = self.buleTooths[indexPath.row];
  
     AddlockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
     // 无色 cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
     cell.blelockname.text =blueNameDic[kCBAdvDataLocalName];
 cell.blelockmac.text=blueNameDic[kCBAdvDataManufacturerData];
     cell.selectionStyle = UITableViewCellSelectionStyleGray;
     if(Sorting==indexPath.row){
        cell.celllayout.backgroundColor = LHRGBColor(176, 88, 98);
     }else{
        cell.celllayout.backgroundColor = LHRGBColor(255, 255, 255);
     }
     return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Sorting=indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *blueNameDic =self.buleTooths[indexPath.row];
    //字条串是否包含有某字符串
    if ([self.nameTextField.text rangeOfString:@"SLok"].location == NSNotFound&&![self.nameTextField.text isEqualToString:@""]) {
    //NSLog(@"string 不存在 martin");
    } else {
    self.nameTextField.text=blueNameDic[kCBAdvDataLocalName];

    }self.buleNameLable.text=blueNameDic[kCBAdvDataManufacturerData];
    self.blenamelable.text=[[NSString alloc]initWithFormat:@"%@%@%@",@"(",blueNameDic[kCBAdvDataLocalName],@")"];
    self.lockIdKey=@"1008611";
     [self.sacnlocktable reloadData];
    //[mTJBluetoothManager ConnectBluetooth:blueNameDic[LHPeripheralKey]];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    NSString *updatedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (updatedText.length > 20) // 4 was chosen for SSN verification
    {
        if (string.length > 1)
        {
            // BasicAlert(@"", @"This field accepts a maximum of 4 characters.");
        }
        
        return NO;
    }
    return YES;
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
