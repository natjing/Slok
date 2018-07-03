//
//  SndApi.h
//  SndApi
//
//  Created by LiuHao on 2017/7/1.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SndApi : NSObject
+(NSData *)Make:(const char*)sz mix_flg:(int)mix_flg;
+(int)OnMic:(short *)pcm_dat pcm_cnt:(int)pcm_cnt;
+(int)Save:(const char*)sz wavfile:(const char*)fname mix_flg:(int)mix_flg;
+(BOOL)Delet_Pcm;
@end
