//
//  LHFunctionControlView.m
//  Slok
//
//  Created by LiuHao on 2017/5/25.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHFunctionControlView.h"
#import "LHFounctionCollectionViewCell.h"
@interface LHFunctionControlView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *acountLable;
@property (weak, nonatomic) IBOutlet UICollectionView *functionCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *settingLable;
@property (weak, nonatomic) IBOutlet UILabel *logoutLable;
@property (nonatomic,strong)NSArray *cellData;
@end
@implementation LHFunctionControlView

-(void)settingFunctionControlView
{
    [self initCellData];
    
    [self initFunctionControlViewLable];
    
    self.functionCollectionView.dataSource = self;
    
    self.functionCollectionView.delegate = self;
    
    self.functionCollectionView.showsVerticalScrollIndicator = NO;
    
    self.functionCollectionView.showsHorizontalScrollIndicator = NO;
    
    self.functionCollectionView.bounces = NO;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat CW = (LHSW - 129)/3.0;
    
    CGFloat CH = LHSW >= 640 ? CW  * 1.5 : CW  * 1.6;
    
    layout.itemSize = CGSizeMake(CW, CH);
    
    layout.minimumInteritemSpacing = 10;
    
    layout.minimumLineSpacing = 10;
    
    self.functionCollectionView.collectionViewLayout = layout;
    
    [self.functionCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([LHFounctionCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"cell"];
}
-(void)initCellData
{
    self.cellData = @[
                      @{
                          LHFunctionImage :[UIImage imageNamed:@"functionCell7"],
                          LHFunctionTxt :(NSString *)[LHToolManager keyPath:LHBluetoothAddLock withClass:NSStringFromClass([LHFounctionCollectionViewCell class])]
                          },
//                      @{
//                          LHFunctionImage :[UIImage imageNamed:@"functionCell2"],
//                          LHFunctionTxt : (NSString *)[LHToolManager keyPath:LHCodeAddLock withClass:NSStringFromClass([LHFounctionCollectionViewCell class])]
//                          },
                      
                      @{
                          LHFunctionImage :[UIImage imageNamed:@"functionCell1"],
                          LHFunctionTxt : (NSString *)[LHToolManager keyPath:LHMyLock withClass:NSStringFromClass([LHFounctionCollectionViewCell class])]
                          },
                      @{
                          LHFunctionImage :[UIImage imageNamed:@"functionCell3"],
                          LHFunctionTxt :(NSString *)[LHToolManager keyPath:LHOpeningRecord withClass:NSStringFromClass([LHFounctionCollectionViewCell class])]
                          },
                      @{
                          LHFunctionImage :[UIImage imageNamed:@"functionCell5"],
                          LHFunctionTxt : (NSString *)[LHToolManager keyPath:LHMessage withClass:NSStringFromClass([LHFounctionCollectionViewCell class])]
                          },
                      @{
                          LHFunctionImage :[UIImage imageNamed:@"functionCell8"],
                          LHFunctionTxt : (NSString *)[LHToolManager keyPath:TJFriends withClass:NSStringFromClass([LHFounctionCollectionViewCell class])]
                          }
                      ];
}
-(void)initFunctionControlViewLable
{
    self.acountLable.text = (NSString *)[LHToolManager keyPath:LHAccount withTarget:self];
    
    self.settingLable.text = (NSString *)[LHToolManager keyPath:LHSettings withTarget:self];
    
    self.logoutLable.text = (NSString *)[LHToolManager keyPath:LHLogout withTarget:self];
    
    self.logoutLable.adjustsFontSizeToFitWidth = YES;
    
    self.settingLable.font = [UIFont systemFontOfSize:[LHToolManager isWhatLanguages] == 2 ? 14 : 18];
        
    self.logoutLable.font = [UIFont systemFontOfSize:[LHToolManager isWhatLanguages] == 2 ? 14 : 18];
    
}
#pragma mark - Delegate
#pragma mark - UICollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LHFounctionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    if(indexPath.row == 4)
    {
        [self showNoticeRed:cell];
    }
    
    [cell initCollectionViewCell:self.cellData[indexPath.row]];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.functionDelegate didSelectItemAtIndexPath:indexPath];
}
-(void)showNoticeRed:(LHFounctionCollectionViewCell*)cell
{
    BOOL isNotice = [LHDataManager getBoolValue:LHHaveNotice];
    
    if(isNotice)
    {
        cell.messageImageView.hidden = NO;
        
    }else{
        
        cell.messageImageView.hidden = YES;
    }
}
#pragma mark - common
-(void)refreshFunctionView
{
    [self initFunctionControlViewLable];
    
    [self initCellData];
    
    [self.functionCollectionView reloadData];
}
@end
