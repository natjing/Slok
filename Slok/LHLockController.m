//
//  LHLockController.m
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/20.
//  Copyright © 2017年 supude. All rights reserved.
//

#import "LHLockController.h"

@implementation LHLockController
-(void)formatLocks:(NSDictionary *)data
{
    NSMutableArray *mainArr = [NSMutableArray array];
    
    for (NSDictionary *mainDic in data[LHInfos]) {
        
        LHLock *lock = [[LHLock alloc] init];
        
        lock.lockName = mainDic[LHLocksName];
        
        lock.lockMac = mainDic[LHLockMac];
        
        lock.lockNum = mainDic[LHLockNum];
        
        lock.lockType = mainDic[LHLockType];
        
        lock.lockId = mainDic[LHLockId];
        
        lock.lockKey = mainDic[LHKey];
        
        lock.lockIsJihuo = mainDic[LHJihuo];
        
        lock.lockSpecies = mainDic[TJLockType];
        if([mainDic[LHUserId] isEqualToString:[LHToolManager getUserId]])
        {
            lock.lockUseTimes = [self existenceOldTimes:mainDic[LHLockId]];
            
            lock.lockVipUse = [self existencePrivilege:mainDic[LHLockId]];
            
            lock.lockAutoOpen = [self existenceOldAutoOpen:mainDic[LHLockId]];
            
        }else{
           
            lock.lockUseTimes = @"0";
            
            lock.lockVipUse = @"0";
            
            lock.lockAutoOpen = @"0";
        }
        
        [mainArr addObject:lock];
    }
    
    [self useTimePaixu:mainArr];
}
-(NSString *)existencePrivilege:(NSString *)keyId
{
    if(![LHDataManager LH_ExistenceFmdb:LHLockFmdb])
    {
        return @"0";
    }
    
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(fmdbData.count == 0)
    {
        return @"0";
        
    }else{
        
        for (LHLock *lock in fmdbData) {
            
            if([lock.lockId isEqualToString:keyId])
            {
                return lock.lockVipUse.length ? lock.lockVipUse : @"0";
            }
            
        }
        
        return @"0";
    }
}
-(NSString *)existenceOldTimes:(NSString *)keyId
{
    if(![LHDataManager LH_ExistenceFmdb:LHLockFmdb])
    {
        return @"0";
    }
    
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(fmdbData.count == 0)
    {
        return @"0";
        
    }else{
        
        for (LHLock *lock in fmdbData) {
            
            if([lock.lockId isEqualToString:keyId])
            {
                return lock.lockUseTimes.length ? lock.lockUseTimes : @"0";
            }
            
        }
        
        return @"0";
    }
}
-(NSString *)existenceOldAutoOpen:(NSString *)keyId
{
    if(![LHDataManager LH_ExistenceFmdb:LHLockFmdb])
    {
        return @"0";
    }
    
    NSArray *fmdbData = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(fmdbData.count == 0)
    {
        return @"0";
        
    }else{
        
        for (LHLock *lock in fmdbData) {
            
            if([lock.lockId isEqualToString:keyId])
            {
                return lock.lockAutoOpen.length ? lock.lockAutoOpen : @"0";
            }
            
        }
        
        return @"0";
    }
}

#pragma mark 对钥匙播放次数进行排序
-(void)useTimePaixu:(NSMutableArray *)lockArray
{
    for (NSInteger i = 0; i < lockArray.count; ++i) {
        for (NSInteger j = i + 1; j < lockArray.count; ++j) {
            LHLock *oneTimes  = OBJECT_AT_INDEX(lockArray, i);
            LHLock *twoTimes  = OBJECT_AT_INDEX(lockArray, j);;
            
            if(([twoTimes.lockUseTimes intValue] > [oneTimes.lockUseTimes intValue] && ![oneTimes.lockVipUse intValue]) || [twoTimes.lockVipUse intValue])
            {
                [lockArray exchangeObjectAtIndex:i withObjectAtIndex:j];
                
                if([twoTimes.lockVipUse intValue])
                {
                    break;
                }
            }
        }
    }
    
    [LHDataManager LH_DeletFmdbKey:LHLockFmdb];
    
    [LHDataManager LH_CreatFmdb:[LHLock class] withFmdbKey:LHLockFmdb];
    
    [LHDataManager LH_InserFmdbs:lockArray withFmdbKey:LHLockFmdb];
}
@end
