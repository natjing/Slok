//
//  JDGScanQRcodeView.m
//  Slok
//
//  Created by user on 2018/6/26.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "JDGScanQRcodeView.h"


@interface JDGScanQRcodeView ()
// 图框
@property (nonatomic, strong) UIImageView *imageView;
// 扫描线
@property (nonatomic, strong) UIImageView *lineImageView;
// 定时器开启扫描线来回移动
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation JDGScanQRcodeView

- (void)setSession:(AVCaptureSession *)session {
    _session = session;
    // 预览图层
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    layer.session = session;
}

// 初始化预览图层
+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        [self initUiConfig];
    }
    return self;
}

//在一个视图中设置二维码UI的垃圾代码
- (void)initUiConfig {
    //设置背景图片
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_code_bg.png"]];
    //设置位置到界面的中间
    self.imageView.frame = CGRectMake(self.bounds.size.width * 0.5 - 140, self.bounds.size.height * 0.5 - 140, 280, 280);
    
    //添加到视图上
    [self addSubview:self.imageView];
    
    //初始化二维码的扫描线的位置
    self.lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    self.lineImageView.image = [UIImage imageNamed:@"scan_line.png"];
    [self.imageView addSubview:self.lineImageView];
    
//    UILabel *tipLabel = [[UILabel alloc] init];
//    tipLabel.text = @"将二维码放入框内,即可自动扫描";
//    tipLabel.font = [UIFont systemFontOfSize:14.0];
//    tipLabel.textColor = [UIColor whiteColor];
//    [self addSubview:tipLabel];
    //开启定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}


// 扫描线动态扫描
- (void)animation {
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.lineImageView.frame = CGRectMake(30, 260, 220, 2);
    } completion:^(BOOL finished) {
        self.lineImageView.frame = CGRectMake(30, 10, 220, 2);
    }];
}
-(void)Stopmoving{
    [self.timer invalidate];
   self. timer = nil;
}
@end
