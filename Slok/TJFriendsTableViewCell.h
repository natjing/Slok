//
//  TJFriendsTableViewCell.h
//  Slok
//
//  Created by user on 2018/3/27.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsObj.h"
@interface TJFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *UserImg;
@property (weak, nonatomic) IBOutlet UILabel *UserName;
@property (weak, nonatomic) IBOutlet UIButton *AcceptButton;

@property (weak, nonatomic) IBOutlet UIButton *IgnoreButton;
@property(nonatomic,strong) FriendsObj *currentfriend;
@end
