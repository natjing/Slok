//
//  ViewController.h
//  Slok
//
//  Created by LiuHao on 2017/5/20.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJGreenControl.h"

#import <Firebase/Firebase.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^block) (void);
@interface ViewController : UIViewController<GIDSignInDelegate,NSXMLParserDelegate>
{
    
    TJGreenControl *lockNumPageControl;
}
-(void)reloadDataInViewController;
@property(nonatomic,strong)block refreshBlock;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

