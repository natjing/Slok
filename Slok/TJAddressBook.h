//
//  TJAddressBook.h
//  Slok
//
//  Created by user on 2018/3/28.
//  Copyright © 2018年 LiuHao. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
//#import "UIViewController+Tools.h"
//#import "FWDefine.h"
@interface TJAddressBook : NSObject
- (void)accessAddressBook:(void(^)(NSArray *))completionHandler;
@end
