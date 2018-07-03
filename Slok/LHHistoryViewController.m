//
//  LHHistoryViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/27.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHHistoryViewController.h"
#import "LHHistoryTableViewCell.h"
@interface LHHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;
 
@property(nonatomic,strong)NSArray *historyData;
@property(nonatomic,assign)NSInteger limit;
@end

@implementation LHHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingSubViewInViewController];
    
    self.limit = 10;
    
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            [self gainHistoryToNet];
        }
    }];
}
-(void)gainHistoryToNet
{
    [LHNetworkManager postHistoryList:@"0" limit:[NSString stringWithFormat:@"%ld",(long)self.limit] handle:^(id result, NSError *error) {
        If_Respose_Success(result, error)
        {
            NSLog(@"key:%@\n",result);
            NSArray *data = result[LHInfos];
            
            if(data.count == self.historyData.count)
            {
                [self.historyTableView.mj_footer endRefreshingWithNoMoreData];
                
            }else{
                
                [self.historyTableView.mj_footer endRefreshing];
            }
            
            self.historyData = result[LHInfos];
            
            [self.historyTableView reloadData];
            
            [self.historyTableView.mj_header endRefreshing];
        }
    }];
}
-(void)settingSubViewInViewController
{
    [self settingTableViewHeaderRefresh];
    
    [self settingTableViewFooterRefresh];
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHNavTitle withTarget:self];
    
    self.historyTableView.dataSource = self;
    
    self.historyTableView.delegate = self;
    
    [self.historyTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LHHistoryTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
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
    self.historyTableView.mj_header = header;
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
    self.historyTableView.mj_footer = footer;
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
            
            [self gainHistoryToNet];
        }else{
            [self.historyTableView.mj_header endRefreshing];
            
            [self.historyTableView.mj_footer endRefreshing];
        }
    }];
    
}
-(void)loadMoreData
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            self.limit = self.limit + 10;
            
            [self gainHistoryToNet];
            
        }else{
            
            [self.historyTableView.mj_header endRefreshing];
            
            [self.historyTableView.mj_footer endRefreshing];
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyData.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LHHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  
    
    NSDictionary *mainDic = OBJECT_AT_INDEX(self.historyData, indexPath.row);
    
    cell.lockNameLable.text = mainDic[LHLocksName];
    
    cell.timeLable.text = [self getDateStringWithDate:mainDic[LHTime]];
    
    if([mainDic[LHUserId] isEqualToString:[LHToolManager getUserId]])
    {
        cell.userNameLable.text = (NSString *)[LHToolManager keyPath:LHOwmUser withTarget:self];
    }else{
        cell.userNameLable.text = mainDic[LHUserId];
    }
    
    return cell;
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
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    return currentDateStr;
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
