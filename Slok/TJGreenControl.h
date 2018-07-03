//
//  TJGreenControl.h
//  Slok
//
//  Created by 刘昊 on 2017/12/6.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import <UIKit/UIKit.h>
 
@interface TJGreenControl : UIPageControl
{
    UIImage *_activeImage;
    UIImage *_inactiveImage;
}
- (id)initWithFrame:(CGRect)CGRectMake;
- (void)setCurrentPage:(NSInteger)currentPage;
@end
