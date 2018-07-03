//
//  LHMyLockViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/27.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHMyLockViewController.h"
#import "LHMyLockTableViewCell.h"
#import "LHShareListViewController.h"
@interface LHMyLockViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property (weak, nonatomic) IBOutlet UITableView *myLockTableView;

@end

@implementation LHMyLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingSubViewInViewController];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    if(!locks.count)
    {
       LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoLock withTarget:self]);
    }
}
-(void)settingSubViewInViewController
{
    [LHToolManager.rootViewController setRefreshBlock:^{
        [self.myLockTableView reloadData];
    }];
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHNavTitle withTarget:self];
    
    self.myLockTableView.dataSource = self;
    
    self.myLockTableView.delegate = self;
    [self.myLockTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LHMyLockTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
    
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    return locks.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LHMyLockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    LHLock *lock = OBJECT_AT_INDEX(locks, indexPath.row);
    
    cell.lockNameLable.text = lock.lockName;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LHShareListViewController *viewController = [[LHShareListViewController alloc] init];
    
    NSArray *locks = [LHDataManager LH_FineFmdbKey:LHLockFmdb withFmdbClass:[LHLock class]];
    
    LHLock *lock = OBJECT_AT_INDEX(locks, indexPath.row);
    
//    if([lock.lockType isEqualToString:@"0"])
//    {
        viewController.selectLock = lock;
    
        [self.navigationController pushViewController:viewController animated:YES];
//    }else{
//
//        LHProgressHUD((NSString *)[LHToolManager keyPath:LHNoSharePower withTarget:self]);
//    }
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
