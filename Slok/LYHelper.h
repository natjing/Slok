//
//  LYHelper.h
//  LYCategoryFoundation
//
//  Created by wei feng on 15/11/21.
//  Copyright © 2015年 wei feng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLyricTimeKey   @"lyricTimeKey"
#define kLyricStringKey @"lyricStringkey"

@interface LYHelper : NSObject

/** 硬件设备及系统信息 */
+ (BOOL)isRetina;
+ (BOOL)isiCloudAvailable;
+ (NSString *)platform;
+ (NSString*)version;
+ (NSString*)systemVersion;
+ (NSString*)appName;
+ (NSString*)OpenUDID;

/** 数据本地持久化 NSUserDefaults */
+ (void)setUserDefaultWithValue:(id)value forKey:(NSString *)key;
+ (id)getUserDefaultForKey:(NSString *)key;

+ (void)mainThreadExcute:(void (^)())block;

/** 歌词 */
+ (NSMutableArray *)lyricFromContentOfFile:(NSString *)path;
+ (NSMutableArray *)lyricFromContent:(NSString *)lyricContent;

/** APP下的文件路径 (fname-文件名) */
+ (NSString*)appDocumentsDirectory;
+ (NSString*)appCachesDirectory;
+ (NSString*)filePathForDocumentDirectory:(NSString *)fname;
+ (NSString*)filePathForTempDirectory:(NSString *)fname;
+ (NSString*)filePathForCachesDirectory:(NSString *)fname;

/** 文件属性 */
+ (NSDictionary *)fileProperty:(NSString *)fileName;
+ (BOOL)checkIsExistsFile:(NSString *)fileName;
+ (BOOL)renameFile:(NSString*)filePath NewName:(NSString*)name;
+ (BOOL)deleteFile:(NSString*)filePath;
+ (BOOL)deleteDocumentFile:(NSString *)fileName;
+ (BOOL)creatFile:(NSString*)fileName content:(NSData *)content attributes:(NSDictionary *)attributes;

@end
