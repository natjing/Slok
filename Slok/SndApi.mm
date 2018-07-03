//
//  SndApi.m
//  SndApi
//
//  Created by LiuHao on 2017/7/1.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "SndApi.h"
#include <stdio.h>
#include <string.h>
#include "SoundMake.h"
#include "Global.h"
//wav头的结构如下所示：


@implementation SndApi

+(NSData *)Make:(const char*)sz mix_flg:(int)mix_flg
{
    int char_buflen = CHAR_BUF_LEN;
    int bufLen = (CMD_MAX_LEN + 6) * char_buflen;
    short data[bufLen];
    memset(data,0,sizeof(short)*bufLen);
    int length = (int)strlen(sz);
    SoundMake soundMake;
    soundMake.getLPStrtoBuf(sz,length,data,mix_flg,char_buflen);
    NSData *voiceData = [NSData dataWithBytes:data length:sizeof(short)*bufLen];
    return voiceData;
}
+(int)OnMic:(short *)pcm_dat pcm_cnt:(int)pcm_cnt
{
    SoundMake soundMake;
    int result = soundMake.getCallBackCode(pcm_dat,pcm_cnt);
    return result;
}
+(int)Save:(const char*)sz wavfile:(const char*)fname mix_flg:(int)mix_flg
{
    int char_buflen = CHAR_BUF_LEN;
    int bufLen = (CMD_MAX_LEN + 6) * char_buflen;
    short data[bufLen];
    memset(data,0,sizeof(short)*bufLen);
    int length = (int)strlen(sz);
    SoundMake soundMake;
    soundMake.getLPStrtoBuf(sz,length,data,mix_flg,char_buflen);
    NSData *voiceData = [NSData dataWithBytes:data length:sizeof(short)*bufLen];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask, YES);
    NSString *pcmPath = [[paths firstObject] stringByAppendingPathComponent:@"sndApi.pcm"];
    
    [voiceData writeToFile:pcmPath atomically:YES];
    
    char const *pathPcm = [pcmPath cStringUsingEncoding:NSUTF8StringEncoding];
    
   int result = soundMake.convertPcm2Wav(pathPcm, fname, 1, 44100);
    
   return result;
}
+(BOOL)Delet_Pcm
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask, YES);
    NSString *pcmPath = [[paths firstObject] stringByAppendingPathComponent:@"sndApi.pcm"];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:pcmPath])
    {
        NSError *error;
        
       return [fileManager removeItemAtPath:pcmPath error:&error];
        
    }else{
        
        return YES;
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[SndApi alloc] init];
    }
    return self;
}

@end
