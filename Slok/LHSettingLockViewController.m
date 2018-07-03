//
//  LHSettingLockViewController.m
//  Slok
//
//  Created by LiuHao on 2017/9/19.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHSettingLockViewController.h"
#import "SYPasswordView.h"
#import "TJBluetoothManager.h"
@interface LHSettingLockViewController ()
@property (weak, nonatomic) IBOutlet UIView *motherView;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UIButton *comfrimButton;
@property (weak, nonatomic) IBOutlet UILabel *adviseLable;
@property (nonatomic, strong) SYPasswordView *pasView;

@property (weak, nonatomic) MBProgressHUD *hud;

@end
@implementation LHSettingLockViewController{
    TJBluetoothManager *mTJBluetoothManager;
    Boolean *ifconnection;
    Boolean *ifgetid;
    Boolean *ifgetidasd;
    NSUInteger *chishu;
    Boolean *Startsetting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    chishu=0;
    Startsetting=NO;
    [self SettingSubViewInViewController];
    [self BluetoothManage];
}
//蓝牙管理
-(void)BluetoothManage{
    ifconnection=NO;
    ifgetid=NO;
    ifgetidasd=NO;
    mTJBluetoothManager=[TJBluetoothManager shareTJBluetoothManager];
    [mTJBluetoothManager BluetoothDisconnect];
    [mTJBluetoothManager SetViewController:3];
    if([mTJBluetoothManager getcentralManager].state == CBCentralManagerStatePoweredOff)
    {
        [self openBlueToothToSetting];
    }else{
        [mTJBluetoothManager scanPeripehrals];
    }
    [mTJBluetoothManager setBluetoothScanReturnedDataBlock:^(NSUInteger *selectIndex, NSMutableDictionary *peripheralDic) {
        if(!Startsetting)
        {
            return;
        }
        if([self.currentLock.lockMac isEqualToString:
            peripheralDic[kCBAdvDataManufacturerData]]){
            //连接蓝牙
            
            [mTJBluetoothManager ConnectBluetooth:peripheralDic[LHPeripheralKey]];
            
        }
    }];
    
    [mTJBluetoothManager setReturnBluetoothStatusBlock:^(NSUInteger *status,NSString *mac) {
        if(status==0){
            chishu=0;
            //未连接
            if(ifconnection){
 
                ifconnection=NO;
                ifgetid=NO;
                ifgetidasd=NO;
            }
            
        }else if(status==1){
            if(!Startsetting)
            {
                return;
            }
            if(ifconnection){
                return;
            }
            ifconnection=YES;
             
            //已连接,获取ID
            NSString *lockKey = nil;
            if([self.currentLock.lockIsJihuo isEqualToString:@"1"])
            {
                lockKey = self.currentLock.lockKey;
                
            }else{
                
                lockKey = @"0810151308107781";
            }
            
            [ mTJBluetoothManager BluetoothSendData:[LHBLEDataManager gainLockIdKey:lockKey]];
            if(self.hud){
                self.hud.labelText = (NSString *)[LHToolManager keyPath:TJSettingup withTarget:self];
            }
        }else if(status==2){
            //通讯成功
        }
    }];
    [mTJBluetoothManager setBluetoothReturnsDataBlock:^(NSUInteger *status, NSData *ReturnsData,NSString *mac) {
        if(!Startsetting)
        {
            return;
        }
        if(status==-3){
            LHLock *lock = [self currentLock];
            if(!lock){
                return;
            }
            NSString *lockkey=@"";
            if([lock.lockIsJihuo isEqualToString:@"0"]){
                lockkey=@"0810151308107781";
            }else{
                lockkey=lock.lockKey;
            }
            BOOL  isTure = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:lockkey];
            //返回数据是否可以解析

            NSLog(@"%@\n",isTure ? @"反馈正确" : @"反馈错误");
            
            if(!isTure){
                if(!ifgetidasd){
                    ifgetidasd=YES;
                    return;
                }
                
                [ mTJBluetoothManager BluetoothSendData:[LHBLEDataManager gainLockIdKey:@"0810151308107781"]];
                return;
            }
            BOOL isOpen = [LHBLEDataManager isOpenFeedback:ReturnsData];

            NSLog(@"锁状态:%@\n",isOpen ? @"已经打开" : @"已经关闭");
            switch (LHBLEDataManager.feedBackType) {
                case 1:
                    if(!ifgetid){
                        //验证开锁
                        [mTJBluetoothManager BluetoothSendData:[LHBLEDataManager gainOpenLockKey]];
                    }else{
                        chishu++;
                        
                        if(chishu>=5){
                            chishu=0;
                            [mTJBluetoothManager BluetoothSendData:[LHBLEDataManager gainOpenLockKey]];
                        }
                    }
                    ifgetid=YES;
                    break;
                case 2:
                    //开锁成功 然后设置密码成功
                   [mTJBluetoothManager BluetoothSendData:[LHBLEDataManager gainTouchOpenKey:self.pasView.textField.text]];
                    break;
                case 5:
                    //设置快击密码成功
                    if(!ifgetid){
                        return;
                    }
                    if(self.hud){
                        [self.hud removeFromSuperview];
                        self.hud = nil;
                    }
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"settingsuccess"object:nil];
                    [self showSuccessHub];
                    break;
                default:
                    //秘钥错误 无法打开
                    
                    break;
            }
        }
    }];
}
-(void)viewWillDisappear:(BOOL)animated
{
    //关闭蓝牙扫描
    [mTJBluetoothManager stopScan];
    
}
-(void)SettingSubViewInViewController
{
    [self settingLableInViewController];
    
    self.pasView = [[SYPasswordView alloc] initWithFrame:CGRectMake(16, 80, LHSW - 32, 50)];
    
    [self.motherView addSubview:_pasView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
  
}

-(void)settingLableInViewController
{
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHSettingPass withTarget:self];
    
    [self.comfrimButton setTitle:(NSString *)[LHToolManager keyPath:LHConfiguration withTarget:self] forState:UIControlStateNormal];
    
    self.adviseLable.text = (NSString *)[LHToolManager keyPath:LHAdviseLable withTarget:self];
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)settingCodeToBle:(id)sender {
     if(self.pasView.textField.text.length == 3)
        {
             Startsetting=YES;
           self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            self.hud.userInteractionEnabled = NO;
            if(self.hud){
                self.hud.labelText = (NSString *)[LHToolManager keyPath:TJconnecting withTarget:self];
            }
        }else{
            
           LHProgressHUD((NSString *)[LHToolManager keyPath:LHEquipmentCode withTarget:self]);
        }
}
#pragma mark - 蓝牙

-(void)showSuccessHub
{
     [self.navigationController popViewControllerAnimated:YES];
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
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(self.hud){
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    [mTJBluetoothManager stopScan];
    [mTJBluetoothManager BluetoothDisconnect];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"controllerreconnectBluetooth"object:nil];

}

-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
    if(self.hud){
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
