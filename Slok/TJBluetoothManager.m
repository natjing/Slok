//
//  TJBluetoothManager.m
//  Slok
//
//  Created by user on 2018/5/15.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "TJBluetoothManager.h"
#import "FriendsObj.h"
//服务UUID
#define RX_SERVICE_UUID @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
//读数据
#define RX_CHAR_UUID @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
//写数据
#define TX_CHAR_UUID @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define openKey [LHBLEDataManager gainOpenLockKey]
@interface TJBluetoothManager();
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *connectedPeripheral;
@property (nonatomic,strong)CBCharacteristic *readCharacteristic;
@property (nonatomic,strong)CBCharacteristic *writeCharacteristic;
@property (nonatomic,assign) NSUInteger *Priority;//1为主界面，2为蓝牙加锁，3为设置快击密码
@property (nonatomic,assign) NSUInteger *selectIndex;//当前连接的锁在首页的排序，-2为蓝牙加锁，-1为设置快击密码
@property (nonatomic,strong)NSString *cwguyhiojString;//当前连接或者扫描到的蓝牙MAC地址
@property (nonatomic,assign)NSUInteger *status;//蓝牙连接状态、0未连接，1已连接，2发送数据，3接收数据

@property (nonatomic,assign) NSUInteger *Ricollegare;//重新连接的次数
@property (nonatomic,copy) BluetoothScanReturnedDataBlock bluetoothscanreturneddataBlock;
@property (nonatomic,copy) ReturnBluetoothStatusBlock returnbluetoothstatusBlock;

@property (nonatomic,copy) BluetoothReturnsDataBlock bluetoothreturnsdataBlock;


@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)NSInteger timeCount;

@property(nonatomic,strong)NSTimer *Connectiontimer;
@end

@implementation TJBluetoothManager{
    
}
//单例生成
+(TJBluetoothManager *)shareTJBluetoothManager{
    static TJBluetoothManager *shareInstance_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance_ = [[self alloc] init];
    });
    return shareInstance_;
}
//初始化中心设备CBCentraManager(管理者)
-(id) init {
    self = [super init];
    if (self) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        self.status=0;
        self.selectIndex=0;
        self.Ricollegare=0;
   }
    return self;
}
//设置使用单例的界面，1为主界面，2为蓝牙加锁，3为设置快击密码
-(void)SetViewController:(NSUInteger *)priority{
    @synchronized(self) {
        
        NSLog(@"----------NSUInteger:%zd",priority);
        
        [self BluetoothDisconnect];
        self.connectedPeripheral=nil;
        self.cwguyhiojString=@"";
        [self stopScan];
        self.cwguyhiojString=@"";
        self.Priority=priority;
        self.Ricollegare=0;
        if(self.Priority==2){
            self.selectIndex =-2;
        }else if (self.Priority==3){
            self.selectIndex =-3;
        }
    }
}
//返回蓝牙对象
-(CBCentralManager *)getcentralManager{
    return self.centralManager;
}
//指定连接某一个蓝牙
-(void)ConnectBluetooth:(CBPeripheral *)peripheral{
    if(self.centralManager&&peripheral){
        [self stopScan];
        self.connectedPeripheral = peripheral;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
//关闭蓝牙扫描
-(void)stopScan{
    //self.cwguyhiojString=@"";
    [self.centralManager stopScan];
}
//断开当前连接
-(void)BluetoothDisconnect{
    //self.cwguyhiojString=@"";
    if (self.centralManager&&self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    }
}
//蓝牙发送数据
-(void)BluetoothSendData:(NSString *)bleWord{
    
    if(self.connectedPeripheral&&self.writeCharacteristic){
        self.timeCount = 5;
        self.status=2;
        [self.connectedPeripheral writeValue:[self sendHex:bleWord] forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}


//设置读取到Characteristics描述的值的block
- (void)setBluetoothScanReturnedDataBlock:(void (^)(NSUInteger *selectIndex,NSMutableDictionary *peripheralDic))block {
    self.bluetoothscanreturneddataBlock=block;
}
//返回蓝牙连接状态、0未连接，1已连接，2通讯成功
-(void)setReturnBluetoothStatusBlock:(void (^)(NSUInteger *status,NSString *mac))block {
    self.returnbluetoothstatusBlock=block;
    
}
//返回蓝牙返回的数据status为序号，ReturnsData为数据
-(void)setBluetoothReturnsDataBlock:(void (^)(NSUInteger *status,NSData *ReturnsData,NSString *mac))block{
    self.bluetoothreturnsdataBlock=block;
}
#pragma mark - 蓝牙
#pragma mark - ble方法
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // 根据SERVICE_UUID来扫描外设，如果不设置SERVICE_UUID，则扫描所有蓝牙设备
    //判断蓝牙是否打开
    if(self.centralManager.state == CBCentralManagerStatePoweredOn){
        [self scanPeripehrals];
    }
}

//前台开启蓝牙扫描
- (void)scanPeripehrals
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn){
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:RX_SERVICE_UUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
    }
}
//后台开启连接
- (void)htconnectionPeripehrals
{
    if(self.centralManager!=nil&&self.connectedPeripheral!=nil){
        if(self.centralManager.state == CBCentralManagerStatePoweredOn){
            //软件在前台 断开连接可以设置重新扫描
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
                [self scanPeripehrals];
                [self.centralManager connectPeripheral:self.connectedPeripheral options:nil];
            }else{
                //软件在后台 断开连接可以设置重新连接
                [self scanPeripehrals];
                [self.centralManager connectPeripheral:self.connectedPeripheral options:nil];
            }
        }
    }
}

