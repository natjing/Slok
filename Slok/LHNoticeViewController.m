//
//  LHNoticeViewController.m
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/27.
//  Copyright © 2017年 supude. All rights reserved.
//

#import "LHNoticeViewController.h"
#import "LHNoticeTableViewCell.h"
@interface LHNoticeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property(nonatomic,strong)NSArray *historyData;
@property(nonatomic,assign)NSInteger limit;
@end

@implementation LHNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.limit = 10;
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            [self gainDataToNet];
        }else{
            self.historyData = [LHDataManager LH_GetJsonDataForKey:LHDeleteHistory];
            
            [self.noticeTableView reloadData];
        }
    }];
    
    [self initSubViewInViewController];
}
-(void)initSubViewInViewController
{
    [self settingTableViewHeaderRefresh];
    
    [self settingTableViewFooterRefresh];
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHMessage withTarget:self];
    
    [self.noticeTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LHNoticeTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
    self.noticeTableView.delegate = self;
    
    self.noticeTableView.dataSource = self;
}
-(void)settingTableViewHeaderRefresh
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    header.automaticallyChangeAlpha = YES;
    
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 设置文字
    [header setTitle:(NSString *)[LHToolManager keyPath:LHRefreshData withTarget:self] forState:MJRefreshStateIdle];
    [header setTitle:(NSString *)[LHToolManager keyPath:LHFinishRefresh withTarget:self] forState:MJRefreshStatePulling];
    [header setTitle:(NSString *)[LHToolManager keyPath:LHLoading withTarget:self] forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = LHRGBColor(105.0, 117.0, 207.0);
    
    // 马上进入刷新状态
    //[header beginRefreshing];
    
    // 设置刷新控件
    self.noticeTableView.mj_header = header;
}
-(void)settingTableViewFooterRefresh
{
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 设置文字
    [footer setTitle:(NSString *)[LHToolManager keyPath:LHLoadingMore withTarget:self] forState:MJRefreshStateIdle];
    [footer setTitle:(NSString *)[LHToolManager keyPath:LHLoading withTarget:self] forState:MJRefreshStateRefreshing];
    [footer setTitle:(NSString *)[LHToolManager keyPath:LHNoMoreData withTarget:self] forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    footer.stateLabel.textColor = LHRGBColor(254.0, 92.0, 90.0);
    
    // 设置footer
    self.noticeTableView.mj_footer = footer;
}
-(void)gainDataToNet
{
    [LHNetworkManager postDeletHistory:@"0" limit:[NSString stringWithFormat:@"%ld",(long)self.limit] handle:^(id result, NSError *error) {
        If_Respose_Success(result, error)
        {
            NSArray *data = result[LHInfos];
            
            if(data.count == self.historyData.count)
            {
                [self.noticeTableView.mj_footer endRefreshingWithNoMoreData];
                
            }else{
                
              [self.noticeTableView.mj_footer endRefreshing];
            }
            
            self.historyData = result[LHInfos];
            
            [self.noticeTableView reloadData];
            
            [self.noticeTableView.mj_header endRefreshing];
            
            [LHDataManager LH_SaveJsonRequestData:result[LHInfos] withKey:LHDeleteHistory];
        }
    }];
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)loadNewData
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            self.limit = 10;
            
            [self gainDataToNet];
        }else{
            
            [self.noticeTableView.mj_header endRefreshing];
            
            [self.noticeTableView.mj_footer endRefreshing];
        }
    }];
}
-(void)loadMoreData
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            self.limit = self.limit + 10;
            
            [self gainDataToNet];
        }else{
            [self.noticeTableView.mj_header endRefreshing];
            
            [self.noticeTableView.mj_footer endRefreshing];
        }
    }];
}
#pragma mark - Delegate
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *mainDic = self.historyData[indexPath.row];
    
    NSString * context = [NSString stringWithFormat:@"%@,%@",mainDic[LHLocksName],(NSString *)[LHToolManager keyPath:LHIsDeleted withTarget:self]];
    
   return [self gainHightWith:context];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LHNoticeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSDictionary *mainDic = self.historyData[indexPath.row];
    
    cell.titleLable.text = (NSString *)[LHToolManager keyPath:LHMessage withTarget:self];
    
    cell.contextLable.text = [NSString stringWithFormat:@"%@,%@",mainDic[LHLocksName],(NSString *)[LHToolManager keyPath:LHIsDeleted withTarget:self]];
    
    cell.releaseLable.text = @"Slok";
    
    cell.timeLable.text = [self getDateStringWithDate:mainDic[LHTime]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
/*
 infos =     (
 {
 "lock_name" = Slok;
 time = 1496320447;
 type = 1;
 },
 {
 "lock_name" = Slok;
 time = 1496318677;
 type = 1;
 }
 );
 */
#pragma mark - Private
-(CGFloat)gainHightWith:(NSString *)context
{
    // 设置文字属性 要和label的一致
    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:15]};
    
    CGSize maxSize = CGSizeMake(LHSW - 60, MAXFLOAT);
    
    // 计算文字占据的高度
    CGSize size = [context boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    
    return size.height + 105;
}
// 时间戳转时间
- (NSString *)getDateStringWithDate:(NSString *)dataStr{
    // dataStr时间戳
    NSTimeInterval time=[dataStr doubleValue];//因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    //    NSLog(@"date:%@",[detaildate description]);
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    return currentDateStr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 系统状态栏
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
