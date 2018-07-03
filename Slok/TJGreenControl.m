//
//  TJGreenControl.m
//  Slok
//
//  Created by 刘昊 on 2017/12/6.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "TJGreenControl.h"

@implementation TJGreenControl

- (id)initWithFrame:(CGRect)CGRectMake
{
    self = [super initWithFrame:CGRectMake];
 
    return self;
}
- (void)updateDots
{
    
    
    for (int i=0; i<[self.subviews count]; i++) {
        //圆点
        UIView* dot = [self.subviews objectAtIndex:i];
        //添加imageView
        if ([dot.subviews count] == 0) {
            UIImageView * view = [[UIImageView alloc]initWithFrame:dot.bounds];
            [dot addSubview:view];
        };
        //配置imageView
        UIImageView * view = dot.subviews[0];
        if (i==self.currentPage) {
            view.image=[UIImage imageNamed:@"tjgreencontrol_selected"];
            dot.backgroundColor = [UIColor clearColor];
        }else {
            view.image=[UIImage imageNamed:@"tjgreencontrol_unselected"];
            dot.backgroundColor = [UIColor clearColor];
        }
    }
 
}

- (void)setCurrentPage:(NSInteger)currentPage
{
   [super setCurrentPage:currentPage];
   [self updateDots];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
