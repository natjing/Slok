
//
//  LHShareListViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/31.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHShareListViewController.h"
#import "LHShareListTableViewCell.h"
#import "LHHeaderShareView.h"
#import "LHShareNameViewController.h"
#import "LHSettingLockViewController.h"
#import "TJBluetoothManager.h"
@interface LHShareListViewController ()<DFUServiceDelegate,DFUProgressDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;

@property (weak, nonatomic) IBOutlet UIButton *deletButton;
@property (weak, nonatomic) IBOutlet UIView *globalview;

@property (nonatomic,strong) NSArray *shareLocks;
@property (weak, nonatomic) MBProgressHUD *hud;
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property(nonatomic, strong) DFUServiceController *controller;
@property(nonatomic, strong) DFUServiceInitiator *initiator;
@property(nonatomic, strong) DFUFirmware *selectedFirmware;
@end

@implementation LHShareListViewController{
    TJBluetoothManager *mTJBluetoothManager;
    Boolean *ifconnection;
    Boolean *ifgetid;
    Boolean *ifgetidasd;
    Boolean *ifreset;
    NSUInteger *chishu;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initSettingViewController];
    //监听广播，提示设置成功
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SuccessTips) name:@"settingsuccess"object:nil];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
}
-(void)initSettingViewController
{
    self.navTitleLable.text = self.selectLock.lockName;
    
    [self.deletButton setTitle:(NSString *)[LHToolManager keyPath:LHLockDelet withTarget:self] forState:UIControlStateNormal];
    if([self.selectLock.lockSpecies isEqualToString:@"3"]||
       [self.selectLock.lockSpecies isEqualToString:@"4"]){
        
    }else{
        if([self.selectLock.lockType isEqualToString:@"0"]){
            [self addHeaderViewInTableView];
        }
    }
}
-(void)SuccessTips
{
    LHProgressHUD((NSString *)[LHToolManager keyPath:LHSuccess withTarget:self]);
}
-(void)addHeaderViewInTableView
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LHSW, 290)];
    headView.backgroundColor = [UIColor clearColor];
    LHHeaderShareView *showkeyView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHHeaderShareView class]) owner:nil options:nil] lastObject];
    
    showkeyView.frame = CGRectMake(0, 0, LHSW, 90);
    
    showkeyView.settingKeyImageView.image = [UIImage imageNamed:@"headerShare3"];
    showkeyView.settingKeyImageView.tag='Fairepivoterimg';
    
    showkeyView.operationtips.text = (NSString *)[LHToolManager keyPath:LHTemporaryKey withTarget:self];
    showkeyView.shareLockLable.text = (NSString *)[self gainLocktemporaryKey:self.selectLock.lockKey Mac:self.selectLock.lockMac];
    showkeyView.shareLockLable.tag='shareLockLable';
    UITapGestureRecognizer *updateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatekeydata:)];
    
    [showkeyView addGestureRecognizer:updateTap];
     [headView addSubview:showkeyView];
        LHHeaderShareView *keySettingView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHHeaderShareView class]) owner:nil options:nil] lastObject];
        
        keySettingView.frame = CGRectMake(0, 70, LHSW, 90);
        
        keySettingView.settingKeyImageView.image = [UIImage imageNamed:@"headerShare2"];
    
        keySettingView.operationtips.text = (NSString *)[LHToolManager keyPath:LHSetKey withTarget:self];
        
        UITapGestureRecognizer *settingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(intoLockSettingViewController:)];
        
        [keySettingView addGestureRecognizer:settingTap];
        
        [headView addSubview:keySettingView];
    LHHeaderShareView *ResetView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHHeaderShareView class]) owner:nil options:nil] lastObject];
    
    ResetView.frame = CGRectMake(0, 140, LHSW, 90);
    
    ResetView.settingKeyImageView.image = [UIImage imageNamed:@"headerShare2"];
    
    ResetView.operationtips.text = (NSString *)[LHToolManager keyPath:TJLockreset withTarget:self];
    
    UITapGestureRecognizer *ResetTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ResetLockViewController:)];
    
    [ResetView addGestureRecognizer:ResetTap];
        
        [headView addSubview:ResetView];
    
    LHHeaderShareView *UpdatedView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHHeaderShareView class]) owner:nil options:nil] lastObject];
    
    UpdatedView.frame = CGRectMake(0, 210, LHSW, 90);
    
    UpdatedView.settingKeyImageView.image = [UIImage imageNamed:@"headerShare2"];
    
    UpdatedView.operationtips.text = (NSString *)[LHToolManager keyPath:TJFirmwareupgrade withTarget:self];
    
    UITapGestureRecognizer *UpdatedTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(UpdatedLockViewControllers:)];
    
    [UpdatedView addGestureRecognizer:UpdatedTap];
    
    [headView addSubview:UpdatedView];
    
    [self.globalview addSubview:headView];
    
    
}
-(void)intoLockSettingViewController:(UITapGestureRecognizer *)tap
{
    LHSettingLockViewController *viewController = [[LHSettingLockViewController alloc] init];
    
    viewController.currentLock = self.selectLock;
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"ChiudiHomeScansionieconnessioni"object:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)updatekeydata:(UITapGestureRecognizer *)tap
{
    UIImageView *mUIImageView=[self.view viewWithTag:'Fairepivoterimg'];
    CABasicAnimation* rotationAnimation;
    
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [mUIImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];//开始动画
    UILabel *mUILabel=[self.view viewWithTag:'shareLockLable'];
//    mUILabel.text= (NSString *)[LHToolManager keyPath:LHTemporaryKey withTarget:self];
    //mUILabel.hidden=YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        mUILabel.text = (NSString *)[self gainLocktemporaryKey:self.selectLock.lockKey Mac:self.selectLock.lockMac];
        mUILabel.hidden=NO;
    });
    
   //[self.shareListTableView reloadData];
}


