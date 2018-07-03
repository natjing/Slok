//
//  LHBlueToothManager.m
//  Slok
//
//  Created by LiuHao on 2017/6/26.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHBlueToothManager.h"
#import "LHBleKeyPath.h"
@interface LHBlueToothManager ()
{
    int _hardNum[4];
    
    int _autoNum[4];
    
    int _keyNum[16];
    
    int _encryNum[8];
    
    int _passKey[8];
}
@end
@implementation LHBlueToothManager
+ (instancetype)shareInstence
{
    static LHBlueToothManager *_manager = nil;
    
    if (_manager == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [[LHBlueToothManager alloc] init];
        });
    }
    
    return _manager;
}
//返回数据的解析
- (BOOL)bleFeedbackIsTure:(NSData *)data withKey:(NSString *)passKey
{
    if(data.length <= 5)
    {
        return NO;
    }
    
    Byte *oByte = (Byte *)[data bytes];
    
    NSUInteger byteLength = data.length;
    
    if(data.length == 19)
    {
        [self gainHardNumToData:data];
        
        [self gainLockId:data];
        
        [self gainAutoNum];
        
        [self EncryptionKey:passKey];
        
        [self gainEncryptionNum];
        
        [self gainCurrenWordType:oByte];
    }
    
    if(oByte[0] == 0x55 && oByte[byteLength - 1] == 0xAA && oByte[2] < 0xC0 )
    {
        uint8_t sum = 0x00;
        
        for (int i = 0; i < byteLength - 2; ++i) {
            
            sum = sum + oByte[i];
        }
        
        if (sum == oByte[byteLength - 2]) {
            
            if(self.bleBlock)
            {
                self.bleBlock(oByte[byteLength - 3]);
            }
            
            return YES;
            
        }else{
            return NO;
        }
        
        
    }else{
        
        return NO;
    }
}
//@"0810151308107781"
- (BOOL)isOpenFeedback:(NSData *)data
{
    if(data.length <= 5)
    {
        return NO;
    }
    
    Byte *oByte = (Byte *)[data bytes];
    
    NSUInteger byteLength = data.length;
    
    if(oByte[byteLength - 4] == 0x02)
    {
        return YES;
        
    }else{
        
        return NO;
    }
}
/*
 1:写ID
 2:开锁
 3:落锁
 4:更新密钥
 */
#pragma mark - 获取当前类型
-(void)gainCurrenWordType:(Byte *)oByte
{
    switch (oByte[2] & 0x3f) {
        case 0x01:
        {
            self.feedBackType = 1;
            NSLog(@"写ID");
        }
            break;
        case 0x31:
        {
            self.feedBackType = 2;
            NSLog(@"开锁");
        }
            break;
        case 0x32:
        {
            self.feedBackType = 3;
            NSLog(@"落锁");
        }
            break;
        case 0x35:
        {
            self.feedBackType = 4;
            NSLog(@"更新密钥");
        }
            break;
        case 0x39:
        {
            self.feedBackType = 5;
            NSLog(@"按键开锁");
        }
            break;
        case 0x34:
        {
            self.feedBackType = 6;
            NSLog(@"重置锁");
        }
            break;
        case 0x2e:
        {
            self.feedBackType = 1;
            NSLog(@"读温度");
        }
             break;
        default:
        {
            self.feedBackType = 0;
            NSLog(@"口令有误");
        }
            break;
    }
}
-(void)gainHardNumToData:(NSData *)data
{
    Byte *oByte = (Byte *)[data bytes];
    
    if(data.length == 19)
    {
        for (int n = 0; n < 4; ++n) {
            
            _hardNum[n] = oByte[11 + n];
            
        }
    }
}
-(void)gainLockId:(NSData *)data
{
    NSMutableString *lockId = [NSMutableString string];
    
    Byte *oByte = (Byte *)[data bytes];
    
    if(data.length == 19)
    {
        for (int n = 0; n < 8; ++n) {
            
            [lockId appendFormat:@"%02x",oByte[3 + n]];
            
        }
    }
    
    self.lockId = [NSString stringWithString:lockId];
}
-(void)gainAutoNum
{
    for (int n = 0; n < 4; ++n) {
        
        _autoNum[n] = arc4random() % 255;
        
    }
}
//获取锁ID
-(NSString *)gainLockIdKey:(NSString *)key
{
    int cmd[19] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0e;
    
    cmd[2] = 0x01;
    
    int data[14] = {};
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    
    NSUInteger unitFlags =  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    
    NSData *keyData = [self sendHex:key];
    
    Byte *oByte = (Byte *)[keyData bytes];
    
    [self passKey:oByte];
    
    int year=(int)[dateComponent year];
    if(year<2000){
        year=2001;
    }
    data[0]=year-2000;
    
    int mon=(int)[dateComponent month];
    data[1]=mon;
   
    int day=(int)[dateComponent day];
    data[2]=day;
  
    int hour = (int) [dateComponent hour];
    data[3]=hour;
  
    int minute = (int) [dateComponent minute];
    data[4]=minute;
 
    int second = (int) [dateComponent second];
    data[5]=second;
    for (int n = 0; n < 14; ++n) {
        
        if(n < 6)
        {
 

        }else{
        
            data[n] = _passKey[n - 6];
            
    }
    }
    
    for (int n = 0; n < 14; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[17] = sum % (16 * 16);
    
    cmd[18] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
        
    }
    return keyString;
}

