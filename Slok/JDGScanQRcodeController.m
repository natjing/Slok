//
//  JDGScanQRcodeController.m
//  Slok
//
//  Created by user on 2018/6/26.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "JDGScanQRcodeController.h"
#import <AVFoundation/AVFoundation.h>
#import <SafariServices/SafariServices.h>
#import "JDGScanQRcodeView.h"
#import "TJHeadView.h"
#import "LHCodeLockViewController.h"
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width//获取设备屏幕的宽
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height//获取设备屏幕的高
@interface JDGScanQRcodeController ()<AVCaptureMetadataOutputObjectsDelegate>
// 1.输入设备(采集信息)  摄像头  键盘   麦克风
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
// 2.输出设备(解析数据)  Metadata:元数据
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
// 3.会话 (连接输入和输出设备)
@property (nonatomic, strong) AVCaptureSession *session;
// 4.预览的图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, weak) JDGScanQRcodeView *scanQRcodeView;
@property (weak, nonatomic) IBOutlet UIView *tobu;

@end

@implementation JDGScanQRcodeController

- (void)viewDidLoad {
   [super viewDidLoad];
   
       [self setUpUI];
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 控制器即将出先的时候开启会发,进行扫描
     [self.session startRunning];
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LHSW, 20)];
    headView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:headView];
    TJHeadView *showkeyView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TJHeadView class]) owner:nil options:nil] lastObject];
    
    showkeyView.frame = CGRectMake(0, 20, LHSW, 49);
    UITapGestureRecognizer *updateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Returnevent:)];
    
    [showkeyView.returnview addGestureRecognizer:updateTap];
    
    showkeyView.Interfacesname.text = (NSString *)[LHToolManager keyPath:LHNavTitle withTarget:self];
    [self.view addSubview:showkeyView];
}
//后退
-(void)Returnevent:(UITapGestureRecognizer *)tap
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setUpUI {
    // 二维码本质就是一个字符串
    
    // 1.输入设备(采集信息)  摄像头  键盘   麦克风
    // 默认就是后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    // 2.输出设备(解析数据)
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // 设置代理
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 3.会话 (连接输入和输出设备)
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.deviceInput]) {
        [self.session addInput:self.deviceInput];
    }
    if ([self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
    }
    // 设置解析的类型  不要写在会话之前 会崩溃
    self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    //   预览图层的主要功能就是将摄像头采集的数据及时的传输到预览图层，使得用户可以在预览图层实时的看到画面，主要类是AVCapturePreviewLayer，创建起来也非常容易
    //自定义扫描视图
    CGRect frame= CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    JDGScanQRcodeView *scanQRcodeView = [[JDGScanQRcodeView alloc] initWithFrame:frame];//self.scanview.bounds
    self.scanQRcodeView = scanQRcodeView;
    scanQRcodeView.session = self.session;
    [self.view addSubview:scanQRcodeView];
    
    // 5.开启会话
    [self.session startRunning];
    
}

// 实现AVCaptureMetadataOutputObjectsDelegate
// 解析到二维码数据后调用
// metadataObjects:解析到的信息
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 关闭会话
    [self.session stopRunning];
    [self.scanQRcodeView Stopmoving];
    // 不能移除layer,移除后返回什么东西都没有了
    //    [self.scanQRcodeView removeFromSuperview];
    for (AVMetadataMachineReadableCodeObject * objc in metadataObjects) {
        NSLog(@"%@",objc.stringValue);
        NSString *type_string = [objc.stringValue substringToIndex:1];
        if([type_string isEqualToString:@"0"]||
           [type_string isEqualToString:@"1"]||
           [type_string isEqualToString:@"2"]||
           [type_string isEqualToString:@"3"]||
           [type_string isEqualToString:@"4"]){
        if(objc.stringValue.length==28){
              LHCodeLockViewController *viewController = [[LHCodeLockViewController alloc] init];
            viewController.scanNumber = [objc.stringValue substringToIndex:16];
            viewController.scanMac = [objc.stringValue substringFromIndex:16];
            [self.navigationController pushViewController:viewController animated:YES];
        }else if(objc.stringValue.length==16){
              LHCodeLockViewController *viewController = [[LHCodeLockViewController alloc] init];
            viewController.scanNumber = [objc.stringValue substringToIndex:16];
            viewController.scanMac =@"";
            [self.navigationController pushViewController:viewController animated:YES];
        }else if(objc.stringValue.length==21){
            LHCodeLockViewController *viewController = [[LHCodeLockViewController alloc] init];
            viewController.scanNumber = [objc.stringValue substringToIndex:16];
            viewController.scanMac =@"";
            [self.navigationController pushViewController:viewController animated:YES];
        }else{
            [self PopupsTips];
        }
        }else{
            [self PopupsTips];
        }
    }
}
-(void)PopupsTips
{
    
    UIAlertController *alet = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHPrompt withTarget:self] message:(NSString *)[LHToolManager keyPath:TJScanerror withTarget:self] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alet dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alet addAction:yesAction];
    
    [self presentViewController:alet animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