#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)shareIsBtn:(UITapGestureRecognizer *)tap
{
    LHShareNameViewController *viewController = [[LHShareNameViewController alloc] init];
    
    viewController.currenLock = self.selectLock;
    
    [self.navigationController pushViewController:viewController animated:YES];
}
- (IBAction)deletCurrentLock:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHWarning withTarget:self] message:(NSString *)[LHToolManager keyPath:LHDeleteWarning withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHYes withTarget:self] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [self deletCurrentLock];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHNo withTarget:self] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)deletCurrentLock
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postDeleteLock:self.selectLock.lockId handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                    [LHToolManager.rootViewController reloadDataInViewController];
                    
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }else{
                    NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHDeleteError withTarget:self]];
                    
                    LHProgressHUD(message);
                }
            }];
            
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
//
//#pragma mark - UITableViewDelegate
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60.0f;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return self.shareLocks.count ? 30.0f : 0;
//}
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.shareLocks.count;
//}
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    LHShareListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//
//    [cell.shareLockDeletButton setTitle:(NSString *)[LHToolManager keyPath:LHLockDelet withTarget:self] forState:UIControlStateNormal];
//
//    NSDictionary *mainDic = self.shareLocks[indexPath.row];
//
//    cell.shareLockNameLable.text = mainDic[LHRShareName];
//
//    cell.lockData = mainDic;
//
//    [cell initShareListTableViewCell];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    return cell;
//}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LHSW, 21)];
//    UILabel *headerLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LHSW - 30, 21.0f)];
//    headerLable.font = [UIFont systemFontOfSize:16.0f];
//    headerLable.textColor = LHRGBColor(180, 180, 180);
//    headerLable.text = (NSString *)[LHToolManager keyPath:LHShareLockList withTarget:self];
//    [headerView addSubview:headerLable];
//    return headerView;
//}
-(NSString *)gainLocktemporaryKey:(NSString *)key Mac:(NSString *)macstr
{
    uint8_t tem[8];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    int year=(int)[dateComponent year];
    if(year<2000){
        year=2001;
    }
    tem[4]=year-2000;
    int mon=(int)[dateComponent month];
    tem[3]=mon;
    int day=(int)[dateComponent day];
    tem[2]=day;
    int hour = (int) [dateComponent hour];
    tem[1]=hour;
    int minute = (int) [dateComponent minute];
    tem[0]=(minute+1)/5;
    NSString *strUrl = [macstr stringByReplacingOccurrencesOfString:@":" withString:@""];
    Byte *oBytemac = (Byte *)[[self sendHex:strUrl] bytes];
    tem[5]=oBytemac[5];
    tem[6]=oBytemac[4];
    tem[7]=oBytemac[3];
    NSData *keyData = [self sendHex:key];
    //    [self decrypt]; 反推0881------ 得到下面的fd32
    //NSData *keyData = [self sendHex:@"fd32e3986b4884b6"];
    Byte *oByte = [keyData bytes];
    for(int dq=0;dq<8;dq++){
        oByte[8+dq]=~oByte[dq];
    }
    return [self ecrypt:tem oByte:oByte];
}
- (NSData *)sendHex:(NSString *)sendStr
{
    const char *buf = [sendStr UTF8String];
    NSMutableData *data = [NSMutableData data];
    if (buf)
    {
        uint32_t len = strlen(buf);
        char singleNumberString[3] = {'\0', '\0', '\0'};
        uint32_t singleNumber = 0;
        for(uint32_t i = 0 ; i < len; i+=2)
        {
            if ( ((i+1) < len) && isxdigit(buf[i]) && (isxdigit(buf[i+1])) )
            {
                singleNumberString[0] = buf[i];
                singleNumberString[1] = buf[i + 1];
                sscanf(singleNumberString, "%x", &singleNumber);
                uint8_t tmp = (uint8_t)(singleNumber & 0x000000FF);
                [data appendBytes:(void *)(&tmp) length:1];
            }
            else
            {
                break;
            }
        }
        
        return  data;
    }
    return [NSData data];
}
- (NSData *)sendHexqw:(NSString *)sendStr
{
     //16进制字符串
    int j=0;
    Byte bytes[128];
    ///3ds key的Byte 数组， 128位
    for(int i=0;i<[sendStr length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [sendStr characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [sendStr characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;
                bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:128];
 
   return newData;
}
//加密
-(NSString *)ecrypt:(uint8_t *)v oByte:(uint8_t *)k
{
    uint32_t v0=0, v1=0, sum=0, i;
    uint32_t delta=0x9e3779b9;
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];
    memcpy((uint8_t  *)&v0,&v[0],4);
    memcpy((uint8_t  *)&v1,&v[4],4);
    memcpy((uint8_t  *)&k0,&k[0],4);
    memcpy((uint8_t  *)&k1,&k[4],4);
    memcpy((uint8_t  *)&k2,&k[8],4);
    memcpy((uint8_t  *)&k3,&k[12],4);
    for (i=0; i < 32; i++) {
        sum += delta;
        v0 += ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        v1 += ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
    }
    memcpy((uint8_t  *)&v[0],(uint8_t  *)&v0,4);
    memcpy((uint8_t  *)&v[4],(uint8_t  *)&v1,4);
    
    for (int i = 0; i < 8; ++i) {
        v[i] = v[i]%10;
        if(v[i]==0){
            v[i]=1;
        }
    }
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < 3; ++ i) {
        
        [keyString appendFormat:@"%x",v[i]];
       
    }
    
    return keyString;
    }
//解密
- (void) decrypt{
    uint8_t v[8]={0x08,0x10,0x15,0x13,0x08,0x10,0x77,0x81};
    Byte *k = (Byte *)[[self sendHex:@"A1B2C3D4E5F613243546587A8B9CADBC"] bytes];
    
    uint32_t v0=v[0],v1=v[1],sum=0xC6EF3720,i;
    uint32_t delta=0x9e3779b9;
    uint32_t k0=k[0],k1=k[1],k2=k[2],k3=k[3];
    memcpy((uint8_t  *)&v0,&v[0],4);
    memcpy((uint8_t  *)&v1,&v[4],4);
    memcpy((uint8_t  *)&k0,&k[0],4);
    memcpy((uint8_t  *)&k1,&k[4],4);
    memcpy((uint8_t  *)&k2,&k[8],4);
    memcpy((uint8_t  *)&k3,&k[12],4);
    for (i=0; i < 32; i++) {
       v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        
         sum -= delta;
    }
    memcpy((uint8_t  *)&v[0],(uint8_t  *)&v0,4);
    memcpy((uint8_t  *)&v[4],(uint8_t  *)&v1,4);
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i <8; ++ i) {
        
        [keyString appendFormat:@"%02x",v[i]];
    }
    
}
-(void)ResetLockViewController:(UITapGestureRecognizer *)tap
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHPrompt withTarget:self] message:(NSString *)[LHToolManager keyPath:TJResetlock withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    
    __weak typeof(alert) weakAlert = alert;
    // 添加确认按钮
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHConfirm withTarget:self] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        self.hud.userInteractionEnabled = NO;
        if(self.hud){
            self.hud.labelText = (NSString *)[LHToolManager keyPath:TJconnecting withTarget:self];
        }
          [self BluetoothManage];
        
    }]];
    // 添加取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHNo withTarget:self] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];

}
//设置蓝牙服务
//蓝牙管理
-(void)BluetoothManage{
    ifconnection=NO;
    ifgetid=NO;
    ifgetidasd=NO;
    ifreset=NO;
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
        if(ifreset){
            return;
        }
        if([self.selectLock.lockMac isEqualToString:
            peripheralDic[kCBAdvDataManufacturerData]]){
            //连接蓝牙
            [mTJBluetoothManager ConnectBluetooth:peripheralDic[LHPeripheralKey]];
        }
    }];
    
    [mTJBluetoothManager setReturnBluetoothStatusBlock:^(NSUInteger *status,NSString *mac) {
        if(ifreset){
            return;
        }
        if(status==0){
            //未连接
            chishu=0;
            if(ifconnection){
                
                ifconnection=NO;
                ifgetid=NO;
                ifgetidasd=NO;
                [self BluetoothManage];
            }
        }else if(status==1){
            if(ifconnection){
                return;
            }
            ifconnection=YES;
            //已连接,获取ID,把重置id写进去
        
            [ mTJBluetoothManager BluetoothSendData:[LHBLEDataManager resetLockIdKey:@"0000000013080001"]];
            if(self.hud){
                self.hud.labelText = (NSString *)[LHToolManager keyPath:TJBeingreset withTarget:self];
            }
        }else if(status==2){
            //通讯成功
        }
    }];
    [mTJBluetoothManager setBluetoothReturnsDataBlock:^(NSUInteger *status, NSData *ReturnsData,NSString *mac) {
        if(ifreset){
            return;
        }
        if(status==-3){
            NSString *lockkey=@"";
            if([self.selectLock.lockIsJihuo isEqualToString:@"0"]){
                lockkey=@"0810151308107781";
            }else{
                lockkey=self.selectLock.lockKey;
            }
            BOOL  isTure = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:lockkey];
            //返回数据是否可以解析
            NSLog(@"%@\n",isTure ? @"反馈正确" : @"反馈错误");
            if(!isTure){
                if(!ifgetidasd){
                    ifgetidasd=YES;
                    return;
                }
                 [ mTJBluetoothManager BluetoothSendData:[LHBLEDataManager resetLockIdKey:@"0000000013080001"]];
                return;
            }
            switch (LHBLEDataManager.feedBackType) {
                case 1:
                    if(!ifgetid){
                        //验证开锁
                         BOOL isTures = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:@"0810151308107781"];
                          [mTJBluetoothManager BluetoothSendData:[LHBLEDataManager ResetLockKey]];
                    }else{
                        chishu++;
                        if(chishu>=5){
                            chishu=0;
                            [mTJBluetoothManager BluetoothSendData:[LHBLEDataManager ResetLockKey]];
                        }
                    }
                    ifgetid=YES;
                    break;
                case 2:
                 [ mTJBluetoothManager BluetoothSendData:[LHBLEDataManager resetLockIdKey:@"0000000013080001"]];
                    break;
                case 6:
                    //设置快击密码成功
                    ifreset=YES;
                    if(!ifgetid){
                        return;
                    };
                    if(self.hud){
                        [self.hud removeFromSuperview];
                        self.hud = nil;
                    };
                    [self showlatab];
                    break;
                default:
                    //秘钥错误 无法打开
                    
                    break;
            }
        }
    }];
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


