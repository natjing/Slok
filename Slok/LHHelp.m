//
//  LHHelp.m
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/11.
//  Copyright © 2017年 supude. All rights reserved.
//

#import "LHHelp.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LHLockController.h"
@implementation LHHelp
+ (instancetype)shareInstence
{
    static LHHelp *_manager = nil;
    
    if (_manager == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [[LHHelp alloc] init];
        });
    }
    
    return _manager;
}

- (NSArray *)checkNSArrayWithChangeUseful:(NSArray *)checkArray
{
    if([checkArray isKindOfClass:[NSArray class]])
    {
        
        NSMutableArray *usefulArr = [NSMutableArray arrayWithArray:checkArray];
        
        [usefulArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if(ISNULL(obj) || ISNil(obj))
            {
                [usefulArr replaceObjectAtIndex:idx withObject:@""];
                
            }else if([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSValue class]])
            {
                [usefulArr replaceObjectAtIndex:idx withObject:[NSString stringWithFormat:@"%@",obj]];
                
            }else if([obj isKindOfClass:[NSDictionary class]])
            {
                [usefulArr replaceObjectAtIndex:idx withObject:[self checkNSDictinaryWithChangeUseful:obj]];
                
            }else if([obj isKindOfClass:[NSArray class]])
            {
                [usefulArr replaceObjectAtIndex:idx withObject:[self checkNSArrayWithChangeUseful:obj]];
            }
            
        }];
        
        return [NSArray arrayWithArray:usefulArr];
    }
    
    return checkArray;
}
- (NSDictionary *)checkNSDictinaryWithChangeUseful:(NSDictionary *)checkDictioary
{
    if([checkDictioary isKindOfClass:[NSDictionary class]])
    {
        
        NSMutableDictionary *usefulDic = [NSMutableDictionary dictionaryWithDictionary:checkDictioary];
        
        [usefulDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if(ISNULL(obj) || ISNil(obj))
            {
                usefulDic[key] = @"";
                
            }else if([obj isKindOfClass:[NSNumber class]] || [obj isKindOfClass:[NSValue class]])
            {
                usefulDic[key] = [NSString stringWithFormat:@"%@",obj];
            }else if([obj isKindOfClass:[NSDictionary class]])
            {
                usefulDic[key] = [self checkNSDictinaryWithChangeUseful: obj];
            }else if([obj isKindOfClass:[NSArray class]])
            {
                usefulDic[key] = [self checkNSArrayWithChangeUseful:obj];
            }
            
        }];
        return [NSDictionary dictionaryWithDictionary:usefulDic];
    }
    return checkDictioary;
}

#pragma 将字符串转JSon数据
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
- (NSString*)appVersion;
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
-(instancetype)keyPath:(NSString *)key withTarget:(id)target
{
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    
    if([language isEqualToString: @"en"])
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ENList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[NSStringFromClass([target class])];
        
        return userDic[key];
        
    }else if([language isEqualToString: @"zh-Hans"]){
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CNList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[NSStringFromClass([target class])];
        
        return userDic[key];
    }else if([language isEqualToString: @"fr"]){
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FRList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[NSStringFromClass([target class])];
        
        return userDic[key];
    }else{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ITList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[NSStringFromClass([target class])];
        
        return userDic[key];
    }
}
-(instancetype)keyPath:(NSString *)key withClass:(NSString *)className
{
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    
    if([language isEqualToString: @"en"])
    {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ENList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[className];
        
        return userDic[key];
        
    }else if([language isEqualToString: @"zh-Hans"]){
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CNList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[className];
        
        return userDic[key];
    }else if([language isEqualToString: @"fr"]){
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FRList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[className];
        
        return userDic[key];
    }else{
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ITList" ofType:@"plist"];
        
        NSMutableDictionary *rootDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
        NSDictionary *userDic = rootDic[className];
        
        return userDic[key];
    }
}
- (BOOL)cameraPemission
{
    
    BOOL isHavePemission = YES;
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                isHavePemission = YES;
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                isHavePemission = NO;
                break;
            case AVAuthorizationStatusNotDetermined:
                isHavePemission = YES;
                break;
        }
    }
    
    return isHavePemission;
}
-(NSInteger)isWhatLanguages
{
    //修改本地获取的语言文件--交替
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    if ([language isEqualToString: @"en"]) {
        return 0;
    }else if([language isEqualToString: @"zh-Hans"]||
             [language isEqualToString: @"zh-Hant"]){
        
        return 1;
        
    }else if([language isEqualToString: @"fr"]){
        
        return 3;
        
    }else{
        
        return 2;
    }
}

