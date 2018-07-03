//
//  LHNoticeTableViewCell.h
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/27.
//  Copyright © 2017年 supude. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHNoticeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *contextLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UILabel *releaseLable;

@end
