//
//  LYAudioRecorder.h
//  KeySteward
//
//  Created by wei feng on 16/4/2.
//  Copyright © 2016年 wei feng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AudioRecordHandle)(NSData *data, NSError *error);

@interface LYAudioRecorder : NSObject

@property (nonatomic, strong, readonly) NSString *audioPath;
@property (nonatomic, strong, readonly) NSDictionary *audioSetting;
@property (nonatomic, strong, readonly) NSData *audioData;

+ (instancetype)shareInstance;

/**
 *  @brief 准备录音
 *
 *  @param recordPath    录音文件保存路径
 *  @param recordSetting 录音设置
 *
 *  @return 准备是否成功
 */
- (BOOL)prepareToRecord:(NSString *)recordPath recordSetting:(NSDictionary *)recordSetting;

/**
 *  @brief 开始（重启）录音
 *
 *  @param duration 本次录音时间（duration＝0 表示不限制录音限制，此时recorder不会回调block，只能自行查询audioData）
 *  @param handle   录音完成回调
 *
 *  @return 录音开启是否成功
 */
- (BOOL)continueRecording:(NSTimeInterval)duration handler:(AudioRecordHandle)handle;

/**
 *  @brief 暂停录音
 */
- (void)pauseRecording;

/**
 *  @brief 停止录音
 */
- (void)stopRecording;

@end
