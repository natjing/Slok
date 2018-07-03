//
//  CommonMenuView.m
//  PopMenuTableView
//
//  Created by  on 2016/12/1.
//  Copyright © 2016年 KongPro. All rights reserved.
//

#import "NewCommonMenuView.h"
#import "UIView+AdjustFrame.h"
#import "MenuModelViewController.h"
#import "MenuModel.h"

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define ckMenuTag 2017122
#define ckCoverViewTag 2017222
#define kMargin 0   //8
#define kTriangleHeight 0 // 三角形的高10
#define kRadius 0 // 圆角半径
#define KDefaultMaxValue 6  // 菜单项最大值

@interface NewCommonMenuView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,strong) NewCommonMenuView * selfMenu;
@property (nonatomic,strong) UITableView * contentTableView;
@property (nonatomic,strong) NSMutableArray * menuDataArray;
@end

@implementation NewCommonMenuView {
    UIView *_backView;
    //CGFloat arrowPointX; // 箭头位置
}

- (void)setMenuDataArray:(NSMutableArray *)menuDataArray{
    if (!_menuDataArray) {
        _menuDataArray = [NSMutableArray array];
    }
    [menuDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[MenuModel class]]) {
            MenuModel *model = [MenuModel MenuModelWithDict:(NSDictionary *)obj];
            [_menuDataArray addObject:model];
        }
    }];
}

- (void)setMaxValueForItemCount:(NSInteger)maxValueForItemCount{
    if (maxValueForItemCount <= KDefaultMaxValue) {
        _maxValueForItemCount = maxValueForItemCount;
    }else{
        _maxValueForItemCount = KDefaultMaxValue;
    }
}


- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self setUpUI];
    }
    return self;
}
- (void)setUpUI{
    self.backgroundColor = [UIColor colorWithRed:254/255.0 green:92/255.0 blue:90/255.0 alpha:1];
    
    //arrowPointX = self.width * 0.5;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTriangleHeight+20, self.width, self.height)];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.bounces = NO;
    tableView.rowHeight = 40;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([MenuModelViewController class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
    self.contentTableView = tableView;
    
    self.height = tableView.height + kTriangleHeight * 2 - 0.5;
    self.alpha = 0;
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    backView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    [backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapd:)]];
    backView.alpha = 0;
    backView.tag = ckCoverViewTag;
    _backView = backView;
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    
    CAShapeLayer *lay = [self getBorderLayer];
    self.layer.mask = lay;
    [self addSubview:tableView];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    }


#pragma mark --- TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuDataArray.count;
}

- (MenuModelViewController *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MenuModel *model = self.menuDataArray[indexPath.row];
    MenuModelViewController *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"  forIndexPath:indexPath];
  
    cell.backgroundColor = [UIColor blackColor];
    cell.menuModel = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MenuModel *model = self.menuDataArray[indexPath.row];
    if (self.itemsClickBlock) {
        self.itemsClickBlock(model.itemName,indexPath.row +1);
    }
}

#pragma mark --- 关于菜单展示
- (void)displayAtPoint:(CGPoint)point{
    
    point = [self.superview convertPoint:point toView:self.window];
    self.layer.affineTransform = CGAffineTransformIdentity;
    [self adjustPosition:point]; // 调整展示的位置 - frame
    // 调整layer
    CAShapeLayer *layer = [self getBorderLayer];
    if (self.max_Y> kScreenHeight) {
        layer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        layer.transform = CATransform3DRotate(layer.transform, M_PI, 0, 0, 1);
        self.y = point.y - self.height;
    }
    
    // 调整frame
    CGRect rect = self.frame;
    self.frame = rect;
    
    self.layer.mask = layer;
    self.layer.affineTransform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        _backView.alpha = 0.3;
        self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)adjustPosition:(CGPoint)point{
    self.x = point.x - self.width * 0.5;
    self.y = point.y + kMargin;
    if (self.x < kMargin) {
        self.x = kMargin;
    }else if (self.x > kScreenWidth - kMargin - self.width){
        self.x = kScreenWidth - kMargin - self.width;
    }
    self.layer.affineTransform = CGAffineTransformMakeScale(1.0, 1.0);
}

