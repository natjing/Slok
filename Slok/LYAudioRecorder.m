//
//  LYAudioRecorder.m
//  KeySteward
//
//  Created by wei feng on 16/4/2.
//  Copyright © 2016年 wei feng. All rights reserved.
//

#import "LYAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "LYHelper.h"

@interface LYAudioRecorder()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic,   copy) AudioRecordHandle recordHandle;

@end

@implementation LYAudioRecorder

@synthesize audioPath = _audioPath;
@synthesize audioSetting = _audioSetting;
@synthesize audioData = _audioData;

+ (instancetype)shareInstance
{
    
    static LYAudioRecorder *_audioRecorder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioRecorder = [[LYAudioRecorder alloc] init];
    });
    return _audioRecorder;
}

#pragma mark - getter

- (AVAudioRecorder *)recorder
{
    if (_recorder == nil)
    {
        NSError *error = nil;
        _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.audioPath]
                                                settings:self.audioSetting
                                                   error:&error];
        _recorder.delegate = self;
        if (error)
        {
            NSLog(@"recorder init failed");
            return nil;
        }
    }
    return _recorder;
}

- (NSString *)audioPath
{
    if (_audioPath == nil)
    {
        _audioPath = [LYHelper filePathForDocumentDirectory:@"cacheAudioRecording.wav"];
    }
    return _audioPath;
}

- (NSDictionary *)audioSetting
{
    if (_audioSetting == nil)
    {
        _audioSetting = @{AVFormatIDKey : @(kAudioFormatLinearPCM),
                          AVSampleRateKey : @44100,
                          AVNumberOfChannelsKey : @1,
                          AVEncoderAudioQualityKey : @(AVAudioQualityHigh),
                          AVLinearPCMBitDepthKey : @16};
    }
    return _audioSetting;
}

- (NSData *)audioData
{
    return [NSData dataWithContentsOfFile:self.audioPath];
}

#pragma mark - public

- (BOOL)prepareToRecord:(NSString *)recordPath recordSetting:(NSDictionary *)recordSetting
{
    _audioPath = recordPath;
    _audioSetting = recordSetting;
    
    if (_recorder.isRecording)
    {
        [_recorder stop];
    }
    
    if (_recorder && ![_recorder deleteRecording])
    {
        NSLog(@"delete old data failed");
    }

    if ([LYHelper checkIsExistsFile:self.audioPath])
    {
        [LYHelper deleteFile:self.audioPath];
    }

    if (self.recorder)
    {
        return [self.recorder prepareToRecord];
    }
    
    return NO;
}

- (void)pauseRecording
{
    if (self.recorder.isRecording)
    {
        [self.recorder pause];
    }
}

- (BOOL)continueRecording:(NSTimeInterval)duration handler:(AudioRecordHandle)handle
{
    self.recordHandle = handle;
    
    if (self.recorder && !self.recorder.isRecording)
    {
        if (duration > 0)
        {
            return [self.recorder recordForDuration:duration];
        }
        return [self.recorder record];
    }
    return NO;
}

- (void)stopRecording
{
    [self.recorder stop];
}

#pragma mark - AVAudioRecording delegate

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    if (self.recordHandle)
    {
        self.recordHandle(self.audioData, error);
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (self.recordHandle)
    {
        if (flag)
        {
            self.recordHandle(self.audioData, nil);
        }
        else
        {
            self.recordHandle(self.audioData, [NSError errorWithDomain:@"audio record failed" code:-1 userInfo:nil]);
        }
    }
}

@end
