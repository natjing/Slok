//
//  TJSearchTableViewCell.h
//  Slok
//
//  Created by user on 2018/3/27.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userimg;
@property (weak, nonatomic) IBOutlet UILabel *useraccount;
@property (weak, nonatomic) IBOutlet UILabel *usercontact;
@property (weak, nonatomic) IBOutlet UIButton *addbutton;

@end
