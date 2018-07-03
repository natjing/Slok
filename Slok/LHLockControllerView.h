//
//  LHLockControllerView.h
//  Slok
//
//  Created by LiuHao on 2017/5/24.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHLockControllerView : UIView

@property (weak, nonatomic) IBOutlet UIView *locklayout;
@property (weak, nonatomic) IBOutlet UIImageView *lockimg;
@property (weak, nonatomic) IBOutlet UILabel *statoline;
@property (weak, nonatomic) IBOutlet UIImageView *typeimg;

@property (weak, nonatomic) IBOutlet UIImageView *shareimg;

@property (weak, nonatomic) IBOutlet UIImageView *dainciimg;

@property (weak, nonatomic) IBOutlet UILabel *buleToothStateLable;
@property (weak, nonatomic) IBOutlet UIButton *lockStateButton;
 
 
@property (weak, nonatomic) IBOutlet UIButton *autoSelectButton;
@property (weak, nonatomic) IBOutlet UILabel *autoOpenLable;
@property (weak, nonatomic) IBOutlet UILabel *eleNumLable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eleNumConstant;
@property (weak, nonatomic) IBOutlet UIView *eleNumView;
@property (weak, nonatomic) IBOutlet UIView *btnShareView;
@property (weak, nonatomic) IBOutlet UILabel *demolabel;
@property (weak, nonatomic) IBOutlet UIView *lockinformation;
@property (weak, nonatomic) IBOutlet UIView *autolockview;


-(void)initLockControllerViewLable:(NSString *)lockName withVoice:(BOOL)isVoice;
-(void)refreshLockControllerViewLable:(NSUInteger)buleState withLockState:(NSUInteger)lockState;
@end
