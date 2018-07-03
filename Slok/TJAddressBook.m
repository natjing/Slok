//
//  TJAddressBook.m
//  Slok
//
//  Created by user on 2018/3/28.
//  Copyright © 2018年 LiuHao. All rights reserved.
//

#import "TJAddressBook.h"

@implementation TJAddressBook


- (void)accessAddressBook:(void(^)(NSArray * models))completionHandler {
    if ([self terminate]) return;
    //if (Before9) {
        [self accessAddressBookBefore9:completionHandler];
   // }else {
   //     [self accessAddressBookLater9:completionHandler];
   // }
}

- (void)accessAddressBookLater9:(void(^)(NSArray * models))completionHandler {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    CNContactStore *store = [[CNContactStore alloc] init];
    
    if (status == CNAuthorizationStatusAuthorized) {
        [self accessContacts:store andResult:completionHandler];
        return;
    }
    
    if (status == CNAuthorizationStatusNotDetermined) {
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [self accessContacts:store andResult:completionHandler];
            }else {
                [self alert];
            }
        }];
        return;
    }
    
    if (status == CNAuthorizationStatusDenied) {
        [self alert];
    }
}

- (void)accessAddressBookBefore9:(void(^)(NSArray * models))completionHandler {
    ABAuthorizationStatus  status = ABAddressBookGetAuthorizationStatus();
    ABAddressBookRef addressBookRef = ABAddressBookCreate();
    
    if (status == kABAuthorizationStatusAuthorized) {
        [self accessABAddressBook:addressBookRef andResult:completionHandler];
    }else if (status == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self accessABAddressBook:addressBookRef andResult:completionHandler];
            }else {
                [self alert];
            }
        });
    }else if (status == kABAuthorizationStatusDenied) {
        [self alert];
    }
    
    if (addressBookRef) {
        CFRelease(addressBookRef);
    }
}

- (void)accessABAddressBook:(ABAddressBookRef)addressBookRef andResult:(void(^)(NSArray * models))completionHandler {
    CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (int i = 0; i< CFArrayGetCount(arrayRef); i++) {
        ABRecordRef people = CFArrayGetValueAtIndex(arrayRef, i);
        NSString *identify = [NSString stringWithFormat:@"%d",ABRecordGetRecordID(people)];
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
        NSString *name = [[NSString alloc] init];
        if (firstName) {
            name = [name stringByAppendingString:firstName];
        }
        if (lastName) {
            name = [name stringByAppendingString:lastName];
        }
        
        ABMutableMultiValueRef  phonesArray = ABRecordCopyValue(people, kABPersonPhoneProperty);
        NSString *phoneNumber = @"";
        for (int j = 0; j < ABMultiValueGetCount(phonesArray); j++) {
            NSString *phone = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phonesArray, j));
            if (phone) {
                phone = [phone stringByAppendingString:@";"];
                phoneNumber = [phoneNumber stringByAppendingString:phone];
            }
            
        }
        if([phoneNumber isEqualToString:@""]) {
            continue;
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"desc",phoneNumber,@"phoneNo",identify,@"deviceRecordId", nil];
        [mutableArray addObject:dic];
    }
    completionHandler([mutableArray copy]);
}

- (void)accessContacts:(CNContactStore *)store andResult:(void(^)(NSArray * models))completionHandler{
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey]];
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSString *firstName = contact.familyName;
        NSString *lastName = contact.givenName;
        NSString *identify = contact.identifier;
        NSString *name = [[NSString alloc] init];
        if (firstName) {
            name = [name stringByAppendingString:firstName];
        }
        if (lastName) {
            name = [name stringByAppendingString:lastName];
        }
        
        NSString *phoneNumber = @"";
        for (CNLabeledValue<CNPhoneNumber*> *phone in contact.phoneNumbers) {
            NSString *number = phone.value.stringValue;
            if (number) {
                number = [number stringByAppendingString:@";"];
                phoneNumber = [phoneNumber stringByAppendingString:number];
            }
        }
        if ([phoneNumber isEqualToString:@""]) {
            return ;
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:name,@"desc",phoneNumber,@"phoneNo",identify,@"deviceRecordId", nil];
        [mutableArray addObject:dic];
    }];
    completionHandler([mutableArray copy]);
}

- (void)alert {
//    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
//    [controller alertSure:^{
//        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
//    } message:@"为了成功贷款，请您前往设置页面允许应用访问通讯录"];
}
- (BOOL)terminate {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"time"];
    NSDate *currentDate = [NSDate date];
    if (date) {
        NSTimeInterval time = [currentDate timeIntervalSinceDate:date];
        if (time < 24*60*60) return YES;
        [self saveTime:currentDate];
    }else {
        [self saveTime:currentDate];
    }
    return NO;
}
- (void)saveTime:(NSDate *)time {
    [[NSUserDefaults standardUserDefaults] setObject:time forKey:@"time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
