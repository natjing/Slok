//
//  TJShareViewController.m
//  Slok
//
//  Created by user on 2018/4/10.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "TJShareViewController.h"
#import "LHShareListViewController.h"
#import "LHShareListTableViewCell.h"
#import "LHHeaderShareView.h"
#import "TJShareFriendViewController.h"
#import "LHSettingLockViewController.h"
@interface TJShareViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UITableView *shareListTableView;
 
@property (nonatomic,strong) NSArray *shareLocks;
@end

@implementation TJShareViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initSettingViewController];
    
    [self gainDataToInternet];
}
-(void)initSettingViewController
{
    self.navTitleLable.text = self.selectLock.lockName;
    
    self.shareListTableView.dataSource = self;
    
    self.shareListTableView.delegate = self;
    
    [self.shareListTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LHShareListTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
    [self addHeaderViewInTableView];
    
    UILabel *noShareLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, LHSW - 20, 40)];
    
    noShareLable.font = [UIFont systemFontOfSize:15.0];
    
    noShareLable.textColor = LHRGBColor(165, 165, 165);
    
    noShareLable.text  = (NSString *)[LHToolManager keyPath:LHNoShareList withTarget:self];
    
    self.shareListTableView.tableFooterView = noShareLable;
    
    self.shareListTableView.tableFooterView.hidden = YES;
    
}
-(void)addHeaderViewInTableView
{
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LHSW, 90)];
    
    headView.backgroundColor = [UIColor clearColor];
    
    LHHeaderShareView *shareView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([LHHeaderShareView class]) owner:nil options:nil] lastObject];
    
    shareView.frame = CGRectMake(0, 0, LHSW, 90);
    
    shareView.shareLockLable.text = (NSString *)[LHToolManager keyPath:LHShareLock withTarget:self];
    shareView.settingKeyImageView.image = [UIImage imageNamed:@"headerShare1"];
    UITapGestureRecognizer *shareTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareIsBtn:)];
    
    [shareView addGestureRecognizer:shareTap];
    
    [headView addSubview:shareView];
    
    self.shareListTableView.tableHeaderView = headView;
    
}


-(void)gainDataToInternet
{
    [LHNetworkManager postShareLockList:self.selectLock.lockId handle:^(id result, NSError *error) {
        
        If_Respose_Success(result, error)
        {
            self.shareLocks = result[LHInfos];
            
            [self.shareListTableView reloadData];
            
            if(self.shareLocks.count)
            {
                self.shareListTableView.tableFooterView.hidden = YES;
                
            }else{
                
                self.shareListTableView.tableFooterView.hidden = NO;
            }
        }
        
    }];
}

#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)shareIsBtn:(UITapGestureRecognizer *)tap
{
    
    TJShareFriendViewController *viewController = [[TJShareFriendViewController alloc] init];
    
    viewController.lock_id = self.selectLock.lockId;
    
    [self.navigationController pushViewController:viewController animated:YES];
}


-(void)deletShareLock:(NSString *)funId
{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postDeleteShareLock:funId handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                    [self gainDataToInternet];
                    
                }else{
                    NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHDeleteError withTarget:self]];
                    
                    LHProgressHUD(message);
                }
            }];
            
        }else{
            
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.shareLocks.count ? 30.0f : 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shareLocks.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LHShareListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    [cell.shareLockDeletButton setTitle:(NSString *)[LHToolManager keyPath:LHShareDelet withTarget:self] forState:UIControlStateNormal];
    
    NSDictionary *mainDic = self.shareLocks[indexPath.row];
    
    
    if(((NSString *)mainDic[LHRShareName]).length>1){
        cell.shareLockNameLable.text = mainDic[LHRShareName];
    }else if(((NSString *)mainDic[@"name"]).length>1){
         cell.shareLockNameLable.text = mainDic[@"name"];
    }else if(((NSString *)mainDic[@"email"]).length>1){
        cell.shareLockNameLable.text = mainDic[@"email"];
    }else{
         cell.shareLockNameLable.text = mainDic[@"phone"];
    }
    
    
    cell.lockData = mainDic;
    
    [cell initShareListTableViewCell];
    
    [cell setRefreshBlock:^(NSDictionary *lockData){
        
        [self deletShareLock:lockData[LHRFunId]];
        
    }];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LHSW, 21)];
    
    UILabel *headerLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, LHSW - 30, 21.0f)];
    
    headerLable.font = [UIFont systemFontOfSize:16.0f];
    
    headerLable.textColor = LHRGBColor(180, 180, 180);
    
    headerLable.text = (NSString *)[LHToolManager keyPath:LHShareLockList withTarget:self];
    
    [headerView addSubview:headerLable];
    
    return headerView;
}


-(void)viewDidAppear:(BOOL)animated
{
    if (_ifRefresh) {
        _ifRefresh=NO;
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHShareSuccess withTarget:self]);
        [self gainDataToInternet];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
