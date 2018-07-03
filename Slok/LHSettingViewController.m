//
//  LHSettingViewController.m
//  Slok
//
//  Created by LiuHao on 2017/5/27.
//  Copyright © 2017年 LiuHao. All rights reserved.
//

#import "LHSettingViewController.h"
#import "LHSettingTableViewCell.h"
#import "LHVoiceSettingTableViewCell.h"
#import "LHSeettingPasswordViewController.h"
#import "LHHelp.h"
@interface LHSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *settingTableView;
@property (weak, nonatomic) IBOutlet UILabel *navTitleLable;

@end

@implementation LHSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self settingSubViewInViewController];
}
-(void)settingSubViewInViewController
{
    self.settingTableView.bounces = NO;
    
    self.settingTableView.dataSource = self;
    
    self.settingTableView.delegate = self;
    
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHSettings withTarget:self];
    
    [self.settingTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LHSettingTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell"];
    
    //添加混音按钮
//    [self.settingTableView registerNib:[UINib nibWithNibName:NSStringFromClass([LHVoiceSettingTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"cell2"];
}
#pragma mark - 事件
- (IBAction)backFontViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changeMixVoice:(UISwitch *)voiceSwitch
{
    voiceSwitch.on = !voiceSwitch.on;
    
    [LHDataManager saveBoolValue:!voiceSwitch.on withKey:LHMixVoice];
}
-(void)switchLanguages
{
    
    NSInteger whatLauage = [LHToolManager isWhatLanguages];
    
    UIAlertController *aler = [UIAlertController alertControllerWithTitle:(NSString *)[LHToolManager keyPath:LHSwitchLanguage withTarget:self] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [aler addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHSimplifiedChinese withTarget:self] style:whatLauage == 0 ? UIAlertActionStyleDefault :UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if([LHToolManager isWhatLanguages] != 1)
        {
            [LHDataManager saveBoolValue:YES withKey:LHIsManualLanguage];
            
            [LHToolManager changeChineseLanguages];
            
            [self refreshCurrentView];
        }
        
    }]];
    
    [aler addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHEnglish withTarget:self] style:whatLauage == 1 ?  UIAlertActionStyleDefault :UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if([LHToolManager isWhatLanguages]!= 0)
        {
            [LHDataManager saveBoolValue:YES withKey:LHIsManualLanguage];
            
            [LHToolManager changeEglishLanguages];
            
            [self refreshCurrentView];
        }
    }]];
    
    [aler addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHItalian withTarget:self] style:whatLauage == 2 ?  UIAlertActionStyleDefault :UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if([LHToolManager isWhatLanguages] != 2)
        {
            [LHDataManager saveBoolValue:YES withKey:LHIsManualLanguage];
            
            [LHToolManager changeItalyLanguges];
            
            [self refreshCurrentView];
        }
    }]];
    
    [aler addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHFrench withTarget:self] style:whatLauage == 3 ?  UIAlertActionStyleDefault :UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if([LHToolManager isWhatLanguages] != 3)
        {
            [LHDataManager saveBoolValue:YES withKey:LHIsManualLanguage];
            
            [LHToolManager changeFrenchLaunguages];
            
            [self refreshCurrentView];
        }
    }]];
    
    [aler addAction:[UIAlertAction actionWithTitle:(NSString *)[LHToolManager keyPath:LHCancel withTarget:self] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:aler animated:YES completion:nil];
}
#pragma mark - Delegate
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(![XWRegularExpression detectionIsEmailQualified:[LHToolManager getUserType]])
    {
        return 2;
    }else{
    return 3;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
//        case 0:
//        {
//            LHVoiceSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
//            
//            cell.mixVoiceLable.text = (NSString *)[LHToolManager keyPath:LHSoundMixing withTarget:self];
//            
//            cell.mixVoiceSwitch.onTintColor = LHRGBColor(253.0, 167.0, 88.0);
//            
//            [cell.mixVoiceSwitch addTarget:self action:@selector(changeMixVoice:) forControlEvents:UIControlEventValueChanged];
//            
//            cell.mixVoiceSwitch.on = ![LHDataManager getBoolValue:LHMixVoice];
//            
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
//            break;
        case 0:
        {
            LHSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            
            cell.functionStaticLable.text = (NSString *)[LHToolManager keyPath:LHSwitchLanguage withTarget:self];
            cell.functionBackLable.text = (NSString *)[LHToolManager keyPath:LHLanguage withTarget:self];
            return cell;
        }
            break;
        case 1:
        {
            LHSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            
            cell.functionStaticLable.text = (NSString *)[LHToolManager keyPath:LHVersionNumber withTarget:self];
            cell.functionBackLable.text = [NSString stringWithFormat:@"V%@",[LHToolManager appVersion]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 2:
        {
            LHSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            
            cell.functionStaticLable.text = (NSString *)[LHToolManager keyPath:LHSeetingPassName withTarget:self];
            cell.functionBackLable.text =@"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        default:
            break;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            [self switchLanguages];
        }
            break;
        case 2:
        {
            LHSeettingPasswordViewController *viewController = [[LHSeettingPasswordViewController alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - private
-(void)refreshCurrentView
{
    self.navTitleLable.text = (NSString *)[LHToolManager keyPath:LHSettings withTarget:self];
    
    [self.settingTableView reloadData];
    
    [self.languageDelegate isRefreshViewToChangeLanguage];
}


-(void)viewDidAppear:(BOOL)animated
{
    if (_ifshow) {
        _ifshow=NO;
        LHProgressHUD((NSString *)[LHToolManager keyPath:LHSuccess withTarget:self]);
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
