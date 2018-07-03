//
//  NSString+Expansion.h
//  SmartDevice
//
//  Created by wei feng on 15/6/30.
//  Copyright (c) 2015年 wei feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Expansion)

+ (NSString *)randomStringWithLength:(NSInteger)length;

- (NSString *)stringWithURLEncoding;

- (NSString *)md5;

- (NSNumber *)numberValue;

- (NSString *)setterString;

- (NSDate *)date;

- (NSDate *)dateWithFormat:(NSString *)formatter;

+ (NSString *)timestemp;

- (NSInteger)characterCount;

#pragma mark - regex

- (BOOL)matches:(NSString *)regex;
- (BOOL)isMobileNumber;     ///< 验证手机号
- (BOOL)isEmail;            ///< 验证邮箱

@end
