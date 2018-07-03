//
//  MenuModelViewController.h
//  Slok
//
//  Created by 刘昊 on 2017/12/4.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuModel.h"
@interface MenuModelViewController : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *featuresimg;
@property (weak, nonatomic) IBOutlet UILabel *featuresname;

@property (nonatomic,strong) MenuModel * menuModel;
@end