-(NSString *)resetLockIdKey:(NSString *)key
{
    
    int cmd[19] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0e;
    
    cmd[2] = 0x01;
    
    int data[14] = {};
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags =  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSData *keyData = [self sendHex:key];
    Byte *oByte = (Byte *)[keyData bytes];
    //[self passKey:oByte];
    
    int year=(int)[dateComponent year];
    if(year<2000){
        year=2001;
    }
    data[0]=year-2000;
    
    int mon=(int)[dateComponent month];
    data[1]=mon;
    
    int day=(int)[dateComponent day];
    data[2]=day;
    
    int hour = (int) [dateComponent hour];
    data[3]=hour;
    
    int minute = (int) [dateComponent minute];
    data[4]=minute;
    
    int second = (int) [dateComponent second];
    data[5]=second;
    for (int n = 0; n < 14; ++n) {
        if(n < 6)
        {
            
        }else{
            data[n] = oByte[n - 6];
        }
    }
    
    for (int n = 0; n < 14; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[17] = sum % (16 * 16);
    
    cmd[18] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
        
    }
    return keyString;
}
-(void)passKey:(Byte *)oByte
{
    if(!oByte){
        return;
    }
    uint8_t  v[8];
    uint8_t  k[16];
    
    for (int i = 0; i < 8; ++i) {
        
        v[i] = oByte[i];
        
    }
    
    NSData *keyData = [self sendHex:@"A1B2C3D4E5F613243546587A8B9CADBC"];
    
    Byte *kByte = (Byte *)[keyData bytes];
    
    for (int i = 0; i < 16; ++i) {
        
        k[i] = kByte[i];
    }
    
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
        
        _passKey[i] = v[i];
        
    }
}
//更新锁ID
-(NSString *)ResetLockKey
{
    int cmd[18] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0d;
    
    cmd[2] = 0x34;
    
    int data[13] = {};
    
    for (int n = 0; n < 13; ++ n) {
        
        if(n < 8)
        {
            data[n] = _encryNum[n];
            
        }else if (n == 8)
        {
            data[n] = 0x00;
            
        }else{
            
            data[n] = _autoNum[n - 9];
        }
        
    }
    
    for (int n = 0; n < 13; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[16] = sum % (16 * 16);
    
    cmd[17] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
    }
    
    return keyString;
}
//设置快击密码
-(NSString *)gainTouchOpenKey:(NSString *)key
{
    if(key.length < 3)
    {
        return nil;
    }
    
    int cmd[18] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0d;
    
    cmd[2] = 0x39;
    
    int data[13] = {};
    
    for (int i = 0; i < key.length && i < 4; ++i) {
        if(i == 3)
        {
            _autoNum[i] = 0;
            
        }else{
            
            _autoNum[i] = [key characterAtIndex:i] - 48;
            
        }
    }
    
    [self gainEncryptionNum];
    
    for (int n = 0; n < 13; ++ n) {
        
        if(n < 8)
        {
            data[n] = _encryNum[n];
            
        }else if (n == 8)
        {
            data[n] = 0x00;
            
        }else{
            
            data[n] = _autoNum[n - 9];
        }
        
    }
    
    for (int n = 0; n < 13; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[16] = sum % (16 * 16);
    
    cmd[17] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
    }
    
    return keyString;
}

