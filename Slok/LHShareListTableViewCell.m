//
//  LHShareListTableViewCell.m
//  Slok
//
//  Created by LiuHao on 2017/5/31.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHShareListTableViewCell.h"

@implementation LHShareListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initShareListTableViewCell
{
    [self.shareLockDeletButton addTarget:self action:@selector(deleteShareLock:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)deleteShareLock:(UIButton *)button
{
    self.refreshBlock(self.lockData);
}
@end
