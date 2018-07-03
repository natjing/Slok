//
//  LHData.m
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/13.
//  Copyright © 2017年 supude. All rights reserved.
//

#import "LHData.h"
#import "XHNetworkCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <JQFMDB/JQFMDB.h>

@interface LHData()
@property (nonatomic,strong)JQFMDB *db;
@end

@implementation LHData

+ (instancetype)shareInstence
{
    static LHData *_manager = nil;
    
    if (_manager == nil)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _manager = [[LHData alloc] init];
        });
    }
    
    return _manager;
}
-(JQFMDB *)db
{
    if(_db == nil)
    {
        _db = [JQFMDB shareDatabase];
    }
    return _db;
}
#pragma mark - 存储Json数据
-(BOOL)LH_SaveJsonRequestData:(id)jsonData withKey:(NSString *)jsonKey
{
    BOOL result = [XHNetworkCache saveJsonResponseToCacheFile:jsonData andURL:jsonKey];
    
    if(result)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
#pragma mark - 异步存储Json数据
-(void)LH_AsyncJsonRequestData:(id)jsonData withJsonKey:(NSString *)jsonKey hander:(DataHandler)hand
{
    [XHNetworkCache save_asyncJsonResponseToCacheFile:jsonData andURL:jsonKey completed:^(BOOL result) {
        
        hand(result);
        
    }];
}
#pragma mark - 获取Json数据
-(id)LH_GetJsonDataForKey:(NSString *)jsonKey
{
    id cacheJson = [XHNetworkCache cacheJsonWithURL:jsonKey];
    
    return cacheJson;
}


#pragma mark - 创建FMDB
-(void)LH_CreatFmdb:(id)fmdbClass withFmdbKey:(NSString *)fmdbKey
{
    if(![self.db jq_isExistTable:fmdbKey])
    {
        [self.db jq_createTable:fmdbKey dicOrModel:fmdbClass];
        
    }else{
        
        [self.db jq_alterTable:fmdbKey dicOrModel:fmdbClass];
    }
}
#pragma mark - 存在表FMDB
-(BOOL)LH_ExistenceFmdb:(NSString *)fmdbKey
{
    if([self.db jq_isExistTable:fmdbKey])
    {
        return YES;
    }else{
        
        return NO;
        
    }
}
#pragma mark - FMDB插入一组数据
-(void)LH_InserFmdb:(id)fmdbObject withFmdbKey:(NSString *)fmdbKey
{
    [self.db jq_inDatabase:^{
        [self.db jq_insertTable:fmdbKey dicOrModel:fmdbObject];
    }];
}
#pragma mark - FMDB插入多数据
-(void)LH_InserFmdbs:(NSMutableArray *)fmdbObjects withFmdbKey:(NSString *)fmdbKey
{
    [self.db jq_inDatabase:^{
        [self.db jq_insertTable:fmdbKey dicOrModelArray:fmdbObjects];
    }];
}

#pragma mark - FMDB更新数据
-(void)LH_UpdataFmdb:(id)fmdbObject withFmdbKey:(NSString *)fmdbKey
{
   [self.db jq_updateTable:fmdbKey dicOrModel:fmdbObject whereFormat:nil];
}

#pragma mark - FMDB更新指定对象数据
-(void)LH_UpdataFmdbId:(id)fmdbObject withFmdbKey:(NSString *)fmdbKey Wherekey:(NSString *)key value:(NSString *)value
{
    NSString *fmdbDescribe = [NSString stringWithFormat:@"where %@ = '%@'",key,value];
    
    [self.db jq_updateTable:fmdbKey dicOrModel:fmdbObject whereFormat:fmdbDescribe];
}

#pragma mark - FMDB更新指定字符数据
-(void)LH_UpdataFmdbDic:(NSDictionary *)fmdbDictinary withFmdbKey:(NSString *)fmdbKey Wherekey:(NSString *)key value:(NSString *)value
{
    NSString *fmdbDescribe = [NSString stringWithFormat:@"where %@ = '%@'",key,value];
    
    [self.db jq_updateTable:fmdbKey dicOrModel:fmdbDictinary whereFormat:fmdbDescribe];
}

#pragma mark - FMDB更新指定字符数据2
-(void)LH_UpdataFmdbDic:(NSDictionary *)fmdbDictinary withFmdbKey:(NSString *)fmdbKey FmdbDescrib:(NSString *)fmdbDescrib
{
    [self.db jq_updateTable:fmdbKey dicOrModel:fmdbDictinary whereFormat:fmdbDescrib];
}

#pragma mark - FMDB删除所有数据
-(void)LH_DeletFmdbKey:(NSString *)fmdbKey
{
    [self.db jq_deleteAllDataFromTable:fmdbKey];
}

#pragma mark - FMDB删除指定数据
-(void)LH_DeletFmdbKey:(NSString *)fmdbKey Wherekey:(NSString *)key value:(NSString *)value
{
    NSString *fmdbDescribe = [NSString stringWithFormat:@"where %@ = '%@'",key,value];
    
    [self.db jq_deleteTable:fmdbKey whereFormat:fmdbDescribe];
}

#pragma mark - FMDB删除指定数据2
-(void)LH_DeletFmdbKey:(NSString *)fmdbKey FmdbDescribe:(NSString *)fmdbDescribe
{
    [self.db jq_deleteTable:fmdbKey whereFormat:fmdbDescribe];
}
#pragma mark - FMDB查找表中数据
-(NSArray *)LH_FineFmdbKey:(NSString *)fmdbKey withFmdbClass:(id)objctClass
{
    NSArray *fmdbArr = [self.db jq_lookupTable:fmdbKey dicOrModel:objctClass whereFormat:nil];
    
    return fmdbArr;
}
#pragma mark - FMDB查找指定数据
-(NSArray *)LH_FineFmdbKey:(NSString *)fmdbKey withFmdbClass:(id)objctClass Wherekey:(NSString *)key value:(NSString *)value
{
    NSString *fmdbDescribe = [NSString stringWithFormat:@"where %@ = '%@'",key,value];
    
    NSArray *fmdbArr = [self.db jq_lookupTable:fmdbKey dicOrModel:objctClass whereFormat:fmdbDescribe];
    
    return fmdbArr;
}
#pragma mark - FMDB查找指定数据2
-(NSArray *)LH_FineFmdbKey:(NSString *)fmdbKey withFmdbClass:(id)objctClass FmdbDescribe:(NSString *)fmdbDescribe
{
    NSArray *fmdbArr = [self.db jq_lookupTable:fmdbKey dicOrModel:objctClass whereFormat:fmdbDescribe];
    
    return fmdbArr;
}
//@"where %@ = '%@' and name = ?"
//@"where %@ = '%@' and name = '%@'"
//@"where Age>10 and ID>2"
//@"where Name like'%千锋%'"
-(void)saveBoolValue:(BOOL)value withKey:(NSString *)key
{
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    
    [defults setBool:value forKey:key];
    
    [defults synchronize];
}
-(BOOL)getBoolValue:(NSString *)key
{
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    
   return [defults boolForKey:key];
}
-(void)saveStringValue:(NSString *)value withKey:(NSString *)key
{
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    
    [defults setObject:value forKey:key];
    
    [defults synchronize];
}
-(NSString *)getStringValue:(NSString *)key
{
    NSUserDefaults *defults = [NSUserDefaults standardUserDefaults];
    
    return [defults objectForKey:key];
}
@end
