//
//  LHBlueToothManager.h
//  Slok
//
//  Created by LiuHao on 2017/6/26.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^BleBlock) (int eleNum);
#define LHBLEDataManager [LHBlueToothManager shareInstence]
@interface LHBlueToothManager : NSObject
+ (instancetype)shareInstence;
@property(nonatomic,strong)BleBlock bleBlock;
@property(nonatomic,strong)NSString *lockId;
@property(nonatomic,assign)NSUInteger feedBackType;
- (BOOL)bleFeedbackIsTure:(NSData *)data withKey:(NSString *)passKey;
- (BOOL)isOpenFeedback:(NSData *)data;
-(NSString *)gainLockIdKey:(NSString *)key;
-(NSString *)resetLockIdKey:(NSString *)key;
-(NSString *)gainTouchOpenKey:(NSString *)key;

//重置锁
-(NSString *)ResetLockKey;
-(NSString *)gainOpenLockKey;
-(NSString *)gainCloseLockKey;
-(NSString *)gainUpdataPassKey;
@end
