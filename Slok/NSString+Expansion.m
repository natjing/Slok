//
//  NSString+Expansion.m
//  SmartDevice
//
//  Created by wei feng on 15/6/30.
//  Copyright (c) 2015年 wei feng. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Expansion.h"

@implementation NSString (Expansion)

+ (NSString *)randomStringWithLength:(NSInteger)length;
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    return randomString;
}

- (NSString *)stringWithURLEncoding
{
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

- (NSString *) md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSNumber *)numberValue
{
    NSNumber *result = nil;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    result = [formatter numberFromString:self];
    
    return result;
}

- (NSString *)setterString
{
    if (self.length == 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"set%@%@:", [[self substringToIndex:1] capitalizedString], [self substringFromIndex:1]];
}

- (NSDate *)date;
{
    return [self dateWithFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
}

- (NSDate *)dateWithFormat:(NSString *)formatter;
{
    NSLocale *POSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:POSIXLocale];
    [dateFormatter setDateFormat:formatter];
    NSDate *date = [dateFormatter dateFromString:self];
    
    return date;
}

+ (NSString *)timestemp
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%d", (int)time];
}

- (NSInteger)characterCount;
{
    NSInteger i,n = [self length],l=0,a=0,b=0;
    unichar c;
    
    for(i = 0; i < n; i++)
    {
        c = [self characterAtIndex:i];
        
        if(isblank(c))
        {
            b++;
        }
        else if(isascii(c))
        {
            a++;
        }
        else
        {
            l++;
        }
    }
    
    if(a==0 && l==0) return 0;
    
    return l+(int)ceilf((float)(a+b)/2.0);
}

- (BOOL)matches:(NSString *)regex
{
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regextestmobile evaluateWithObject:self];
}

// 正则判断手机号码地址格式
- (BOOL)isMobileNumber
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
//    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
//    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    return [self matches:MOBILE];
}

- (BOOL)isEmail
{
    NSString *email = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{1,5}";
    return [self matches:email];
}

@end
