//
//  LHFounctionCollectionViewCell.h
//  Slok
//
//  Created by LiuHao on 2017/5/25.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LHFounctionCollectionViewCell : UICollectionViewCell
-(void)initCollectionViewCell:(NSDictionary *)cellDic;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
@end