-(void)changeChineseLanguages
{
    //修改本地获取的语言文件--交替
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    
    if (![language isEqualToString: @"zh-Hans"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)changeEglishLanguages
{
    //修改本地获取的语言文件--交替
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    
    if (![language isEqualToString: @"en"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)changeItalyLanguges
{
    //修改本地获取的语言文件--交替
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    
    if (![language isEqualToString: @"it"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"it" forKey:@"appLanguage"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)changeFrenchLaunguages
{
    //修改本地获取的语言文件--交替
    NSString *language = [[NSUserDefaults standardUserDefaults]objectForKey:@"appLanguage"];
    
    if (![language isEqualToString: @"fr"]){
        [[NSUserDefaults standardUserDefaults] setObject:@"fr" forKey:@"appLanguage"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//排序
-(NSString *)makePaiXu:(NSDictionary *)dic
{
    NSArray *keys = [dic allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    int i = 0;
    NSMutableString *string = [NSMutableString string];
    for (NSString *categoryId in sortedArray) {
        if(i == 0)
        {
            [string appendFormat:@"%@=%@",categoryId,[dic objectForKey:categoryId]];
        }else{
            [string appendFormat:@"&%@=%@",categoryId,[dic objectForKey:categoryId]];
        }
        ++i;
    }
    [string appendString:[self getUserPass]];
    return string;
}
-(NSDictionary *)secrecyParam:(NSDictionary *)param
{
    NSMutableDictionary *secrecyParam =[NSMutableDictionary dictionaryWithDictionary:param];
    
    NSString *md5String = [self makePaiXu:param];
    
    [secrecyParam setObject:[md5String md5] forKey:@"vkey"];
    NSLog(@"Thesa%@\n",param);
    return [NSDictionary dictionaryWithDictionary:secrecyParam];
}
-(BOOL)isLogin
{
    if(![LHDataManager LH_ExistenceFmdb:LHUserFmdb])
    {
        return NO;
    }
    
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    
    if(fmdbData.count == 0)
    {
        return NO;
    }
    
    LHUser *user = [fmdbData firstObject];
    
    return [user.userIsLogin boolValue];
}
-(NSString *)getUserId
{
    if(![LHDataManager LH_ExistenceFmdb:LHUserFmdb])
    {
        return nil;
    }
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    
    if(fmdbData.count == 0)
    {
        return nil;
        
    }else{
        
        LHUser *user = [fmdbData lastObject];
        
        return user.userId;
    }
}
-(NSString *)getUserPass
{
    if(![LHDataManager LH_ExistenceFmdb:LHUserFmdb])
    {
        return nil;
    }
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    
    if(fmdbData.count == 0)
    {
        return nil;
        
    }else{
        
        LHUser *user = [fmdbData lastObject];
        
        return user.userPass;
    }
}

-(NSString *)getUserType
{
    if(![LHDataManager LH_ExistenceFmdb:LHUserFmdb])
    {
        return nil;
    }
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    
    if(fmdbData.count == 0)
    {
        return nil;
        
    }else{
        
        LHUser *user = [fmdbData lastObject];
        
        return user.userType;
    }
}
//XYW-D9EB11E451D3
-(NSString *)macIpByName:(NSString *)Bname
{
    if(Bname.length >= 12){
        
        NSString *oMac = [[Bname componentsSeparatedByString:@"-"] lastObject];
        
        NSMutableString *nMac = [NSMutableString string];
        
        for (NSInteger i = 0; i < oMac.length; ++i) {
            [nMac appendFormat:@"%c",[oMac characterAtIndex:i]];
            if(i % 2 && i != oMac.length - 1)
            {
                [nMac appendFormat:@"%@",@":"];
            }
        }
        
        return nMac;
        
    }else{
        
        return Bname;
    }
}
-(NSString *)findErrorDetailInErrorList:(id)result error:(NSError *)error withAutoErrorMessage:(NSString *)message
{
    if(!error && [result isKindOfClass:[NSDictionary class]] && result[LHResult] && [result[LHResult] integerValue] < 0)
    {
        NSString *code = [NSString stringWithFormat:@"%@",result[LHResult]];
        
        NSString *errMessage = (NSString *)[LHToolManager keyPath:code withTarget:self];
        
        if(errMessage.length)
        {
            return errMessage;
        }else{
            return message;
        }
    }
    
    return message;
}
-(void)logout
{
    NSDictionary *dic = [NSDictionary dictionary];
    NSMutableArray *mainData = [NSMutableArray array];
    NSDictionary *dic1 = [NSDictionary dictionary];
    NSInteger langint=[self isWhatLanguages];
    NSString *lock_name=@"";
    switch (langint) {
            
        case 0:
            lock_name=@"You Have No Locks";
            break;
        case 1:
            lock_name=@"您还没有钥匙";
            break;
        case 2:
            lock_name=@"Non hai ancora bloccato";
            break;
        case 3:
            lock_name=@"Vous n'avez pas encore verrouillé";
            break;
        default:
            lock_name=@"You Have No Locks";
            break;
    }
    dic1 = @{
             @"jihuo":@"1",
             @"key":@"0810151308107781",
             @"lock_id":@"282",
             @"lock_mac":@"E8:54:93:0E:73:CE",
             @"lock_name":lock_name,
             @"lock_num":@"1234565432",
             @"type":@"0",
             @"user_id":@"104"
             };
    [mainData addObject:dic1];
    dic = @{
            @"result":@"1",
            @"infos":mainData
            };
    LHLockController *lockController = [[LHLockController alloc] init];
    [lockController formatLocks:dic];
    NSArray *users = [LHDataManager LH_FineFmdbKey:LHUserFmdb withFmdbClass:[LHUser class]];
    
    LHUser *user = users.firstObject;
    
    user.userIsLogin = @"0";
    
    [LHDataManager LH_UpdataFmdbId:user withFmdbKey:LHUserFmdb Wherekey:ObjcKeyPath(user, userPass) value:user.userPass];
}
- (NSString *)removeSpaceAndNewline:(NSString *)str {
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

-(NSString *)gainMacToData:(NSData *)data
{
    Byte *oByte = (Byte *)[data bytes];
    
    NSUInteger byteLength = data.length;
    
    if(byteLength >= 8)
    {
        NSMutableString *lockMac = [NSMutableString string];
    
        for (int n = 7; n >= 2; --n) {
        
            [lockMac appendFormat:@"%02x",oByte[n]];
        
            if(n > 2)
            {
                [lockMac appendFormat:@":"];
            }
        }
        
        return [self toUpper:lockMac];
        
    }else{
        
        return nil;
    }
}
-(NSString *)toUpper:(NSString *)str{
    for (NSInteger i=0; i<str.length; i++) {
        if ([str characterAtIndex:i]>='a'&[str characterAtIndex:i]<='z') {
            //A  65  a  97
            char  temp=[str characterAtIndex:i]-32;
            NSRange range=NSMakeRange(i, 1);
            str=[str stringByReplacingCharactersInRange:range withString:[NSString stringWithFormat:@"%c",temp]];
        }
    }
    return str;
}
-(void)setLoginType:(NSString *)type{
    _LoginType=type;
}

-(NSString *)getLoginType{
    return self.LoginType;
}
/*
 NSInteger code = [result[LHResult] integerValue];
 
 switch (code) {
 case -1111:
 return @"授权失败";
 case -2520:
 return @"该用户已经存在!";
 break;
 case -2521:
 return @"添加用户失败";
 break;
 case -2522:
 return @"用户名不能为空!";
 break;
 case -2523:
 return @"你没有该锁或分享锁已经失效!";
 break;
 case -2501:
 return @"数据修改有误，请重试!";
 break;
 case -2502:
 return @"用户不存在或密码错误";
 break;
 case -2503:
 return @"该用户名已经存在";
 break;
 case -2504:
 return @"修改失败，请重试!";
 break;
 case -2518:
 return @"添加关联失败";
 break;
 case -2505:
 return @"添加锁失败";
 break;
 case -2506:
 return @"该锁已经存在!";
 break;
 case -2507:
 return @"已经存在该锁";
 break;
 case -2508:
 return @"修改锁失败";
 break;
 case -2509:
 return @"删除锁失败";
 break;
 case -2510:
 return @"该锁不存在!";
 break;
 case -2511:
 return @"锁分享失败";
 break;
 case -2512:
 return @"该分享锁已经失效!";
 break;
 case -2513:
 return @"该锁已经被领取!";
 break;
 case -2514:
 return @"锁分享有误!";
 break;
 case -2515:
 return @"锁分享有误!";
 break;
 case -2516:
 return @"生成用户异常!";
 break;
 case -2517:
 return @"添加记录失败";
 break;
 case -2524:
 return @"分享锁已经过时!";
 break;
 case -2526:
 return @"你没有分享记录!";
 break;
 case -2527:
 return @"你没有分享权限";
 break;
 case -2529:
 return @"该接收者名已经存在";
 break;
 case -2530:
 return @"修改失败，请重试!";
 break;
 case -2531:
 return @"接收者名不能为空!";
 break;
 case -2532:
 return @"删除分享锁失败!";
 break;
 case -2533:
 return @"网络繁忙,请重试!";
 break;
 case -2535:
 return @"添加推送id失败!";
 break;
 case -2537:
 return @"推送id不存在!";
 break;
 case -2538:
 return @"邮箱分享失败!";
 break;
 case -2536:
 return @"添加推送id失败!";
 break;
 case -2539:
 return @"删除分享锁失败!";
 break;
 default:
 return message;
 break;
 }
 */
@end