-(void)showlatab
{
      LHProgressHUD((NSString *)[LHToolManager keyPath:TJResetsuccess withTarget:self]);
}

#pragma mark - 蓝牙
-(void)updateBle
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOff)
    {
        [self openBlueToothToSetting];
    }else{
        [self scanPeripehrals];
    }
}
//前台开启蓝牙扫描
- (void)scanPeripehrals
{
     if(self.centralManager.state == CBCentralManagerStatePoweredOn){
        NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
        [self.centralManager scanForPeripheralsWithServices:nil options:scanForPeripheralsWithOptions];
     }
}
#pragma mark - ble方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
    //判断蓝牙是否打开
    if(self.centralManager.state == CBCentralManagerStatePoweredOn){
       // [self scanPeripehrals];
    }
}


/** 发现符合要求的外设，回调  连接*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *macIp=[LHToolManager gainMacToData:advertisementData[kCBAdvDataManufacturerData]];
    NSString *blename=  peripheral.name;
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        blename = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
        blename = peripheral.name;
    }else{
        blename = [peripheral.identifier UUIDString];
    }
        if([blename isEqualToString:@"DfuTarg"]){
           self.connectedPeripheral = peripheral;
            [self.centralManager connectPeripheral:peripheral options:nil];
            [self.centralManager stopScan];
        }
}
/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    // 设置代理
    printf("已连接上设备：");
    printf("name = %s\n",[peripheral.name UTF8String]);
    self.connectedPeripheral = peripheral;
    //连接成功
    if(self.hud){
        self.hud.labelText = (NSString *)[LHToolManager keyPath:TJDuringupgrade withTarget:self];
    }
    // 开始
    if ( !self.controller )
    {
        if ([self _InitInitator])
        {
            self.controller = [self.initiator start];
        }
        else
        {
            NSLog(@"初始化失败");
        }
    }
    else
    {
        [self.controller restart];
    }
 
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
 
    [self scanPeripehrals];
    [self.centralManager connectPeripheral:peripheral options:nil];
}
/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    //软件在前台 断开连接可以设置重新扫描
    [self scanPeripehrals];
    //软件在后台 断开连接可以设置重新连接
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
  }

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
  }

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {

    }
/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(characteristic.value.length != 19){
        return;
    }
}
/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //NSLog(@"写入成功");
}


-(void)UpdatedLockViewControllers:(UITapGestureRecognizer *)tap
{
    //获取沙盒地址
    NSString *cacherPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    
    NSArray *users = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    LHUser *user=nil;
    if(users.count>0){
        user = users.firstObject;
    }
    
    NSString *file=@"";
    if(user.VersionName){
        
        file =[[NSString alloc]initWithFormat:@"%@%@%@",cacherPath,@"/",user.VersionName];
        
    }else{
        
        file =[[NSString alloc]initWithFormat:@"%@%@%@",cacherPath,@"/",@"SLOK-P01-V107-1.zip"];
    }
    
 
    if(![self isFileExist:user.VersionName]){
        if(self.hud){
            [self.hud removeFromSuperview];
            self.hud = nil;
        }
        LHProgressHUD((NSString *)[LHToolManager keyPath:TJUpdatefailure withTarget:self]);
        return;
    }
    [self _InitSwift:file];
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.userInteractionEnabled = NO;
    if(self.hud){
        self.hud.labelText = (NSString *)[LHToolManager keyPath:TJconnecting withTarget:self];}
    [self updateBle];
}
-(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}
- (void)_InitSwift:(NSString *)updateFilePath
{
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:[NSURL fileURLWithPath:updateFilePath]];
    self.selectedFirmware = selectedFirmware;
    
}

- (BOOL)_InitInitator
{
    if (!self.selectedFirmware)
    {
        return NO;
    }
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:self.centralManager target:self.connectedPeripheral];
    self.initiator = [initiator withFirmware:self.selectedFirmware];
    self.initiator.forceDfu = YES; // 这个是强制升级, 如果是YES无论硬件是不是最新版本, 都重新写入程序.  如果是NO, 硬件如果是最新版本,就不升级.
    self.initiator.delegate = self; // - to be informed about current state and errors
    self.initiator.progressDelegate = self; // - to show progress bar
    
    return (self.initiator != nil);
}


/// 进度
- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    
}
- (void)dfuStateDidChangeTo:(enum DFUState)state;
{
    NSLog(@"dfuStateDidChangeTo %d",(int)state);
    if (state==DFUStateCompleted) {
        [mTJBluetoothManager BluetoothDisconnect];
        if(self.hud){
            [self.hud removeFromSuperview];
            self.hud = nil;
        }
        //  NSLog(@"成功成功成功成功成功成功");
        LHProgressHUD((NSString *)[LHToolManager keyPath:TJUpdatesuccessed withTarget:self]);
    }
}
- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message
{
    NSLog(@"dfuError -- didOccurWithMessage %@",message);
}
-(void)viewDidAppear:(BOOL)animated
{
    if (_ifRefresh) {
        _ifRefresh=NO;
    LHProgressHUD((NSString *)[LHToolManager keyPath:LHShareSuccess withTarget:self]);
    }
  
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if(self.hud){
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
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
