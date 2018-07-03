//
//  LHHistoryTableViewCell.h
//  Slok
//
//  Created by LiuHao on 2017/5/27.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHHistoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lockNameLable;

@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UILabel *userNameLable;
@end
