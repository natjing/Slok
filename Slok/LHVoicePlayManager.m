//
//  LHVoicePlayManager.m
//  LHSupudePower
//
//  Created by LiuHao on 2017/7/5.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHVoicePlayManager.h"
#import "SimpleAudioPlayer.h"
#import "SndApi.h"
#import "LYAudioRecorder.h"
@interface LHVoicePlayManager()
@property(nonatomic,assign)BOOL isCancelPlay;
@property(nonatomic,assign)NSInteger playTimes;
@property(nonatomic,strong)NSString *keyVaule;
@end
@implementation LHVoicePlayManager
-(void)playVoice:(NSString *)keyVal
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[self getVoicePath]])
    {
        [fileManager removeItemAtPath:[self getVoicePath] error:nil];
    }
    
    self.isCancelPlay = NO;
    
    self.keyVaule = keyVal;
    
    [[LYAudioRecorder shareInstance] prepareToRecord:nil recordSetting:nil];
    
    [self initPlayVoice];
}
-(void)initPlayVoice
{
    if(self.keyVaule.length >= 8)
    {
        char cmd[13] = {0*13};
        
        switch (self.playType) {
            case 0:
                cmd[0] = 'a';
                break;
            case 1:
                cmd[0] = 'u';
                break;
            case 2:
                cmd[0] = 'v';
                break;
            default:
                break;
        }
        //NSLog(@"%c%@",cmd[0],keyVal);
        const char *cKey = [self.keyVaule cStringUsingEncoding:NSUTF8StringEncoding];
        
        size_t length = strlen(cKey);
        
        memcpy(cmd+1, cKey, length);
        
        [SndApi Save:cmd wavfile:[[self getVoicePath] cStringUsingEncoding:NSUTF8StringEncoding] mix_flg:![LHDataManager getBoolValue:LHMixVoice]];
        
        [self begainPlayVoice];
    }
}
-(void)begainPlayVoice
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:[self getVoicePath]])
    {
        
        [self beginRecordSetting];
        
        [SimpleAudioPlayer playFile:[self getVoicePath] volume:1 loops:0 withCompletionBlock:^(BOOL result) {
            
        }];
        
        if ([[LYAudioRecorder shareInstance] continueRecording:0 handler:nil])
        {
            
        }
        
        if(self.isCancelPlay == NO)
        {
            [self performSelector:@selector(checkRecordedData)
                       withObject:nil
                       afterDelay:0.8];
            
        }
    }
}
-(void)checkRecordedData
{
    NSData *data = [LYAudioRecorder shareInstance].audioData;
    
    short * pcm_dat = (short *)[data bytes];
    
    int length = (int)ceil([data length]/2);
    
    int result = [SndApi OnMic:pcm_dat pcm_cnt:length];
    
    if (result >= 0 && result < 4)
    {
        [self stopPlay];
        
        [self.voicePlayDelegate playBackResult:result];
            
    }else if (self.playTimes < 1)
    {
        ++self.playTimes;
            
        [self performSelector:@selector(checkRecordedData)
                       withObject:nil
                       afterDelay:0.8];
    }else
    {
        self.playTimes = 0;
        [SimpleAudioPlayer stopAllPlayers];
        [[LYAudioRecorder shareInstance] stopRecording];
        
        if(self.isCancelPlay == NO)
        {
            [self initPlayVoice];
        }
    }
}
-(void)stopPlay
{
    self.isCancelPlay = YES;
    
    [SimpleAudioPlayer stopAllPlayers];
    
    [[LYAudioRecorder shareInstance] stopRecording];
}
-(void)beginRecordSetting
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    if(!success)
    {
        NSLog(@"AVAudioSession setCategory Error:%@",setCategoryError);
    }
    else
    {
        NSError *setActiveError=nil;
        
        success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setActiveError];
        
        if(!success)
        {
            NSLog(@"AVAudioSession setActive Error:%@",setActiveError);
        }
    }
}

-(NSString *)getVoicePath
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    NSString *extensionPath = [@"sndApi" stringByAppendingString:@".wav"];
    
    return [path stringByAppendingPathComponent:extensionPath];
}
-(NSString *)getPCMPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask, YES);
    NSString *pcmPath = [[paths firstObject] stringByAppendingPathComponent:@"sndApi.pcm"];
    
    return pcmPath;
}



-(void)dealloc
{
    [self stopPlay];
}
@end