//不加UUID蓝牙扫描
- (void)NotUUIDscanPeripehrals
{
    if(self.centralManager.state == CBCentralManagerStatePoweredOn){
        
        NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
        
        [self.centralManager scanForPeripheralsWithServices:nil options:scanForPeripheralsWithOptions];
    }
}
/** 发现符合要求的外设，回调  连接*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSString *macIp=[LHToolManager gainMacToData:advertisementData[kCBAdvDataManufacturerData]];
    if(self.Priority!=1&&self.Priority!=4){
        if(macIp==nil){
            return;
        }
        
        if([self.cwguyhiojString isEqualToString:macIp]){
            return;
        }
        
    }
    NSString *blename=  peripheral.name;
    
    if ([advertisementData objectForKey:@"kCBAdvDataLocalName"]) {
        blename = [NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
    }else if(!([peripheral.name isEqualToString:@""] || peripheral.name == nil)){
        blename = peripheral.name;
    }else{
        blename = [peripheral.identifier UUIDString];
    }
    if(self.Priority==4){
        if([blename isEqualToString:@"DfuTarg"]){
            self.cwguyhiojString=macIp;
            self.connectedPeripheral = peripheral;
            
            [self.centralManager connectPeripheral:peripheral options:nil];
            
           //[self.centralManager stopScan];
        }
        return;
    }
    
    self.cwguyhiojString=macIp;
    //试玩模式
    if(![LHToolManager isLogin])
    {
        
        NSLog(@"blename%@",blename);
        NSLog(@"macIp%@",macIp);
        NSMutableArray *mainData = [NSMutableArray array];
        NSDictionary *dic1 = [NSDictionary dictionary];
        dic1 = @{
                 @"jihuo":@"1",
                 @"key":@"0810151308107781",
                 @"lock_id":@"282",
                 @"lock_mac":macIp,
                 @"lock_name":blename,
                 @"lock_num":@"00001709b9b82625",
                 @"type":@"0",
                 @"user_id":@"104"
                 };
        [mainData addObject:dic1];
        self.selectIndex = -1;
        self.bluetoothscanreturneddataBlock(self.selectIndex,
                                            mainData);
        // 连接外设
        self.connectedPeripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
        if(!self.Connectiontimer){
            self.Connectiontimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
        }
        self.Ricollegare=0;
        return;
    }
    //蓝牙加锁  //设置k'j
    if(self.Priority==2||self.Priority==3){
        if(self.Priority==2){
            self.selectIndex =-2;
        }else if (self.Priority==3){
            self.selectIndex =-3;
        }
        
        NSString *blename=  [advertisementData objectForKey:kCBAdvDataLocalName];
        NSMutableDictionary *peripheralDic = [[NSMutableDictionary alloc] init];
        [peripheralDic setObject:peripheral forKey:LHPeripheralKey];
        [peripheralDic setObject:self.cwguyhiojString forKey:kCBAdvDataManufacturerData];
        [peripheralDic setObject:blename forKey:kCBAdvDataLocalName];
        if(self.Priority==3){
            self.cwguyhiojString=@"";
        }
        
        //        if(self.Priority!=2){
        //            self.connectedPeripheral = peripheral;
        //            if(!self.Connectiontimer){
        //                self.Connectiontimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
        //            }
        //        }
        self.bluetoothscanreturneddataBlock(self.selectIndex, peripheralDic);
        self.Ricollegare=0;
        return;
    }
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    if(!self.centralManager)
    {
        return;
        
    }else if(locks.count>0){
        
        for (LHLock *key in locks) {
            if([key.lockMac isEqualToString:macIp])
            {
                [self stopScan];
                self.selectIndex = [locks indexOfObject:key];
                // 连接外设
                self.connectedPeripheral = peripheral;
                if(self.status==0){
                    [self.centralManager connectPeripheral:peripheral options:nil];
                }
                
                self.bluetoothscanreturneddataBlock(self.selectIndex,nil);
                if(!self.Connectiontimer){
                    self.Connectiontimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(reconnect) userInfo:nil repeats:YES];
                }
                self.Ricollegare=0;
                break;
            }
        }
    }
}
/** 连接成功 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    if(self.Priority==4){
        self.connectedPeripheral = peripheral;
        self.returnbluetoothstatusBlock(self.Priority,self.cwguyhiojString);
        // 可以停止扫描
        [self.centralManager stopScan];
        return;
    }
    if(!self.timer){
        self.timeCount = 3;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(codeTime:) userInfo:nil repeats:YES];
    }
    if(self.Connectiontimer){
        [self.Connectiontimer invalidate];
        self.Connectiontimer = nil;
    }
    if(self.Priority==1){
        NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
        for (LHLock *key in locks) {
            if([key.lockMac isEqualToString:self.cwguyhiojString])
            {
                self.selectIndex = [locks indexOfObject:key];
                
                break;
            }
        }
    }
    // 可以停止扫描
    [self.centralManager stopScan];
    // 设置代理
    printf("已连接上设备：");
    printf("name = %s\n",[peripheral.name UTF8String]);
    self.connectedPeripheral = peripheral;
    // 设置代理
    self.connectedPeripheral.delegate = self;
    // 根据UUID来寻找服务
    [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:RX_SERVICE_UUID]]];
    
}

/** 连接失败的回调 */
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disConnect%@",peripheral.name);
    if(self.Priority==4){
        return;
    }
    if(self.Priority!=1){
        self.cwguyhiojString=@"";
    }
    self.status=0;
    self.returnbluetoothstatusBlock(self.status,self.cwguyhiojString);
    [self scanPeripehrals];
    [self.centralManager connectPeripheral:peripheral options:nil];
}
/** 断开连接 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    NSLog(@"断开连接");
    if(self.Priority==4){
        return;
    }
    if(self.Priority!=1){
        self.cwguyhiojString=@"";
    }
    self.status=0;
    self.selectIndex=0;
    self.returnbluetoothstatusBlock(self.status,
                                    self.cwguyhiojString);
    //软件在前台 断开连接可以设置重新扫描
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        [self scanPeripehrals];
        
        //[self.centralManager connectPeripheral:peripheral options:nil];
    }else{
        [self scanPeripehrals];
        //软件在后台 断开连接可以设置重新连接
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

#pragma mark -
#pragma mark - CBPeripheralDelegate

/** 发现服务 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for(CBService *service in peripheral.services){
        // [weakSelf discoverCharacteristic:service];
        // 根据UUID寻找服务中的特征
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/** 发现特征回调 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    CBUUID *readUUID = [CBUUID UUIDWithString:TX_CHAR_UUID];
    
    CBUUID *writerUUID = [CBUUID UUIDWithString:RX_CHAR_UUID];
    // 遍历出所需要的特征
    for (CBCharacteristic *characteristic in service.characteristics){
        
        // 从外设开发人员那里拿到不同特征的UUID，不同特征做不同事情，比如有读取数据的特征，也有写入数据的特征
        if([characteristic.UUID isEqual:readUUID])
        {
            //写入数据的时候需要用到这个特征
            self.readCharacteristic = characteristic;
            //直接读取这个特征数据，会调用didUpdateValueForCharacteristic
            [peripheral readValueForCharacteristic:self.readCharacteristic];
            //订阅通知
            [peripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
        }else if([characteristic.UUID isEqual:writerUUID])
        {
            self.writeCharacteristic = characteristic;
        }
    }
    //获取设备ID，10指令
    if(self.readCharacteristic&&self.writeCharacteristic){
        self.status=1;
        self.timeCount = 3;
        self.returnbluetoothstatusBlock(self.status,
                                        self.cwguyhiojString);
    }
}

/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    //    if (error) {
    //        NSLog(@"订阅失败");
    //        NSLog(@"%@",error);
    //    }
    //    if (characteristic.isNotifying) {
    //        NSLog(@"订阅成功");
    //    } else {
    //        NSLog(@"取消订阅");
    //    }
}

/** 接收到数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(characteristic.value.length != 19){
        return;
    }
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    self.status=3;
    self.timeCount = 3;
    self.returnbluetoothstatusBlock(self.status,
                                    self.cwguyhiojString);
    self.bluetoothreturnsdataBlock(self.selectIndex,
                                   characteristic.value,self.cwguyhiojString);
    
}

/** 写入数据回调 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error {
    //NSLog(@"写入成功");
}
-(CBCentralManager *)ReturnCBCentralManager
{
    return self.centralManager;
}

-(CBPeripheral *)ReturnCBPeripheral
{
    return self.connectedPeripheral;
}


-(void)codeTime:(NSTimer *)timer
{
    if(self.status==1||self.status==2){
        --self.timeCount;
        if(self.timeCount >= 0 && [self.timer isValid])
        {
            [self BluetoothSendData:[LHBLEDataManager gainLockIdKey:@"0810151308107781"]];
            //[self.timer invalidate];
        }else if(self.timer){
            [self.timer invalidate];
            self.timer = nil;
            [self BluetoothDisconnect];
            self.status=0;
            
        }
    }
}

-(void)reconnect
{
    if(self.Priority!=2){
        if(self.Ricollegare<=3){
            NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
            if(self.connectedPeripheral&&locks.count){
                [self ConnectBluetooth:self.connectedPeripheral];
            }
            self.Ricollegare++;
        }else if(self.Connectiontimer){
            [self.Connectiontimer invalidate];
            self.Connectiontimer = nil;
            [self BluetoothDisconnect];
            self.Ricollegare=0;
            
        }
    }
}
// 发送数据
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
@end
