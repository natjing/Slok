//
//  TJShareFriendViewController.m
//  Slok
//
//  Created by user on 2018/4/10.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "TJShareFriendViewController.h"
 
#import "TJFriendsTableViewCell.h"
#import "TJShareViewController.h"
#import "FriendsObj.h"
@interface TJShareFriendViewController ()
@property (weak, nonatomic) IBOutlet UITableView *FriendsTableView;

@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;
@property(nonatomic,strong)NSMutableArray *RegisteredArray;//好友列表
@end

@implementation TJShareFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:TJSharefriends withTarget:self];
    
    [self.FriendsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([TJFriendsTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    self.FriendsTableView.delegate = self;
    
    self.FriendsTableView.dataSource = self;
    self.RegisteredArray=[NSMutableArray array];
    [self Getfriends];
    
}

- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//获取好友列表
-(void)Getfriends
{
    
    [LHNetworkManager postGetFriendsList:^(id result, NSError *error) {
        If_Respose_Success(result, error)
        {
            NSLog(@"%@",result);
            [self.RegisteredArray removeAllObjects];
            for (NSDictionary *mainDic in result[LHInfos]) {
                FriendsObj *friendsobj = [[FriendsObj  alloc] init];
                friendsobj.email = mainDic[@"email"];
                friendsobj.name = mainDic[@"name"];
                friendsobj.phone = mainDic[@"phone"];
                friendsobj.user_id = mainDic[@"user_id"];
                [self.RegisteredArray addObject:friendsobj];
            }
            [self.FriendsTableView reloadData];
        }Else_If_Error(result, error)
        {
            
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    switch (indexPath.section) {
       
        case 0:
        {
            FriendsObj *friendsobj =self.RegisteredArray[indexPath.row];
            if(friendsobj.name.length>1){
                cell.UserName.text = friendsobj.name;
            }else{
                if(friendsobj.email.length>1){
                    cell.UserName.text = friendsobj.email;
                }else{
                    cell.UserName.text = friendsobj.phone;
                }
            }
            cell.AcceptButton.hidden=YES;
            
            cell.IgnoreButton.hidden=YES;
        }
            break;
            
        default:
            break;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
                return self.RegisteredArray.count;
            break;
        default:
            return 0;
            break;
    }
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
        return 1;
  
}
//tableView每一个view的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
              FriendsObj *friendsobj =self.RegisteredArray[indexPath.row];
            [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
                if(status)
                {
                    LHShowHUB(hud);
                    [LHNetworkManager postShareFriend:friendsobj.user_id lockid:self.lock_id handle:^(id result, NSError *error){
                        LHHideHUB(hud);
                        If_Respose_Success(result, error)
                        {
                            TJShareViewController *viewController=nil;
                            
                            for (UIViewController *tempVc in self.navigationController.viewControllers) {
                                
                                if ([tempVc isKindOfClass:[TJShareViewController class]]) {
                                    
                                    viewController=tempVc;
                                    viewController.ifRefresh= YES;
                                }
                            }
                            [self.navigationController popToViewController:viewController animated:YES];
                        }else{
                            NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:LHShareError withTarget:self]];
                            
                            LHProgressHUD(message);
                        }
                    }];
                    
                }else{
                    LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
                }
            }];

        }
            break;
        default:
            break;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LHSW, 25)];
    
    headView.backgroundColor = LHRGBColor(59,53, 72);
    
    UILabel *sectionLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, LHSW - 15, 25)];
    
    sectionLable.font = [UIFont systemFontOfSize:13];
    
    sectionLable.textColor = LHRGBColor(105, 102, 115);
    
    [headView addSubview:sectionLable];
    
    switch (section) {
        case 0:
        {
            if(self.RegisteredArray.count==0){
                    sectionLable.text =(NSString *)[LHToolManager keyPath:TJnofriends withTarget:self];
                }else{
                    sectionLable.text =(NSString *)[LHToolManager keyPath:TJFriendsView withTarget:self];
                }
           
        }
            break;
        default:
            break;
    }
    
    return headView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
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
