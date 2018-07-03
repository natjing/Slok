//
//  LHVoicePlayManager.h
//  LHSupudePower
//
//  Created by LiuHao on 2017/7/5.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol LHVoicePlayDelegate <NSObject>
-(void)playBackResult:(int)result;
@end
@interface LHVoicePlayManager : NSObject
@property(nonatomic,assign)id<LHVoicePlayDelegate>voicePlayDelegate;
@property(nonatomic,assign)NSInteger playType;
-(void)playVoice:(NSString *)keyVal;
-(void)stopPlay;
@end
