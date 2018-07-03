//
//  ViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/20.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "ViewController.h"
#import "LHLoginViewController.h"
#import "LHLockControllerView.h"
#import "LHFunctionControlView.h"
#import "NewCommonMenuView.h"
#import "UIView+AdjustFrame.h"


#import "LHSettingViewController.h"
#import "LHHistoryViewController.h"
#import "LHMyLockViewController.h"
#import "LHShareViewController.h"
#import "LHMyLockViewController.h"
#import "LHLockController.h"
#import "LHNoticeViewController.h"
#import "LHPushController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LHBleAddLockViewController.h"
#import "LHShareListViewController.h"
#import "SubmitemailViewController.h"
#import "FriendsObj.h"
#import "TJGreenControl.h"
#import "LoginControllerView.h"
#import "LHEmailLoginViewController.h"
#import "RetrievepasswordViewController.h"
#import "TJShareViewController.h"
#import "TJFriendsViewController.h"
#import "TJBluetoothManager.h"
#import "BGLogation.h"
#import "JDGScanQRcodeController.h"
#import "LHVoicePlayManager.h"

#define openKey [LHBLEDataManager gainOpenLockKey]//@"55002A7FAA"
#define closeKey [LHBLEDataManager gainCloseLockKey]//@"55002B80AA"
#define electricityKey @"55000156AA"
#define LHkCBAdvDataLocalName @"kCBAdvDataLocalName"
#define LHPeripheral @"peripheral"
#define LHPeripheralKey @"peripheralKey"
@interface ViewController ()<LHFunctionDelegate,LHSwitchLanguageDelegate,UIScrollViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,LHVoicePlayDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *lockManageScrollView;

@property (weak, nonatomic) IBOutlet TJGreenControl *lockNumPageControl;

@property (weak, nonatomic) IBOutlet UILabel *gologin;
@property (weak, nonatomic) IBOutlet UIImageView *functionselection;
@property (nonatomic,strong)LHFunctionControlView *functionView;
@property (nonatomic,strong)UIView *maskView;
@property (nonatomic,strong)LoginControllerView *loginconview;

@property (nonatomic,strong)UIView *loginView;
@property (nonatomic,assign) BOOL flag;
@property (nonatomic,assign) BOOL initiativeclosed;
@property (nonatomic,assign) int itemCount;

@property (nonatomic,strong) NSString *bleWord;
@property (nonatomic,strong) NSString *cwguyhiojString;

@property (nonatomic,assign)NSUInteger slokState;

@property (nonatomic,assign)NSUInteger lockState;

@property (nonatomic,assign)NSInteger selectIndex;

@property (nonatomic,assign)NSInteger Targetnumber;//要移动到的位置

@property(nonatomic,strong)BGLogation *bgLogation;
/*
 *isNoAutoOpen解决连接蓝牙后频繁自动开锁问题
 */
@property(nonatomic,assign)BOOL isNoAutoOpen;
/*
 *isConnectBle连接蓝牙后页面跳转
 */
@property(nonatomic,assign)BOOL isConnectBle;
@property(nonatomic,strong)NSMutableArray *advData;
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property (weak, nonatomic) MBProgressHUD *hud;


@property(nonatomic,strong)LHVoicePlayManager *voicePlayer;
@end

@implementation ViewController{
    
    NSMutableArray *requestDictionary;
    BOOL *ifshowtips;//是否同时了无法打开，如果没有就在获取一次ID
    BOOL *ifSuccessnews;//在当前连接中是否打开了一次锁
    BOOL *ifRecorderror;//当前锁是否激活的记录是否错误
    BOOL *ifProgramsliding;//是否是程序设置滑动
    
    BOOL *ifGetId;//在当前连接中是否接收到获取ID的返回值
    TJBluetoothManager *mTJBluetoothManager;
    NSString *FileVersion;
    NSString *VersionURL;
    NSString *VersionName;
}
//0810151308107781
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
 
    ifshowtips=NO;
    ifSuccessnews=NO;
    ifRecorderror=NO;
    ifProgramsliding=NO;
    ifGetId=NO;
    requestDictionary= [NSMutableArray array];
    [self settingSubViewInViewController];
    
    [self useTimePaixuInViewController];
    
    [self initSubViewInViewController];
   
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if([LHToolManager isLogin] && status)
        {
            [self reloadDataInViewController];
        }
    }];
    if([LHToolManager isLogin]){
        self.initiativeclosed=NO;
        //监听广播，关闭当前页面的蓝牙连接
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DisattivaScansioneBluetooth) name:@"ChiudiHomeScansionieconnessioni"object:nil];
        
        //监听广播，打开当前页面的蓝牙连接
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reconnectBluetooth) name:@"controllerreconnectBluetooth"object:nil];
        
        
        //监听广播，调用连接最后一个蓝牙
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mTJBluetoothPeripehrals) name:@"htconnectionPeripehrals"object:nil];
        self.bgLogation =[[BGLogation alloc] init];
        __weak ViewController *weakSelf = self;
        
        self.bgLogation.block = ^(Boolean *blescan){
            
             [mTJBluetoothManager htconnectionPeripehrals];
            
        };
        [self.bgLogation startLocation];
    }
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    self.tap.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:self.tap];
    NSError *audioSessionError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if ([audioSession setCategory:AVAudioSessionCategoryAmbient error:&audioSessionError]) {
        
        //NSLog(@"设置音频类别成功");
        
    }else{
        
        // NSLog(@"不能设置音频类别");
        
    }
}
-(void)voiceControllerNew
{
    if(self.voicePlayer != nil)
    {
        [self.voicePlayer stopPlay];
    }
    
    self.voicePlayer = [[LHVoicePlayManager alloc] init];
    
    self.voicePlayer.voicePlayDelegate = self;
}

-(void)mTJBluetoothPeripehrals{
    [mTJBluetoothManager htconnectionPeripehrals];
}

