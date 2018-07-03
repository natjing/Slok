//
//  LHFunctionControlView.h
//  Slok
//
//  Created by LiuHao on 2017/5/25.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LHFunctionDelegate <NSObject>
-(void)didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
@end
@interface LHFunctionControlView : UIView
-(void)settingFunctionControlView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *settingView;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
@property (weak, nonatomic) IBOutlet UILabel *loginTypeLable;
@property (nonatomic,assign)id<LHFunctionDelegate>functionDelegate;
-(void)refreshFunctionView;
@end