-(NSString *)gainOpenLockKey
{
    int cmd[18] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0d;
    
    cmd[2] = 0x31;
    
    int data[13] = {};
    
    for (int n = 0; n < 13; ++ n) {
        
        if(n < 8)
        {
            data[n] = _encryNum[n];
            
        }else if (n == 8)
        {
            data[n] = 0x00;
            
        }else{
            
            data[n] = _autoNum[n - 9];
        }
        
    }
    
    for (int n = 0; n < 13; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[16] = sum % (16 * 16);
    
    cmd[17] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
    }
    
    return keyString;
}

-(NSString *)gainCloseLockKey
{
    int cmd[18] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0d;
    
    cmd[2] = 0x32;
    
    int data[13] = {};
    
    for (int n = 0; n < 13; ++ n) {
        
        if(n < 8)
        {
            data[n] = _encryNum[n];
            
        }else if (n == 8)
        {
            data[n] = 0x00;
            
        }else{
            
            data[n] = _autoNum[n - 9];
        }
        
    }
    
    for (int n = 0; n < 13; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[16] = sum % (16 * 16);
    
    cmd[17] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
    }
    
    return keyString;
}

-(NSString *)gainUpdataPassKey
{
    int cmd[18] = {};
    
    cmd[0] = 0x55;
    
    cmd[1] = 0x0d;
    
    cmd[2] = 0x35;
    
    int data[13] = {};
    
    for (int n = 0; n < 13; ++ n) {
        
        if(n < 8)
        {
            data[n] = _encryNum[n];
            
        }else if (n == 8)
        {
            data[n] = 0x00;
            
        }else{
            
            data[n] = _autoNum[n - 9];
        }
        
    }
    
    for (int n = 0; n < 13; ++ n) {
        
        cmd[3 + n] = data[n];
        
    }
    
    int sum = 0;
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        sum = sum + cmd[i];
    }
    
    cmd[16] = sum % (16 * 16);
    
    cmd[17] = 0xaa;
    
    NSMutableString *keyString = [NSMutableString string];
    
    for (int i = 0; i < sizeof(cmd) / sizeof(cmd[0]); ++ i) {
        
        [keyString appendFormat:@"%02x",cmd[i]];
    }
    
    return keyString;
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

-(void)EncryptionKey:(NSString *)passKey
{
    NSData *keyData = [self sendHex:passKey];
    
    Byte *oByte = (Byte *)[keyData bytes];
    
    for (int n = 0; n < 16; ++n) {
        
        if(n < 8)
        {
           _keyNum[n] = oByte[n];
            
        }else{
            
           _keyNum[n] = 255 - oByte[n - 8];
        }
    }
}

-(void)gainEncryptionNum
{
    int autoSum[8] = {};
    
    for (int n = 0; n < 8; ++ n) {
        if(n < 4)
        {
            autoSum[n] = _hardNum[n];
            
        }else{
            
            autoSum[n] = _autoNum[n - 4];
        }
    }
    uint8_t  v[8];
    uint8_t  k[16];
    
    for (int i = 0; i < 8; ++i) {
        
        v[i] = autoSum[i];
        
    }
    
    for (int i = 0; i < 16; ++i) {
        
        k[i] = _keyNum[i];
        
    }
    
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
        
        _encryNum[i] = v[i];
        
    }
}



@end