-(void)DisattivaScansioneBluetooth
{
    self.initiativeclosed=YES;
    //关闭蓝牙扫描
    [mTJBluetoothManager stopScan];
}
//重新启用蓝牙管理单例
-(void)reconnectBluetooth
{
    self.initiativeclosed=NO;
    mTJBluetoothManager=[TJBluetoothManager shareTJBluetoothManager];
    [mTJBluetoothManager BluetoothDisconnect];
    [mTJBluetoothManager SetViewController:1];
    if([mTJBluetoothManager getcentralManager].state == CBCentralManagerStatePoweredOff)
    {
        [self openBlueToothToSetting];
    }else{
        [mTJBluetoothManager scanPeripehrals];
    }
    [mTJBluetoothManager setBluetoothScanReturnedDataBlock:^(NSUInteger *selectIndex, NSMutableDictionary *peripheralDic) {
        if(selectIndex==-1){
            NSDictionary *dic = [NSDictionary dictionary];
            dic = @{
                    @"result":@"1",
                    @"infos":peripheralDic
                    };
            LHLockController *lockController = [[LHLockController alloc] init];
            [lockController formatLocks:dic];
            self.lockNumPageControl.currentPage = 0;
            [self addBlockRefreshData];
            [self initSubViewInViewController];
            self.selectIndex = 0;
            [self isConnect:1];
            return;
        }
        if(self.selectIndex!=selectIndex){
            ifProgramsliding=YES;
            self.selectIndex =selectIndex;
            self.Targetnumber=self.selectIndex;
            [self.lockManageScrollView setContentOffset:CGPointMake(LHSW*self.selectIndex, 0) animated:YES];

            self.lockNumPageControl.currentPage = selectIndex;
        }
           [self isConnect:1];
    }];
    
    [mTJBluetoothManager setReturnBluetoothStatusBlock:^(NSUInteger *status,NSString *mac) {
        if(status==0){
            //未连接
            self.isConnectBle = NO;
            [self isConnect:0];
         
            [self changeOpenState:YES];
        }else if(status==1){
            //已连接,获取Id
            if(![mac isEqualToString:@""]){
                self.cwguyhiojString=mac;
            }
            if(![self setselectIndex]){
                return;
            };
            ifshowtips=NO;
            ifSuccessnews=NO;
            ifRecorderror=NO;
            ifGetId=NO;
            self.isNoAutoOpen = NO;
            [self isConnect:1];
            LHLockControllerView *currenView = [self currentControllerView];
            if(currenView)
            {
                LHLock *lock = [self currentLock];
                if(!lock){
                    return;
                }
                self.bleWord = [LHBLEDataManager gainLockIdKey:lock.lockKey];
                NSLog(@"key:%@\n",lock.lockKey);
                [LHBLEDataManager setBleBlock:^(int eleNum){
                    if(eleNum>70){
                        currenView.dainciimg.image=[UIImage imageNamed:@"dianchi6"];
                    }else if (eleNum>40){
                        currenView.dainciimg.image=[UIImage imageNamed:@"dianchi7"];
                    }else{
                        currenView.dainciimg.image=[UIImage imageNamed:@"dianchi8"];
                    }
                    
                }];
                if(!self.isConnectBle){
                   [self playOnOtherMusic:@"connect"];
                }
                //获取设备ID，10指令
                 [mTJBluetoothManager BluetoothSendData:self.bleWord];
            }
        }else if(status==3){
            //通讯成功
            if(![mac isEqualToString:@""]){
                self.cwguyhiojString=mac;
            }
            if(![self setselectIndex]){
                return;
            };
        }
    }];
    [mTJBluetoothManager setBluetoothReturnsDataBlock:^(NSUInteger *status, NSData *ReturnsData,NSString *mac) {
        if(status>=0){
            if(![mac isEqualToString:@""]){
                self.cwguyhiojString=mac;
            }
            
            if(![self setselectIndex]){
                return;
            };
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
//            BOOL  isTure = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:lock.lockKey];
            NSLog(@"%@\n",isTure ? @"反馈正确" : @"反馈错误");
            if(isTure&&ifRecorderror){
                ifRecorderror=NO;
                if([lock.lockIsJihuo isEqualToString:@"0"]){
                    
                    lock.lockIsJihuo = @"1";
                    [LHNetworkManager postActionLock:lock.lockId handle:^(id result, NSError *error) {
                        If_Respose_Success(result, error)
                        {
                            [LHDataManager LH_UpdataFmdbId:lock withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(lock, lockId) value:lock.lockId];
                        }
                    }];
                }else{
                    BOOL isTures = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:@"0810151308107781"];
                    self.bleWord = [LHBLEDataManager gainUpdataPassKey];
                    [mTJBluetoothManager BluetoothSendData:self.bleWord];
                    return;
                }
                
            }
            if(!isTure){
                //无法解析返回数据，提示或许不是锁的拥有者
                //[self changeOpenState:true];
                [self showNotOpen:ReturnsData];
                return;
            }
            BOOL isOpen = [LHBLEDataManager isOpenFeedback:ReturnsData];
            [self changeOpenState:isOpen];
            NSLog(@"锁状态:%@\n",isOpen ? @"已经打开" : @"已经关闭");
            //估计锁的状态，设置需要传输的数据
            //self.bleWord = isOpen ? closeKey : openKey;
            //只需要打开
            self.bleWord = openKey;
            LHLockControllerView *currenView = [self currentControllerView];
            if(!currenView){
                return;
            }
            switch (LHBLEDataManager.feedBackType) {
                case 1:
                    //1 写ID
                    if([lock.lockIsJihuo isEqualToString:@"0"]){//更新秘钥
                        if(!ifGetId){
                            ifGetId=YES;
                            return;
                        }
                    BOOL isTures = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:@"0810151308107781"];
                    self.bleWord = [LHBLEDataManager gainUpdataPassKey];
                    [mTJBluetoothManager BluetoothSendData:self.bleWord];
                    }else if(!isOpen&&[lock.lockAutoOpen boolValue]){
                        ifGetId=YES;
                        //自动开锁
                    [self performSelector:@selector(autoBleOpen) withObject:nil afterDelay:1.0f];
                    }else if(!isOpen){
                         ifGetId=YES;
                    }
                    break;
                case 2:
                    if(!ifGetId){
                        return;
                    }
                    //2 开锁  开锁成功
                    if(isOpen){
                        ifSuccessnews=YES;
                        //开门成功
                        [self feedBackOpenToInternet];
                        //开锁成功的提示
                        if(self.isConnectBle){
                              [self playOnOtherMusic:@"open"];
                        }else{
                            
                            // [self changeOpenState:NO];
                        }
                        //修改开锁按钮的状态
                    }
                    break;
                case 3:
                    if(!ifGetId){
                        return;
                    }
                    //落锁反馈
                    //修改开锁按钮的状态
                   // [self changeOpenState:isOpen];
                    break;
                case 4:
                    if(!ifGetId){
                        return;
                    }
                    //4更新密钥 成功
                    if(![lock.lockIsJihuo boolValue])
                    {
                        lock.lockIsJihuo = @"1";
                        [LHNetworkManager postActionLock:lock.lockId handle:^(id result, NSError *error) {
                            If_Respose_Success(result, error)
                            {
                                [LHDataManager LH_UpdataFmdbId:lock withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(lock, lockId) value:lock.lockId];
                            }
                        }];
                    }
                    if(!isOpen&&[lock.lockAutoOpen boolValue]){
                        //更新秘钥之后的自动开锁
                        [self performSelector:@selector(autoBleOpen) withObject:nil afterDelay:1.0f];
                    }
                    break;
                default:
                    if(!ifGetId){
                        return;
                    }
                    //秘钥错误 无法打开
                    //无法解析返回数据，提示或许不是锁的拥有者
                  //  [self changeOpenState:YES];
                    [self showNotOpen:ReturnsData];
                    break;
            }
        }
        
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    if(![LHToolManager isLogin])
    {
        
        self.gologin.text = (NSString *)[LHToolManager keyPath:LHLogin withTarget:self];
        
        self.functionselection.hidden=YES;
    }else{
        self.gologin.text=@"";
        self.functionselection.hidden=NO;
    }
}

