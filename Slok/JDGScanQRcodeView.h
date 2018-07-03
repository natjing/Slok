//
//  JDGScanQRcodeView.h
//  Slok
//
//  Created by user on 2018/6/26.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface JDGScanQRcodeView : UIView
// session
@property (nonatomic, strong) AVCaptureSession *session;
-(void)Stopmoving;
@end