- (void)updateFrameForMenu{
    NewCommonMenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckMenuTag];
    menuView.maxValueForItemCount = menuView.menuDataArray.count;
    menuView.transform = CGAffineTransformMakeScale(1.0, 1.0);;
    menuView.contentTableView.height = 45 * menuView.maxValueForItemCount;
    menuView.height = 45 * menuView.maxValueForItemCount + kTriangleHeight * 2 - 0.5;
    menuView.layer.mask = [menuView getBorderLayer];
    menuView.transform = CGAffineTransformMakeScale(0.01, 0.01);
}

- (void)hiddenMenu{
    self.contentTableView.contentOffset = CGPointMake(0, 0);
    [UIView animateWithDuration:0.25 animations:^{
        self.layer.affineTransform = CGAffineTransformMakeScale(0.01, 0.01);
        self.alpha = 0;
        _backView.alpha = 0;
    }];
}

- (void)tapd:(UITapGestureRecognizer *)sender{
    if (self.backViewTapBlock) {
        self.backViewTapBlock();
    }
    [self hiddenMenu];
    
}
- (CAShapeLayer *)getBorderLayer{
 
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.frame = self.bounds;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, kTriangleHeight + kRadius)];
 
    [bezierPath addLineToPoint:CGPointMake(self.width - kRadius, kTriangleHeight)];
 
    [bezierPath addLineToPoint:CGPointMake(self.width, self.height - kTriangleHeight - kRadius)];
 
    [bezierPath addLineToPoint:CGPointMake(kRadius, self.height - kTriangleHeight)];
    
    [bezierPath addLineToPoint:CGPointMake(0, kTriangleHeight + kRadius)];
    [bezierPath closePath];
    borderLayer.path = bezierPath.CGPath;
    return borderLayer;
}

#pragma mark --- 类方法封装
+ (NewCommonMenuView *)createMenuWithFrame:(CGRect)frame target:(UIViewController *)target dataArray:(NSArray *)dataArray itemsClickBlock:(void(^)(NSString *str, NSInteger tag))itemsClickBlock backViewTap:(void(^)())backViewTapBlock{
    
    CGFloat menuWidth = frame.size.width ? frame.size.width : 120;
    
    NewCommonMenuView *menuView = [[NewCommonMenuView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 45 * dataArray.count+20)];
    menuView.selfMenu = menuView;
    menuView.itemsClickBlock = itemsClickBlock;
    menuView.backViewTapBlock = backViewTapBlock;
    menuView.menuDataArray = [NSMutableArray arrayWithArray:dataArray];
    menuView.maxValueForItemCount = 6;
    menuView.tag = ckMenuTag;
    return menuView;
}

+ (void)showMenuAtPoint:(CGPoint)point{
    NewCommonMenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckMenuTag];
    [menuView displayAtPoint:point];
}

+ (void)hidden{
    NewCommonMenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckMenuTag];
    [menuView hiddenMenu];
}
 

+ (void)clearMenu{
    [NewCommonMenuView hidden];
    NewCommonMenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckMenuTag];
    UIView *coverView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckCoverViewTag];
    [menuView removeFromSuperview];
    [coverView removeFromSuperview];
}

+ (void)appendMenuItemsWith:(NSArray *)appendItemsArray{
    NewCommonMenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckMenuTag];
    NSMutableArray *tempMutableArr = [NSMutableArray arrayWithArray:menuView.menuDataArray];
    [tempMutableArr addObjectsFromArray:appendItemsArray];
    menuView.menuDataArray = tempMutableArr;
    [menuView.contentTableView reloadData];
    [menuView updateFrameForMenu];
}

+ (void)updateMenuItemsWith:(NSArray *)newItemsArray{
    NewCommonMenuView *menuView = [[UIApplication sharedApplication].keyWindow viewWithTag:ckMenuTag];
    [menuView.menuDataArray removeAllObjects];
    menuView.menuDataArray = [NSMutableArray arrayWithArray:newItemsArray];
    [menuView.contentTableView reloadData];
    [menuView updateFrameForMenu];
}
@end