-(void)settingSubViewInViewController
{
    LHToolManager.rootViewController = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recevePushData:) name:LHPushNotice object:nil];
    
    [self settingScrollViewInViewController];
    
    [self settingMenuViewInviewController];
    
    [self settingMaskViewInViewController];
    
    [self settingFunctionViewInViewController];
    
    [self settingloginViewInViewController];
    
    [self settingLoginControllerViewInViewController];
}
-(void)useTimePaixuInViewController
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if([LHToolManager isLogin] && locks.count)
    {
        LHLockController *lockController = [[LHLockController alloc] init];
        
        [lockController useTimePaixu:[NSMutableArray arrayWithArray:locks]];
    }
}
-(void)settingScrollViewInViewController
{
    self.lockManageScrollView.showsVerticalScrollIndicator = NO;
    
    self.lockManageScrollView.showsHorizontalScrollIndicator = NO;
    
    self.lockManageScrollView.bounces = NO;
    
    self.lockManageScrollView.pagingEnabled = YES;
    
    self.lockManageScrollView.delegate = self;
    
    [self.lockManageScrollView layoutIfNeeded];
}
-(void)settingMaskViewInViewController
{
    self.maskView  = [[UIView alloc] initWithFrame:CGRectMake(0, 20, LHSW, LHSH - 20)];
    
    self.maskView.backgroundColor = [UIColor blackColor];
    
    self.maskView.alpha = 0.4;
    
    [self.view addSubview:self.maskView];
    
    self.maskView.hidden = YES;
}
-(void)settingFunctionViewInViewController
{
    self.functionView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHFunctionControlView class]) owner:nil options:nil] lastObject];
    
    self.functionView.frame = CGRectMake(-LHSW, 0, LHSW, LHSH);
    
    [self addTapToFunctionView];
    
    [self.functionView settingFunctionControlView];
    
    [self.view addSubview:self.functionView];
    
    self.functionView.functionDelegate = self;
}
-(void)settingloginViewInViewController
{
    self.loginView  = [[UIView alloc] initWithFrame:CGRectMake(0, 20, LHSW, LHSH - 20)];
    
    self.loginView.backgroundColor = [UIColor blackColor];
    
    self.loginView.alpha = 0.4;
    
    [self.view addSubview:self.loginView];
    
    self.loginView.hidden = YES;
    
}
-(void)settingLoginControllerViewInViewController
{
    self.loginconview = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LoginControllerView class]) owner:nil options:nil] lastObject];
    
    self.loginconview.frame = CGRectMake(-LHSW, 0, LHSW-30, LHSH-200);
    [self.loginconview.Outloginview setUserInteractionEnabled:YES];
    [self addTapToLoginView];
    
    [self.loginconview settingLoginControllerView];
    
    [self.view addSubview:self.loginconview];
    
    
}

-(void)settingMenuViewInviewController
{
    self.flag = YES;
    
    NSArray *dataArray = @[@{
                               LHImageName : @"view8",
                               LHItemName : (NSString *)[LHToolManager keyPath:LHBluetoothAddLock withTarget:self]
                               },
                           @{
                               LHImageName : @"view9",
                               LHItemName : (NSString *)[LHToolManager keyPath:LHScanningAddLock withTarget:self]
                               }
                           ,
                           @{
                               LHImageName : @"view7",
                               LHItemName : (NSString *)[LHToolManager keyPath:LHSharelock withTarget:self]
                               }
                           ];
    
    __weak __typeof(&*self)weakSelf = self;
    
    CGFloat menuW = 0;
    
    switch ([LHToolManager isWhatLanguages]) {
        case 0:
            menuW = 160.0f;
            break;
        case 1:
            menuW = 150.0f;
            break;
        case 2:
            menuW = 160.0f;
            break;
        case 3:
            menuW = 160.0f;
            break;
        default:
            break;
    }
    
    [NewCommonMenuView createMenuWithFrame:CGRectMake(0, 0, menuW, 0) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
        
        [weakSelf isChoseMenuView:tag];
        
    } backViewTap:^{
        weakSelf.flag = YES;
    }];
}
-(void)initSubViewInViewController
{
    [self initScrollViewInViewController];
    
}
-(void)initScrollViewInViewController
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(locks.count)
    {
        [self exitLockInitScrollView];
       
    }else{
        
        [self noLockInitScrollView];
    }
    
}
//没有钥匙
-(void)noLockInitScrollView
{
    if(self.lockManageScrollView.subviews.count)
    {
        [self removeAllScrollViewSub];
    }
    
    self.lockManageScrollView.contentSize = CGSizeMake(LHSW, 0);
    
    LHLockControllerView *lockView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHLockControllerView class]) owner:nil options:nil] lastObject];
    
    lockView.center = CGPointMake(LHSW / 2.0, (LHSH - 140)/2.0);
    
    lockView.autoOpenLable.hidden = YES;
    
    lockView.autoSelectButton.hidden = YES;
    lockView.bounds = CGRectMake(0, 0, LHSW, LHSH - 140);
    
    [lockView initLockControllerViewLable:(NSString *)[LHToolManager keyPath:LHNoLock withTarget:self] withVoice:NO];
    lockView.typeimg.hidden=NO;
    if([LHToolManager isLogin]){
      [lockView.lockimg setImage:[UIImage imageNamed:@"LockController2.png"]];
        lockView.locklayout.backgroundColor=LHRGBColor(83, 74, 102);
        
    }else{
        [lockView.lockimg setImage:[UIImage imageNamed:@"LockController1.png"]];

    }
    //添加点击事件
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(intoBleLockViewController)];
    [lockView.lockimg addGestureRecognizer:tapGesturRecognizer];
    lockView.lockimg.userInteractionEnabled=YES;
    
    
    [lockView.lockStateButton addTarget:self action:@selector(showNolock:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.lockManageScrollView addSubview:lockView];
    
    self.lockNumPageControl.numberOfPages = 0;
}

