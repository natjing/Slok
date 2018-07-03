//
//  TJSearchViewController.m
//  Slok
//
//  Created by user on 2018/3/27.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "TJSearchViewController.h"
#import "TJSearchTableViewCell.h"
#import "FriendsObj.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <MessageUI/MessageUI.h> 
@interface TJSearchViewController ()<MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *ControllerName;
@property (weak, nonatomic) IBOutlet UITextField *SearchBar; 
@property (weak, nonatomic) IBOutlet UITableView *ResultsTableView;
@property (weak, nonatomic) IBOutlet UIButton *SearchButton;

@property(nonatomic,strong)NSMutableArray *SearchArray;//搜索结果
@property(nonatomic,strong)NSMutableArray *RegisteredArray;//通讯录
@property (nonatomic,strong)UITapGestureRecognizer *tap;
@property (nonatomic,assign)NSInteger selectIndex;
@property (weak, nonatomic) MBProgressHUD *hud;
@end

@implementation TJSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.selectIndex=0;
    self.SearchArray= [NSMutableArray array];
    self.RegisteredArray= [NSMutableArray array];
    self.ControllerName.text = (NSString *)[LHToolManager keyPath:TJSearchView withTarget:self];
    self.SearchBar.placeholder = (NSString *)[LHToolManager keyPath:TJsearchfor withTarget:self];
    
    [self.SearchBar setValue:LHRGBColor(101, 92, 131) forKeyPath:@"_placeholderLabel.textColor"];
    
    
    [self.SearchButton setTitle:(NSString *)[LHToolManager keyPath:TJChercher withTarget:self] forState:UIControlStateNormal];
    [self.ResultsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([TJSearchTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    self.ResultsTableView.delegate = self;
    
    self.ResultsTableView.dataSource = self;
    
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backKingboard:)];
    self.tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tap];
    [self visitAddressBook];
}
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)SearchButtonClick:(id)sender {
    
    self.SearchBar.text = [LHToolManager removeSpaceAndNewline:self.SearchBar.text];
    
    if(self.SearchBar.text.length>=3)
    {
        [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
            if(status)
            {
                LHShowHUB(hud);
                [LHNetworkManager postSearchFriends:self.SearchBar.text handle:^(id result, NSError *error) {
                    LHHideHUB(hud);
                    If_Respose_Success(result, error)
                    {
                        NSLog(@"%@",result);
                        [self.SearchArray removeAllObjects];
                        for (NSDictionary *mainDic in result[LHInfos]) {
                            FriendsObj *friendsobj = [[FriendsObj  alloc] init];
                            friendsobj.email = mainDic[@"email"];
                            friendsobj.name = mainDic[@"name"];
                            friendsobj.phone = mainDic[@"phone"];
                            friendsobj.user_id = mainDic[@"user_id"];
                            if(![[LHToolManager getUserId] isEqualToString:friendsobj.user_id]){
                                [self.SearchArray addObject:friendsobj];
                            }
                            
                        }
                        [self.ResultsTableView reloadData];
                       
                        if(self.SearchArray.count==0){
                            //搜索返回数据为空
                            NSString *qwertyu = (NSString *)[LHToolManager keyPath:TJNotfound withTarget:self];
                             LHProgressHUD(qwertyu);
                        }
                       
                    }else{
                       //搜索结果无法解析
                    }
                }];
                
            }else{
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
            }
        }];
        
    }else{
        LHProgressHUD((NSString *)[LHToolManager keyPath:TJSearchfortip withTarget:self]);
    }
}
//访问通讯录
-(void)visitAddressBook
{
    // if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined) {
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            
            // 2. 获取联系人仓库
            CNContactStore * store = [[CNContactStore alloc] init];
            // 3. 创建联系人信息的请求对象
            NSArray * keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
            // 4. 根据请求Key, 创建请求对象
            CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
            // 5. 发送请求
            [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                // LHShowHUB(hud);
                NSString *language = [NSString stringWithFormat:@"%d",![LHToolManager isWhatLanguages]];
                // 6.1 获取姓名
                NSString * givenName = contact.givenName;
                NSString * familyName = contact.familyName;
                NSLog(@"%@--%@", givenName, familyName);
                // 6.2 获取电话
                NSArray * phoneArray = contact.phoneNumbers;
                for (CNLabeledValue * labelValue in phoneArray) {
                    FriendsObj *fri=[[FriendsObj alloc]  init];
                    if([language isEqualToString:@"1"]){
                        fri.name=[familyName stringByAppendingString:givenName];
                    }else{
                        fri.name= [givenName stringByAppendingString:familyName];
                    }
                    CNPhoneNumber * number = labelValue.value;
                    fri.phone = [number.stringValue stringByReplacingOccurrencesOfString:@"-"withString:@""];
                    
                    //NSLog(@"%@--%@", number.stringValue, labelValue.label);
                    [self.RegisteredArray addObject:fri];
                }
                //LHHideHUB(hud);
            }];
            [self.ResultsTableView reloadData];
            [self GetFriendsData];
        }
    }];
    // }
}
- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Delegate
#pragma mark - Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    switch (indexPath.section) {
        case 0:
        {
            if(self.SearchArray.count!=0){
            FriendsObj *friendsobj =self.SearchArray[indexPath.row];
            cell.useraccount.text =friendsobj.name;
            if(friendsobj.phone.length>1){
                cell.usercontact.text=friendsobj.phone;
            }else{
                cell.usercontact.text=friendsobj.email;
            }
                
                [cell.addbutton setTitle:(NSString *)[LHToolManager keyPath:LHAdd withTarget:self] forState:UIControlStateNormal];
             }else{
                 FriendsObj *friendsobj =self.RegisteredArray[indexPath.row];
                 cell.useraccount.text =friendsobj.name;
                 
                 if(friendsobj.phone.length>1){
                     cell.usercontact.text=friendsobj.phone;
                     
                     
                 }else{
                     cell.usercontact.text=friendsobj.email;
                     
                 }
                 if(friendsobj.user_id.length>1){
                     [cell.addbutton setTitle:(NSString *)[LHToolManager keyPath:LHAdd withTarget:self]forState:UIControlStateNormal];
                 }else{
                      [cell.addbutton setTitle:(NSString *)[LHToolManager keyPath:TJInvitestr withTarget:self] forState:UIControlStateNormal];
                    
                 }
             }
        }
            break;
        case 1:
        {
            FriendsObj *friendsobj =self.RegisteredArray[indexPath.row];
            cell.useraccount.text =friendsobj.name;
            if(friendsobj.phone.length>1){
                cell.usercontact.text=friendsobj.phone;
                
                
            }else{
                cell.usercontact.text=friendsobj.email;
                
            }
            if(friendsobj.user_id.length>1){
                [cell.addbutton setTitle:(NSString *)[LHToolManager keyPath:LHAdd withTarget:self]forState:UIControlStateNormal];
            }else{
                [cell.addbutton setTitle:(NSString *)[LHToolManager keyPath:TJInvitestr withTarget:self] forState:UIControlStateNormal];
                
            }
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
            if(self.SearchArray.count==0){
                return self.RegisteredArray.count;
            }
            return self.SearchArray.count;
            
            break;
        case 1:
            return self.RegisteredArray.count;
            break;
            
        default:
            return 0;
            break;
    }
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.SearchArray.count==0){
         return 1;
    }
    return 2;
}
//tableView每一个view的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if(self.SearchArray.count!=0){
            FriendsObj *friendsobj =self.SearchArray[indexPath.row];
            [self postAddFriends:friendsobj.user_id];
            }else{
                FriendsObj *friendsobj =self.RegisteredArray[indexPath.row];
                if(friendsobj.user_id.length>1){
                    [self postAddFriends:friendsobj.user_id];
                }else{
                    [self allowShareToMessage:friendsobj.phone];
                }
            }
        }
            break;
        case 1:
        {
            FriendsObj *friendsobj =self.RegisteredArray[indexPath.row];
            if(friendsobj.user_id.length>1){
                [self postAddFriends:friendsobj.user_id];
            }else{
                [self allowShareToMessage:friendsobj.phone];
            }
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
             if(self.SearchArray.count!=0){
            sectionLable.text =(NSString *)[LHToolManager keyPath:TJSearchresults withTarget:self];
             }else{
                 sectionLable.text = (NSString *)[LHToolManager keyPath:TJContacts withTarget:self];
             }
            
        }
            break;
        case 1:
        {
            sectionLable.text = (NSString *)[LHToolManager keyPath:TJContacts withTarget:self];
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
//提交添加好友的请求
-(void)postAddFriends:(NSString *)userid{
    [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
        if(status)
        {
            LHShowHUB(hud);
            [LHNetworkManager postAddFriends:userid handle:^(id result, NSError *error) {
                LHHideHUB(hud);
                If_Respose_Success(result, error)
                {
                     
                    LHProgressHUD((NSString *)[LHToolManager keyPath:TJAddrequest withTarget:self]);
                }else{
                    NSString *message = [LHToolManager findErrorDetailInErrorList:result error:error withAutoErrorMessage:(NSString *)[LHToolManager keyPath:TJAddrequestfailur withTarget:self]];
                    
                    LHProgressHUD(message);
                }
            }];
            
        }else{
            LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
        }
    }];
}
//获取通讯录对应用户的信息
-(void)GetFriendsData{
    NSString *phone=@"";
    
    for (NSInteger i=self.selectIndex; i<self.RegisteredArray.count; i++) {
       
        FriendsObj *friendsobj =self.RegisteredArray[i];
        if(i==self.selectIndex){
            phone = [[NSString alloc] initWithFormat:@"%@%@", phone, friendsobj.phone];
        }else{
            phone = [[NSString alloc] initWithFormat:@"%@%@%@", phone,@"_", friendsobj.phone];
        }
        if(i-self.selectIndex==30){
            break;
        }
       
    }
        [LHNetworkManager isNetworkReachability:^(AFNetworkReachabilityStatus status) {
            if(status)
            {
                if(self.selectIndex==0){
                    
                    LHShowHUB(hud);
                    self.hud=hud;
                }
                [LHNetworkManager postGetFriendsData:phone handle:^(id result, NSError *error) {
                    if(self.selectIndex==0){
                        LHHideHUB(self.hud);
                    }
                    If_Respose_Success(result, error)
                    {
                        NSInteger lag=0;
                        for (NSDictionary *mainDic in result[LHInfos]) {
                            NSInteger ads=self.selectIndex+lag;
                           if(ads>=self.RegisteredArray.count){
                                break;
                            }
                            FriendsObj *friendsobj =[self.RegisteredArray objectAtIndex:ads];
                            friendsobj.user_id = mainDic[@"user_id"];
                            if ([[LHToolManager getUserId] isEqualToString:friendsobj.user_id]) {
                                [self.RegisteredArray removeObject:friendsobj];
                                lag=lag-1;
                                
                            }
                            for (int i = 0; i < [self.mRegisteredArray count]; i++) {
                                FriendsObj *mfriendsobj =[self.mRegisteredArray objectAtIndex:i];
                                if ([mfriendsobj.user_id isEqualToString:friendsobj.user_id]) {
                                    [self.RegisteredArray removeObject:friendsobj];
                                    lag=lag-1;
                                }
                                
                            }
                            lag=lag+1;
                        }
                        self.selectIndex=self.selectIndex+lag;
                        [self.ResultsTableView reloadData];
                        if(self.selectIndex<self.RegisteredArray.count){
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                                [self GetFriendsData];
                                
                            });
                        }
                    }else{
                        
                    }
                }];
                
            }else{
                LHProgressHUD((NSString *)[LHToolManager keyPath:LHNetworkError withTarget:self]);
            }
        }];
    
}
#pragma mark - private
-(void)allowShareToMessage:(NSString *)phone
{
    if( [MFMessageComposeViewController canSendText] )
        
    {
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        
        controller.recipients =@[phone];
        // controller.body = [NSString stringWithFormat:@"我将%@的临时钥匙分享給你了(%@分钟内有效),点击%@",@"",timestr,url];
        controller.body=(NSString *)[LHToolManager keyPath:TJSmscontent withTarget:self];
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:(NSString *)[LHToolManager keyPath:LHPrompt withTarget:self] message:(NSString *)[LHToolManager keyPath:TJDoessms withTarget:self] delegate:nil cancelButtonTitle:(NSString *)[LHToolManager keyPath:LHConfirm withTarget:self]otherButtonTitles:nil, nil];
        
        [alert show];
    }
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result

{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
            
        case MessageComposeResultSent:
            
            //信息传送成功
        {
            //LHProgressHUD(@"信息传送成功");
        }
            
            break;
            
        case MessageComposeResultFailed:
            
            //信息传送失败
        {
            //LHProgressHUD(@"信息传送失败");
        }
            break;
            
        case MessageComposeResultCancelled:
            
            //信息被用户取消传送
        {
            //LHProgressHUD(@"信息取消传送");
        }
            break;
            
        default:
            
            break;
            
    }
}
#pragma mark - 系统状态栏
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
-(void)backKingboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}


@end
