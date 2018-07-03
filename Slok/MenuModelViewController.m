//
//  MenuModelViewController.m
//  Slok
//
//  Created by 刘昊 on 2017/12/4.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "MenuModelViewController.h"

@interface MenuModelViewController ()

@end

@implementation MenuModelViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setMenuModel:(MenuModel *)menuModel{
    _menuModel = menuModel;
    self.featuresimg.image = [UIImage imageNamed:menuModel.imageName];
    self.featuresname.text = menuModel.itemName;
    
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