-(void)exitLockInitScrollView
{
    if(self.lockManageScrollView.subviews.count)
    {
        [self removeAllScrollViewSub];
    }
    
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    self.lockManageScrollView.contentSize = CGSizeMake(LHSW * locks.count, 0);
    
    [locks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        LHLock *lock = (LHLock *)obj;
        
        LHLockControllerView *lockView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHLockControllerView class]) owner:nil options:nil] lastObject];
        
        lockView.center = CGPointMake(LHSW / 2.0 + LHSW * idx, (LHSH - 140) / 2.0);
        
        lockView.bounds = CGRectMake(0, 0, LHSW, LHSH - 140);
        
        //添加四个边阴影
        lockView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影颜色
        lockView.layer.shadowOffset = CGSizeMake(0, 0);//偏移距离
        lockView.layer.shadowOpacity = 0.02;//不透明度
        lockView.layer.shadowRadius = 10.0;//半径
        
        
       // [lockView initLockControllerViewLable:lock.lockName withVoice:([lock.lockNum hasPrefix:@"SK"] && lock.lockNum.length == 10)];
        
        [lockView initLockControllerViewLable:lock.lockName withVoice:([lock.lockSpecies isEqualToString:@"4"])];
        [lockView.lockStateButton addTarget:self action:@selector(openTheLock:) forControlEvents:UIControlEventTouchUpInside];
        
        if([lock.lockType isEqualToString:@"0"])
        {
            lockView.shareimg.image=[UIImage imageNamed:@"LockController6"];
        }else{
            lockView.shareimg.image=[UIImage imageNamed:@"LockController9"];
        }
        
        if([lock.lockSpecies isEqualToString:@"4"]){
            //声波锁
             [lockView.lockimg setImage:[UIImage imageNamed:@"LockController13.png"]];
             lockView.lockinformation.hidden=YES;
             lockView.autolockview.hidden=YES;
              lockView.lockStateButton.backgroundColor =LHRGBColor(254, 92, 90);
        }else if([lock.lockSpecies isEqualToString:@"3"]){
            //远程锁
            [lockView.lockimg setImage:[UIImage imageNamed:@"LockController12.png"]];
            lockView.lockinformation.hidden=YES;
            lockView.autolockview.hidden=YES;
              lockView.lockStateButton.backgroundColor =LHRGBColor(254, 92, 90);
        }else{
            //蓝牙锁  默认为挂锁
           if([lock.lockSpecies isEqualToString:@"1"]){
                //蓝牙U型锁
                [lockView.lockimg setImage:[UIImage imageNamed:@"LockController10.png"]];
            }else if([lock.lockSpecies isEqualToString:@"2"]){
                //蓝牙入户锁
                [lockView.lockimg setImage:[UIImage imageNamed:@"LockController11.png"]];
            }
            [lockView.autoSelectButton addTarget:self action:@selector(isAutoOpen:) forControlEvents:UIControlEventTouchUpInside];
            
            lockView.autoSelectButton.selected = [lock.lockAutoOpen boolValue];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(intoShareViewController:)];
            
            [lockView.btnShareView addGestureRecognizer:tap];
            lockView.lockStateButton.backgroundColor = LHRGBColor(83, 74, 102);
            lockView.lockStateButton.enabled = NO;
            if([lock.lockType isEqualToString:@"0"])
            {
                if([LHToolManager isLogin]){
                    lockView.typeimg.image=[UIImage imageNamed:@"LockController8"];
                    lockView.shareimg.image=[UIImage imageNamed:@"LockController6"];
                }else{
                    lockView.typeimg.hidden=YES;
                    lockView.demolabel.text= (NSString *)[LHToolManager keyPath:TJdemolabel withTarget:self];
                    lockView.shareimg.image=[UIImage imageNamed:@"LockController9"];
                }
            }else if([lock.lockId isEqualToString:@"282"])
            {
                lockView.typeimg.hidden=YES;
                lockView.demolabel.text= (NSString *)[LHToolManager keyPath:TJdemolabel withTarget:self];
                
                lockView.shareimg.image=[UIImage imageNamed:@"LockController9"];
                
            }else{
                lockView.typeimg.image=[UIImage imageNamed:@"LockController7"];
                
                lockView.shareimg.image=[UIImage imageNamed:@"LockController9"];
            }
            
        }
        [self.lockManageScrollView addSubview:lockView];
    }];
    
    [self.lockManageScrollView setContentOffset:CGPointZero animated:NO];
    
    if(locks.count > 1)
    {
        self.lockNumPageControl.numberOfPages = locks.count;
        
        self.lockNumPageControl.hidden = NO;
        
    }else{
        
        self.lockNumPageControl.hidden = YES;
    }
}
-(void)removeAllScrollViewSub
{
    for (UIView *subView in self.lockManageScrollView.subviews) {
        if([subView isKindOfClass:[LHLockControllerView class]])
        {
            [subView removeFromSuperview];
        }
    }
}

