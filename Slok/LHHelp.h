//
//  LHHelp.h
//  LHQuickOpening
//
//  Created by Haoliu on 17/4/11.
//  Copyright © 2017年 supude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"
#define LHToolManager [LHHelp shareInstence]
@interface LHHelp : NSObject
+ (instancetype)shareInstence;
@property(nonatomic,weak)ViewController *rootViewController;
@property(nonatomic,strong)NSString *LoginType;
- (NSArray *)checkNSArrayWithChangeUseful:(NSArray *)checkArray;
- (NSDictionary *)checkNSDictinaryWithChangeUseful:(NSDictionary *)checkDictioary;
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
- (NSString*)appVersion;
-(instancetype)keyPath:(NSString *)key withTarget:(id)target;
-(instancetype)keyPath:(NSString *)key withClass:(NSString *)className;
- (BOOL)cameraPemission;
-(NSInteger)isWhatLanguages;
-(void)changeChineseLanguages;
-(void)changeEglishLanguages;
-(void)changeItalyLanguges;
-(void)changeFrenchLaunguages;
-(NSDictionary *)secrecyParam:(NSDictionary *)param;
-(BOOL)isLogin;
-(NSString *)getUserId;
-(NSString *)getUserPass;

-(void)setLoginType:(NSString *)type;
-(NSString *)getLoginType;

-(NSString *)getUserType;

-(NSString *)findErrorDetailInErrorList:(id)result error:(NSError *)error withAutoErrorMessage:(NSString *)message;
-(void)logout;
-(NSString *)macIpByName:(NSString *)Bname;
- (NSString *)removeSpaceAndNewline:(NSString *)str;
-(NSString *)gainMacToData:(NSData *)data;
@end
