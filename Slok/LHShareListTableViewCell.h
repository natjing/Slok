//
//  LHShareListTableViewCell.h
//  Slok
//
//  Created by LiuHao on 2017/5/31.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^myBlock)(NSDictionary *shareData);

@interface LHShareListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *shareLockNameLable;
@property (weak, nonatomic) IBOutlet UIButton *shareLockDeletButton;
@property (nonatomic,strong)NSDictionary *lockData;
@property (nonatomic,strong)myBlock refreshBlock;
-(void)initShareListTableViewCell;
@end