-(void)addTapToFunctionView
{
    UITapGestureRecognizer *backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFunctionView)];
    
    [self.functionView.backView addGestureRecognizer:backTap];
    
    UITapGestureRecognizer *settingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(intoSettingViewController:)];
    
    [self.functionView.settingView addGestureRecognizer:settingTap];
    
    UITapGestureRecognizer *logoutTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isBtnLogout:)];
    
    [self.functionView.logoutView addGestureRecognizer:logoutTap];
}
//弹出登录窗口中绑定各个点击事件
-(void)addTapToLoginView
{
    UITapGestureRecognizer *closeLoginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeLoginView)];
    
    [self.loginconview.Outloginview addGestureRecognizer:closeLoginTap];
    
    UITapGestureRecognizer *loginTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginbutton)];
    
    [self.loginconview.loginbutton addGestureRecognizer:loginTap];
    
    
    UITapGestureRecognizer *goregisterTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goregistered:)];
    [self.loginconview.registerbutton addGestureRecognizer:goregisterTap];
    
    self.loginconview.forgetpassword.userInteractionEnabled=YES;
    UITapGestureRecognizer *getbackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(isBtngetback)];
    
    [self.loginconview.forgetpassword addGestureRecognizer:getbackTap];
    
    UITapGestureRecognizer *loginWithTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithWechat:)];
    [self.loginconview.wechatview addGestureRecognizer:loginWithTap];
    
    UITapGestureRecognizer *TwitterWithTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithTwitter:)];
    [self.loginconview.twitterview addGestureRecognizer:TwitterWithTap];
    UITapGestureRecognizer *FacebookWithTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithFacebook:)];
    [self.loginconview.facebookview addGestureRecognizer:FacebookWithTap];
    UITapGestureRecognizer *GoogleWithTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginWithGoogle:)];
    [self.loginconview.googleview addGestureRecognizer:GoogleWithTap];
}
- (void)loginbutton{
    [self.view endEditing:YES];
    
    self.loginconview.accountfield.text = [LHToolManager removeSpaceAndNewline:self.loginconview.accountfield.text];
    
    self.loginconview.passwordfield.text = [LHToolManager removeSpaceAndNewline:self.loginconview.passwordfield.text];
    if(!self.loginconview.passwordfield.text.length)
    {
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHEnterPassword withTarget:self]);
        
        return;
    }
    if(!self.loginconview.accountfield.text.length)
    {
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
    [LHNetworkManager postLoginByEmail:self.loginconview.accountfield.text passWord:[self.loginconview.passwordfield.text md5] handle:^(id result, NSError *error) {
        LHHideHUB(hud);
        If_Respose_Success(result, error)
        {
            NSArray *users = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
            LHUser *yquser=nil;
            if(users.count>0){
                yquser = users.firstObject;
            }
            LHUser *user = [[LHUser alloc] init];
            user.userPass = [self.loginconview.passwordfield.text md5];
            user.userId = result[LHUserId];
            user.userIsLogin = @"1";
            if(yquser){
                user.FileVersion = yquser.FileVersion;
                user.VersionName = yquser.VersionName;
            }else{
                user.FileVersion = @"0";
                user.VersionName = @"";
            }
            user.userType = self.loginconview.accountfield.text;
            user.userEmail= self.loginconview.accountfield.text;
            [self saveUseToFmdb:user];
            LHPushController *pushController = [[LHPushController alloc] init];
            [pushController sendPushId:result[LHUserId]];
            [LHToolManager.rootViewController reloadDataInViewController];
            
            [self closeLoginView];
            self.gologin.text=@"";
            self.functionselection.hidden=NO;
            
        }else{
            NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHLoginFailure withTarget:self]];
            
            LHProgressHUD(message);
        }
    }];
}
-(void)isBtngetback{
    
    RetrievepasswordViewController *viewController = [[RetrievepasswordViewController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)logoutViewController
{
    [self changeNoConnectState];
    LHLoginViewController *viewController = [[LHLoginViewController alloc] init];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}

-(void)initLoginType
{
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    
    if(fmdbData.count)
    {
        LHUser *user = [fmdbData lastObject];
        
        self.functionView.loginTypeLable.text = user.userType;
        //判断是否有邮箱，没有就去绑定
        if(user.userEmail.length<2){
            SubmitemailViewController *viewController = [[SubmitemailViewController alloc] init];
            
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            self.functionView.loginTypeLable.text = user.userEmail;
        }
        
    }
}

-(void)reloadDataInViewController
{
    //判断用户是否绑定了邮箱
    [self initLoginType];
    //获取好友请求
    [self Getfriendrequest];
    
    [LHNetworkManager postGainLockhandle:^(id result, NSError *error) {
        If_Respose_Success(result, error)
        {
            NSLog(@"%@",result);
            LHLockController *lockController = [[LHLockController alloc] init];
            
            [lockController formatLocks:result];
            
            LHPushController *pushController = [[LHPushController alloc] init];
            
            [pushController sendPushId:[LHToolManager getUserId]];
            
            self.lockNumPageControl.currentPage = 0;
            
            [self addBlockRefreshData];
            
            [self initSubViewInViewController];
            
        }Else_If_Error(result, error)
        {
            [LHToolManager logout];
            [self logoutViewController];
        }
        
    }];
    [self Getfileversion];
}
//获取好友请求
-(void)Getfriendrequest
{
    
    [LHNetworkManager postGetfriendrequest:^(id result, NSError *error) {
        If_Respose_Success(result, error)
        {
            for (NSDictionary *mainDic in result[LHInfos]) {
                FriendsObj *friendsobj = [[FriendsObj  alloc] init];
                friendsobj.email = mainDic[@"email"];
                friendsobj.name = mainDic[@"name"];
                friendsobj.phone = mainDic[@"phone"];
                friendsobj.user_id = mainDic[@"user_id"];
                [requestDictionary addObject:friendsobj];
            }
        }Else_If_Error(result, error)
        {
            
        }
        
    }];
}
//获取文件版本
-(void)Getfileversion
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {　　[LHNetworkManager postGetfileversion:^(id result, NSError *error) {
            NSString *xmlString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
            
            NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:result];
            //设置该类本身为代理类，即该类在声明时要实现NSXMLParserDelegate委托协议
            [m_parser setDelegate:self];  //设置代理为本地
            
            BOOL flag = [m_parser parse]; //开始解析
        }];
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
    
}

-(void)parserDidStartDocument:(NSXMLParser *)parser{
    //NSLog(@"解析开始！");
}
//解析起始标记 //按顺序获取键名
- (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    　//　NSLog(@"标记：%@",elementName);
    if([elementName isEqualToString:@"version"]){
        FileVersion=@"version";
    } else if ([elementName isEqualToString:@"url"]){
        VersionURL=@"url";
    }else if ([elementName isEqualToString:@"name"]){
        VersionName=@"name";
    }
    
}

//获取值
- (void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //解析文本节点
    //NSLog(@"值：%@",string);
    if([FileVersion isEqualToString:@"version"]){
        FileVersion=string;
    }else if ([VersionURL isEqualToString:@"url"]){
        VersionURL=string;
        NSArray *users = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
        LHUser *user = users.firstObject;
        if(!user.FileVersion){
            user.FileVersion = @"0";
            user.VersionName = @"";
            [self saveUseToFmdb:user];
        }
        if(![user.FileVersion isEqualToString:FileVersion]){
            [self downLoadWithUrlString:VersionURL];
        }else if(![self isFileExist:VersionName]){
            [self downLoadWithUrlString:VersionURL];
        }
    }else if([VersionName isEqualToString:@"name"]){
        VersionName=string;
    }
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
//解析结束标记
- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    // NSLog(@"结束标记：%@",elementName);
    
}
//文档结束时触发
-(void) parserDidEndDocument:(NSXMLParser *)parser{
    // NSLog(@"解析结束！");
    
}
- (void)downLoadWithUrlString:(NSString *)urlString
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
            //创建session
            NSURLSession *session = [NSURLSession sharedSession];
            
            //创建URL
            NSURL *url = [NSURL URLWithString:urlString];
            
            //创建request
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            
            //创建任务
            NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                //成功记录当前版本
                NSArray *users = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
                
                LHUser *user = users.firstObject;
                
                user.FileVersion = FileVersion;
                user.VersionName = VersionName;
                
                [LHDataManager LH_UpdataFmdbId:user withFmdbKey:LHUserFmdb Wherekey:ObjcKeyPath(user, userPass) value:user.userPass];
                //找到沙盒caches的路径
                NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                
                //找到文件路径
                NSString *file = [caches stringByAppendingPathComponent:response.suggestedFilename];
                
                //拿到文件管理器
                NSFileManager *mgr = [NSFileManager defaultManager];
                
                //执行移动操作
                [mgr moveItemAtPath:location.path toPath:file error:nil];
            }];
            
            //开始任务
            [task resume];
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
#pragma mark - 事件
-(void)isAutoOpen:(UIButton *)button
{
    button.selected = !button.selected;
    
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    LHLock *lock = OBJECT_AT_INDEX(locks, self.selectIndex);
    
    lock.lockAutoOpen = button.selected ? @"1" : @"0";
    
    [LHDataManager LH_UpdataFmdbId:lock withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(lock, lockId) value:lock.lockId];
}
-(void)intoShareViewController:(UITapGestureRecognizer *)tap
{
    if(![LHToolManager isLogin])
    {
        return;
    }
    LHLock *lock = [self currentLock];
    if(!lock){
        return;
    }
    if([lock.lockType isEqualToString:@"0"])
    {
         TJShareViewController *viewController = [[TJShareViewController alloc] init];
        viewController.selectLock = lock;
        
        [self.navigationController pushViewController:viewController animated:YES];
        
    }else{
        
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoSharePower withTarget:self]);
    }
}
-(void)closeFunctionView
{
    self.maskView.hidden = YES;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 0);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.functionView.transform = transform;
        
    }];
}
-(void)closeLoginView
{
    self.loginView.hidden = YES;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(-LHSW, 0);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.loginconview.transform = transform;
        
    }];
}
- (IBAction)openFunctionView:(id)sender {
    if(![LHToolManager isLogin])
    {
        [LHToolManager logout];
        //[self logoutViewController];
        self.loginView.hidden = NO;
        // 123
        CGAffineTransform transform = CGAffineTransformMakeTranslation(LHSW+15, 100);
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.loginconview.transform = transform;
        }];
    }else{
        [LHToolManager.rootViewController reloadDataInViewController];
    self.maskView.hidden = NO;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(LHSW, 0);
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.functionView.transform = transform;
    }];
    }
}
- (IBAction)showMenuView:(id)sender {
    if([LHToolManager isLogin])
    {
    if (self.flag) {
        [NewCommonMenuView showMenuAtPoint:CGPointMake(LHSW - 20, 76)];
        self.flag = NO;
    }else{
        [NewCommonMenuView hidden];
        self.flag = YES;
    }
    }else{
        [LHToolManager logout];
        //[self logoutViewController];进入登录界面
        
        self.loginView.hidden = NO;
        // 123
        CGAffineTransform transform = CGAffineTransformMakeTranslation(LHSW+15, 100);
        
        [UIView animateWithDuration:0.25 animations:^{
            
            self.loginconview.transform = transform;
        }];
    }
}
//退出提示框
-(void)isBtnLogout:(UITapGestureRecognizer *)tap
{
    NSString *ti=(NSString *)[LHToolManager keyPath:LHShareCancel withTarget:self];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHLogout withTarget:self] message:(NSString *)[LHToolManager keyPath:LHExitaccount withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    
    __weak typeof(alert) weakAlert = alert;
    // 添加确认按钮
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHConfirm withTarget:self] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [LHToolManager logout];
        self.gologin.text = (NSString *)[LHToolManager keyPath:LHLogin withTarget:self];
        
        self.functionselection.hidden=YES;
        
        [self closeFunctionView];
        requestDictionary= [NSMutableArray array];
        [self settingSubViewInViewController];
        
        [self useTimePaixuInViewController];
        
        [self initSubViewInViewController];
        
