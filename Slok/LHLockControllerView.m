//
//  LHLockControllerView.m
//  Slok
//
//  Created by LiuHao on 2017/5/24.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHLockControllerView.h"
#define isPhoneX_bm ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
@interface LHLockControllerView ()
@property (weak, nonatomic) IBOutlet UILabel *slokStateLable;
@property (weak, nonatomic) IBOutlet UILabel *lockNameLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Frombottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgheight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NameHeight;

@end
@implementation LHLockControllerView
-(void)initLockControllerViewLable:(NSString *)lockName withVoice:(BOOL)isVoice
{
    
   // if(isPhoneX_bm){
    
    if(isVoice){
        self.Frombottom.constant+=20;
        self.imgheight.constant+=40;
       // self.NameHeight.constant+=60;
    }
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(!locks.count)
    {
        self.lockNameLable.text = (NSString *)[LHToolManager keyPath:LHNoLock withTarget:self];
        
    }else{
        
        self.lockNameLable.text = lockName;
    }
    
    self.slokStateLable.text = (NSString *)[LHToolManager keyPath:LHSlokState withTarget:self];
    
    self.autoOpenLable.text = (NSString *)[LHToolManager keyPath:LHAutoUnlocked withTarget:self];
    
    NSDictionary *buleToothState = (NSDictionary *)[LHToolManager keyPath:LHBuleToothState withTarget:self];
    
    self.buleToothStateLable.text = buleToothState[LHNoConnect];
}
-(void)refreshLockControllerViewLable:(NSUInteger)buleState withLockState:(NSUInteger)lockState
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(!locks.count)
    {
        self.lockNameLable.text = (NSString *)[LHToolManager keyPath:LHNoLock withTarget:self];
        
    }
    
    self.slokStateLable.text = (NSString *)[LHToolManager keyPath:LHSlokState withTarget:self];
    
    self.autoOpenLable.text = (NSString *)[LHToolManager keyPath:LHAutoUnlocked withTarget:self];
    
    NSDictionary *buleToothStateDic = (NSDictionary *)[LHToolManager keyPath:LHBuleToothState withTarget:self];
    
    NSString *slokStateKey = nil;
    
    switch (buleState) {
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
    
    self.buleToothStateLable.text =buleToothStateDic[slokStateKey];
    
    NSDictionary *lockStateDic = (NSDictionary *)[LHToolManager keyPath:LHLockState withTarget:self];
    
    NSString *lockStateKey = nil;
    
    switch (lockState) {
        case 0:
        {
            lockStateKey = LHLockOpen;
        }
            break;
        case 1:
        {
            lockStateKey = LHLockClose;
        }
            break;
        default:
        {
            lockStateKey = LHLockOpen;
        }
            break;
    }
    
    [self.lockStateButton setTitle:lockStateDic[lockStateKey] forState:UIControlStateNormal];
    
   
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
