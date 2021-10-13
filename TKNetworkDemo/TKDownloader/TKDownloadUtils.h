//
//  TKDownloadUtils.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKDownloadUtils : NSObject

+ (NSString *)rootPath;

+ (NSString *)subPath;

+ (NSString *)absoluteSavePath;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)downloadPathWithPath:(NSString *)downloadFilePath url:(NSString *)url;

+ (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath;

+ (BOOL)validateResumeData:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