//        [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
//            if([LHToolManager isLogin] && status)
//            {
//                [self reloadDataInViewController];
//            }
//        }];
    }]];
    // 添加取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHShareCancel withTarget:self] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
//坐上角弹出窗的点击事件
-(void)isChoseMenuView:(NSInteger)index
{
    [NewCommonMenuView hidden];
    
    self.flag = YES;
    
    switch (index) {
        case 1:
        {
            [self intoBleLockViewController];
        }
            break;
            case 2:
        {
            JDGScanQRcodeController *viewController = [[JDGScanQRcodeController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 3:
        {
            NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
            
            if(locks.count)
            {
                LHLock *lock = [self currentLock];
                if(!lock){
                    return;
                }
                if([lock.lockType isEqualToString:@"0"])
                {
                    
                    TJShareViewController *viewController = [[TJShareViewController alloc] init];
                    
                    viewController.selectLock = lock;
                    
                    [self.navigationController pushViewController:viewController animated:YES];
                }else{
                    
                    LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoSharePower withTarget:self]);
                }
            }else{
                
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoLock withTarget:self]);
            }
        }
            break;
        default:
            break;
    }
}
-(void)intoSettingViewController:(UITapGestureRecognizer *)tap
{
    LHSettingViewController *viewController = [[LHSettingViewController alloc] init];
    
    viewController.languageDelegate = self;
    
    [self.navigationController pushViewController:viewController animated:YES];
}
-(void)showNolock:(UIButton *)button
{
    LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoLock withTarget:self]);
}
//点击打开按钮
-(void)openTheLock:(UIButton *)button
{
    LHLock *lock = [self currentLock];
    if(!lock){
        return;
    }
    //远程锁
    if ([lock.lockSpecies isEqualToString:@"3"]){
        
        return;
    }
    //声波锁
    if([lock.lockSpecies isEqualToString:@"4"]) {
    
        if(self.voicePlayer != nil)
        {
            [self.voicePlayer stopPlay];
            self.voicePlayer = nil;
             return;
        }
        
        self.voicePlayer = [[LHVoicePlayManager alloc] init];
        
        self.voicePlayer.voicePlayDelegate = self;
        [self.voicePlayer playVoice:lock.lockKey];
        return;
    }
    //连接状态
    if(self.slokState == 2)
    {
        self.bleWord = openKey;
        // 根据上面的特征self.characteristic来写入数据
        [ mTJBluetoothManager BluetoothSendData:self.bleWord];
        
        [self addCurrenLockUseTimes];
        
    }else{
        
        NSDictionary *buleToothState = (NSDictionary *)[LHToolManager keyPath:LHBuleToothState withClass:NSStringFromClass([LHLockControllerView class])];
        
        NSString *slokStateKey = nil;
        
        switch (self.slokState) {
            case 0:
            {
                slokStateKey = LHNoConnect;
            }
                break;
            case 1:
            {
                //slokStateKey = LHIsConnecting;
                     return;
            }
                break;
            case 2:
            {
               // slokStateKey = LHIsConnected;
                     return;
            }
                break;
            default:
            {
                slokStateKey = LHNoConnect;
            }
                break;
        }
        
        NSString *state = buleToothState [slokStateKey];
        
        LHProgressHUD(state);
    }
}

