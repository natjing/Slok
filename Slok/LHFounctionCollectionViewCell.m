//
//  LHFounctionCollectionViewCell.m
//  Slok
//
//  Created by LiuHao on 2017/5/25.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHFounctionCollectionViewCell.h"
@interface LHFounctionCollectionViewCell()
@property (weak, nonatomic) IBOutlet UILabel *functionLable;
@property (weak, nonatomic) IBOutlet UIImageView *functionImageView;

@end
@implementation LHFounctionCollectionViewCell

-(void)initCollectionViewCell:(NSDictionary *)cellDic
{
    UIImage *image = cellDic[LHFunctionImage];
    
    self.functionImageView.image = image;
    
    self.functionLable.text = cellDic[LHFunctionTxt];
}
@end
