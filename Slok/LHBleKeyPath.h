//
//  LHBleKeyPath.h
//  Slok
//
//  Created by LiuHao on 2017/6/26.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#ifndef LHBleKeyPath_h
#define LHBleKeyPath_h

#define LHBleHeader 0x55
#define LHBleEnd 0xAA
//读ID
#define LHBleReadId 0x01
//解锁
#define LHBleOpenLock 0x31
//落锁
#define LHBleCloseLock 0x32
//允许下一个按键来开锁
#define LHBleNextOpen 0x33
//写ID
#define LHBleWriteId 0x34
//更新密钥
#define LHBleUpdatePass 0x35
//

#endif /* LHBleKeyPath_h */