-(void)addCurrenLockUseTimes
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    LHLock *lock = OBJECT_AT_INDEX(locks, self.selectIndex);
    
    lock.lockUseTimes = [NSString stringWithFormat:@"%d",[lock.lockUseTimes intValue] + 1];
    
    [LHDataManager LH_UpdataFmdbId:lock withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(lock, lockId) value:lock.lockId];
}
#pragma mark - Delegate
#pragma mark - functionDelegate
-(void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [self intoBleLockViewController];
        }
            break;
     
        case 1:
        {
            LHMyLockViewController *viewController = [[LHMyLockViewController alloc] init];
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 2:
        {
            LHHistoryViewController *viewController = [[LHHistoryViewController alloc] init];
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 3:
        {
            LHNoticeViewController *viewController = [[LHNoticeViewController alloc] init];
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        case 4:
        {
            TJFriendsViewController *viewController = [[TJFriendsViewController alloc] init];
            viewController.requestDictionary= requestDictionary;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
            case 5:
        {
            JDGScanQRcodeController *viewController = [[JDGScanQRcodeController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - LHSwitchLanguageDelegate
-(void)isRefreshViewToChangeLanguage
{
    [self refreshViewInViewController];
}

#pragma mark - UITextFieldDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger *locking=self.selectIndex;
    self.selectIndex = (NSInteger)roundf(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if(ifProgramsliding){
        if(self.selectIndex==self.Targetnumber){
           ifProgramsliding=NO;
        }
        return;
    }
 
    if(locking!=self.selectIndex){
        [self modifyprevious:locking];
        self.lockNumPageControl.currentPage = self.selectIndex;
     
        //关闭当前连接
        [mTJBluetoothManager BluetoothDisconnect];
        [self changeNoConnectState];
        self.isConnectBle = NO;
        [self isConnect:0];
        [mTJBluetoothManager scanPeripehrals];
        [self changeOpenState:YES];
    }
}
//停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}
//开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
   [self stopAllAction];
}

-(void)changeNoConnectState
{
    self.slokState = 0;
    
    self.lockState = 0;
    
    [self.lockManageScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        LHLockControllerView *currenView = (LHLockControllerView *)obj;
        
        NSDictionary *buleToothState = (NSDictionary *)[LHToolManager keyPath:LHBuleToothState withClass:NSStringFromClass([LHLockControllerView class])];
        
        NSString *state = buleToothState [LHNoConnect];
        
        currenView.buleToothStateLable.text = state;
        
        
    }];
    
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
-(void)recevePushData:(NSNotification *)notice
{
    NSDictionary *pushData = (NSDictionary *)notice.object;
    
    if([pushData isKindOfClass:[NSDictionary class]] && [pushData[LHLockType] isEqualToString:@"1"])
    {
        [self reloadDataInViewController];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
#pragma mark - 锁状态改变
-(void)isConnect:(NSInteger)isConnect
{
    self.slokState = isConnect;
    
    LHLockControllerView *currenView = OBJECT_AT_INDEX(self.lockManageScrollView.subviews, self.selectIndex);
    
    NSDictionary *buleToothState = (NSDictionary *)[LHToolManager keyPath:LHBuleToothState withClass:NSStringFromClass([LHLockControllerView class])];
    
    NSString *slokStateKey = nil;
    
    switch (isConnect) {
        case 0:
        {
            slokStateKey = LHNoConnect;
        }
            break;
        case 1:
        {
            slokStateKey = LHIsConnecting;
        }
            break;
        case 2:
        {
            slokStateKey = LHIsConnected;
        }
            break;
        default:
        {
            slokStateKey = LHNoConnect;
        }
            break;
    }
    
    NSString *state = buleToothState [slokStateKey];
    
    currenView.buleToothStateLable.text = state;
}
-(void)changeOpenState:(BOOL)open
{
    LHLock *lock = [self currentLock];
    if(!lock){
        return;
    }
    //不是蓝牙锁返回
    if ([lock.lockSpecies isEqualToString:@"3"]||
        [lock.lockSpecies isEqualToString:@"4"]) {
         return;
    }
    
    self.lockState = open ? 1 : 0;
    
    LHLockControllerView *currenView = OBJECT_AT_INDEX(self.lockManageScrollView.subviews, self.selectIndex);
    
    NSDictionary *buleToothState = (NSDictionary *)[LHToolManager keyPath:LHLockState withClass:NSStringFromClass([LHLockControllerView class])];
    
    NSString *slokStateKey = LHLockOpen;
    
    NSString *state = buleToothState [slokStateKey];
    
    currenView.lockStateButton.backgroundColor = open ?LHRGBColor(83, 74, 102) : LHRGBColor(254, 92, 90);
    
    currenView.lockStateButton.enabled = !open;
    
    
}
//修改上一个锁view的显示
-(void)modifyprevious:(NSInteger)num
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    LHLock *lock;
    if(locks.count&&locks.count>=num)
    {
        LHLock *lock = OBJECT_AT_INDEX(locks, num);
        //不是蓝牙锁返回
        if ([lock.lockSpecies isEqualToString:@"3"]||
            [lock.lockSpecies isEqualToString:@"4"]) {
            return;
        }
    }else{
        return;
    }
   
    LHLockControllerView *currenView = OBJECT_AT_INDEX(self.lockManageScrollView.subviews, num);
    
    NSDictionary *buleToothState = (NSDictionary *)[LHToolManager keyPath:LHLockState withClass:NSStringFromClass([LHLockControllerView class])];
    
    NSString *slokStateKey = LHLockOpen;
    currenView.lockStateButton.backgroundColor = LHRGBColor(83, 74, 102);
    
    currenView.lockStateButton.enabled =NO;
}

#pragma mark - private
-(void)intoBleLockViewController
{
    if([LHToolManager isLogin]){
        LHBleAddLockViewController *viewController = [[LHBleAddLockViewController alloc] init];
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    
}
-(void)refreshViewInViewController
{
    [self refreshScrollViewInViewController];
    
    [self refreshMenuViewInViewController];
    
    [self.functionView refreshFunctionView];
}
-(void)refreshScrollViewInViewController
{
    for (UIView *subView in self.lockManageScrollView.subviews) {
        if([subView isKindOfClass:[LHLockControllerView class]])
        {
            LHLockControllerView *lockControlView = (LHLockControllerView *)subView;
            
            [lockControlView refreshLockControllerViewLable:self.slokState withLockState:self.lockState];
        }
    }
}
-(void)refreshMenuViewInViewController
{
    [NewCommonMenuView clearMenu];
    
    [self settingMenuViewInviewController];
}
-(void)addBlockRefreshData
{
    BOOL mark = NO;
    
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if([viewController isKindOfClass:[LHMyLockViewController class]])
        {
            mark = YES;
            break;
        }
    }
    
    if(mark == YES)
    {
        self.refreshBlock();
    }
}
//自动开锁
-(void)autoBleOpen
{
    LHLock *lock = [self currentLock];
    if(!lock){
        return;
    }
    LHLockControllerView *currenView = [self currentControllerView];
    
    if(lock && currenView && [lock.lockAutoOpen boolValue] && !self.isNoAutoOpen)
    {
        self.isNoAutoOpen = YES;
        self.bleWord = openKey;
        //NSLog(@"传输的数据:%@\n",self.bleWord);
         [ mTJBluetoothManager BluetoothSendData:self.bleWord];
    }
}
//开门成功的记录
-(void)feedBackOpenToInternet
{
    if(![LHToolManager isLogin]){
        return;
    }
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    LHLock *lock = OBJECT_AT_INDEX(locks, self.selectIndex);
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            [LHNetworkManager postOpenHistory:lock.lockId type:@"1" handle:^(id result, NSError *error) {
                
            }];
        }
    }];
    
    for (LHLock *key in locks) {
        
        if(![key isEqual:lock] && [key.lockVipUse isEqualToString:@"1"])
        {
            key.lockVipUse  = @"0";
            
            [LHDataManager LH_UpdataFmdbId:key withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(key, lockId) value:key.lockId];
        }
    }
    
    if([lock.lockVipUse isEqualToString:@"0"])
    {
        lock.lockVipUse = @"1";
        
        [LHDataManager LH_UpdataFmdbId:lock withFmdbKey:LHLockFmdb Wherekey:ObjcKeyPath(lock, lockId) value:lock.lockId];
    }
}


//返回当前锁
-(LHLock *)currentLock
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(locks.count)
    {
        LHLock *lock = OBJECT_AT_INDEX(locks, self.selectIndex);
        
        return lock;
        
    }else{
       
        [self DisattivaScansioneBluetooth];
        return nil;
    }
}
//返回当前锁的滑动View
-(LHLockControllerView *)currentControllerView
{
    LHLockControllerView *currenView = OBJECT_AT_INDEX(self.lockManageScrollView.subviews, self.selectIndex);
    
    return currenView;
}
//进入注册页面
-(void)goregistered:(UITapGestureRecognizer *)tap {
    LHEmailLoginViewController *viewController = [[LHEmailLoginViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


//微信登录
-(void)loginWithWechat:(UITapGestureRecognizer *)tap {
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            [LHToolManager setLoginType:@"3"];
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
-(void)loginWithTwitter:(UITapGestureRecognizer *)tap{
    
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
     [LHToolManager setLoginType:@"4"];
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
-(void)loginWithFacebook:(UITapGestureRecognizer *)tap{
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        
        if(status)
        {
             [LHToolManager setLoginType:@"1"];
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            LHShowHUB(hud);
            self.hud = hud;
            [login logInWithReadPermissions: @[@"public_profile"]fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                if (error) {
                    LHHideHUB(hud);
                    LHProgressHUD((NSString *)[LHToolManager keyPath:   LHFailureAuthorize withTarget:self]);
                } else if (result.isCancelled) {
                    LHHideHUB(hud);
                    LHProgressHUD((NSString *)[LHToolManager keyPath:LHCancel withTarget:self]);
                }else{
                    [self faceBookAuthorizationSuccessByToken:result];
                }
            }];
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
//Google登录
-(void)loginWithGoogle:(UITapGestureRecognizer *)tap{
     [LHToolManager setLoginType:@"8"];
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
    
    [LHNetworkManager postLogin:type userIdentity:userId handle:^(id result, NSError *error) {
        LHHideHUB(self.hud);
        If_Respose_Success(result, error)
        {
            [self DisattivaScansioneBluetooth];
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
                [self closeLoginView];
                self.gologin.text=@"";
                self.functionselection.hidden=NO;
                
                [LHToolManager.rootViewController reloadDataInViewController];
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
//打开蓝牙
-(void)openBlueToothToSetting
{
    UIAlertController *alet = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHPrompt withTarget:self] message:(NSString *)[LHToolManager keyPath:LHTurnBluetooth withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alet dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    [alet addAction:yesAction];
    
    [self presentViewController:alet animated:YES completion:nil];
}
//提示或许不是拥有者
-(void)showNotOpen:(NSData *)ReturnsData
{
    if(![LHToolManager isLogin]){
        
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHNotOpen withTarget:self]);
        return;
    }
    
    if(ifshowtips){
        ifshowtips=NO;
        if(ifSuccessnews){
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHCommandError withTarget:self]);
        }else{
            if(ifRecorderror){
                ifRecorderror=NO;
                if(![self setselectIndex]){
                    LHProgressHUD((NSString *)[LHToolManager keyPath:LHNotOpen withTarget:self]);
                };
               
            }else{
                ifRecorderror=YES;
                LHLock *lock = [self currentLock];
                if(!lock){
                    return;
                }
                NSString *lockkey=@"";
                if([lock.lockIsJihuo isEqualToString:@"0"]){
                    
                   lockkey=lock.lockKey;
                }else{
                   lockkey=@"0810151308107781";
                }
                BOOL isTures = [LHBLEDataManager bleFeedbackIsTure:ReturnsData withKey:lockkey];
                self.bleWord =openKey;
                [mTJBluetoothManager BluetoothSendData:self.bleWord];
            }
        }
    }else{
        ifshowtips=YES;
        LHLockControllerView *currenView = [self currentControllerView];
        if(currenView)
        {
            LHLock *lock = [self currentLock];
            if(!lock){
                return;
            }
            self.bleWord = [LHBLEDataManager gainLockIdKey:lock.lockKey];
            NSLog(@"key:%@\n",lock.lockKey);
            //获取设备ID，10指令
             [mTJBluetoothManager BluetoothSendData:self.bleWord];
        }
    }
}
//设置当前序号
-(BOOL)setselectIndex{
    
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    for (LHLock *key in locks) {
        if([key.lockMac isEqualToString:self.cwguyhiojString])
        {
            NSInteger selectIndexs
            = [locks indexOfObject:key];
            self.selectIndex=selectIndexs;
                ifProgramsliding=YES;
                [self.lockManageScrollView setContentOffset:CGPointMake(LHSW*self.selectIndex, 0) animated:YES];
                self.lockNumPageControl.currentPage = self.selectIndex;
                 [self isConnect:2];
                return YES;
            
            
        }
    }
    [mTJBluetoothManager BluetoothDisconnect];
    self.selectIndex=0;
    [self.lockManageScrollView setContentOffset:CGPointMake(LHSW*self.selectIndex, 0) animated:YES];
    self.lockNumPageControl.currentPage = self.selectIndex;
    [self isConnect:0];
    [self changeNoConnectState];
    self.isConnectBle = NO;
    [self isConnect:0];
    [self changeOpenState:YES];
    [mTJBluetoothManager scanPeripehrals];
    return NO;
}

- (void)playOnOtherMusic:(NSString *)mp3name{
    //初始化文件地址
    //创建播放器并播放
   dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *filePath = [[NSBundle mainBundle]pathForResource:mp3name ofType:@"mp3"];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSError *audioPlayerError = nil;
        self.audioPlayer = [[AVAudioPlayer alloc]initWithData:fileData error:&audioPlayerError];
        if (self.audioPlayer != nil) {
            self.audioPlayer.delegate = self;
            if ([self.audioPlayer prepareToPlay] && [self.audioPlayer play]) {
                NSLog(@"Successfully started playing.");
                self.isConnectBle = YES;
            }else{
                NSLog(@"Failed to play the audio file.");
                self.audioPlayer = nil;
            }
        }else{
            NSLog(@"Could not instantiate the audio player.");
        }
    });
}
#pragma mark - LHVoicePlayDelegate
-(void)playBackResult:(int)result
{
    [self stopAllAction];
    
    if(self.voicePlayer)
    {
        [self.voicePlayer stopPlay];
    }
    
    NSString *notice = nil;
    
    switch (result) {
        case 0:
        {
            notice = @"指令错误";
        }
            break;
        case 1:
        {
            notice = @"开锁成功";
        }
            break;
        case 2:
        {
            notice = @"时间错误";
        }
            break;
        case 3:
        {
            notice = @"电池电量低";
        }
            break;
            
        default:
        {
            notice = @"口令错误";
        }
            break;
    }
    
    LHProgressHUD_Bottom(notice);
}
-(void)stopAllAction
{
    if(self.voicePlayer)
    {
        [self.voicePlayer stopPlay];
        
        self.voicePlayer = nil;
    }
}
-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    ifshowtips=NO;
    ifSuccessnews=NO;
    ifRecorderror=NO;
    ifProgramsliding=NO;
    ifGetId=NO;
    requestDictionary= [NSMutableArray array];
    [self reconnectBluetooth];
  
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [mTJBluetoothManager BluetoothDisconnect];
    [self changeNoConnectState];
    [self modifyprevious:self.selectIndex];
    self.isConnectBle = NO;
    ifshowtips=NO;
    ifSuccessnews=NO;
    ifRecorderror=NO;
    ifProgramsliding=NO;
    ifGetId=NO;
    [self isConnect:0];
    [self changeOpenState:YES];
    [self closeFunctionView];
    [self closeLoginView];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
