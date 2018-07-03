//
//  LHData.h
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/13.
//  Copyright © 2017年 supude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LHUser.h"
#import "LHLock.h"
typedef void(^DataHandler)(BOOL result);
#define LHDataManager [LHData shareInstence]
@interface LHData : NSObject
+ (instancetype)shareInstence;
@property(nonatomic,assign)BOOL isWechatShare;
#pragma mark - 存储Json数据
-(BOOL)LH_SaveJsonRequestData:(id)jsonData withKey:(NSString *)jsonKey;
#pragma mark - 异步存储Json数据
-(void)LH_AsyncJsonRequestData:(id)jsonData withJsonKey:(NSString *)jsonKey hander:(DataHandler)hand;
#pragma mark - 获取Json数据
-(id)LH_GetJsonDataForKey:(NSString *)jsonKey;



#pragma mark - 创建FMDB
-(void)LH_CreatFmdb:(id)fmdbClass withFmdbKey:(NSString *)fmdbKey;
#pragma mark - FMDB插入一组数据
-(void)LH_InserFmdb:(id)fmdbObject withFmdbKey:(NSString *)fmdbKey;
#pragma mark - FMDB插入多数据
-(void)LH_InserFmdbs:(NSMutableArray *)fmdbObjects withFmdbKey:(NSString *)fmdbKey;
#pragma mark - FMDB更新数据
-(void)LH_UpdataFmdb:(id)fmdbObject withFmdbKey:(NSString *)fmdbKey;
#pragma mark - FMDB更新指定对象数据
-(void)LH_UpdataFmdbId:(id)fmdbObject withFmdbKey:(NSString *)fmdbKey Wherekey:(NSString *)key value:(NSString *)value;
#pragma mark - FMDB更新指定字符数据
-(void)LH_UpdataFmdbDic:(NSDictionary *)fmdbDictinary withFmdbKey:(NSString *)fmdbKey Wherekey:(NSString *)key value:(NSString *)value;
#pragma mark - FMDB更新指定字符数据2
-(void)LH_UpdataFmdbDic:(NSDictionary *)fmdbDictinary withFmdbKey:(NSString *)fmdbKey FmdbDescrib:(NSString *)fmdbDescrib;
#pragma mark - FMDB删除所有数据
-(void)LH_DeletFmdbKey:(NSString *)fmdbKey;
#pragma mark - FMDB删除指定数据
-(void)LH_DeletFmdbKey:(NSString *)fmdbKey Wherekey:(NSString *)key value:(NSString *)value;
#pragma mark - FMDB删除指定数据2
-(void)LH_DeletFmdbKey:(NSString *)fmdbKey FmdbDescribe:(NSString *)fmdbDescribe;
#pragma mark - FMDB查找表中数据
-(NSArray *)LH_FineFmdbKey:(NSString *)fmdbKey withFmdbClass:(id)objctClass;
#pragma mark - FMDB查找指定数据
-(NSArray *)LH_FineFmdbKey:(NSString *)fmdbKey withFmdbClass:(id)objctClass Wherekey:(NSString *)key value:(NSString *)value;
#pragma mark - FMDB查找指定数据2
-(NSArray *)LH_FineFmdbKey:(NSString *)fmdbKey withFmdbClass:(id)objctClass FmdbDescribe:(NSString *)fmdbDescribe;
#pragma mark - 存在表FMDB
-(BOOL)LH_ExistenceFmdb:(NSString *)fmdbKey;


-(void)saveBoolValue:(BOOL)value withKey:(NSString *)key;
-(BOOL)getBoolValue:(NSString *)key;
-(void)saveStringValue:(NSString *)value withKey:(NSString *)key;
-(NSString *)getStringValue:(NSString *)key;
@end
