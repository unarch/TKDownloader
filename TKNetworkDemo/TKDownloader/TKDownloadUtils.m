//
//  TKDownloadUtils.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKDownloadUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TKDownloadUtils

+ (NSString *)rootPath {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return cachePath;
}

+ (NSString *)subPath {
    return @"TKFileDownload";
}

+ (NSString *)downloadPathWithPath:(NSString *)downloadFilePath url:(NSString *)url {
    NSString *downloadTargetPath = nil;
    NSString *downloadPath = nil;
    if (downloadFilePath && downloadFilePath.length > 0) {
        downloadPath = downloadFilePath;
    } else {
        downloadPath =  [TKDownloadUtils absoluteMD5PathWithKey:url];
    }

    BOOL isDirectory;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadPath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    if (isDirectory) {
        NSString *fileName = [[NSURL URLWithString:url] lastPathComponent];
        downloadTargetPath = [NSString pathWithComponents:@[downloadPath, fileName]];
    } else {
        downloadTargetPath = downloadPath;
    }
    return downloadTargetPath;
}

+ (NSString *)absoluteMD5PathWithKey:(NSString *)key {
    if (!key || key.length == 0) {
        return nil;
    }
   NSString *md5Key = [TKDownloadUtils md5StringFromString:key];
    if (!md5Key || md5Key.length == 0) {
        return nil;
    }
   return [[TKDownloadUtils absoluteSavePath] stringByAppendingPathComponent:md5Key];
}

+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);

    const char *value = [string UTF8String];

    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }

    return outputString.copy;
}

+ (NSString *)absoluteSavePath {
    if (![TKDownloadUtils subPath] || [TKDownloadUtils subPath].length == 0) {
        return self.rootPath;
    }
   NSString *path = [[TKDownloadUtils rootPath] stringByAppendingPathComponent:[TKDownloadUtils subPath]];
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!existed || !isDir) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = nil;
    NSString *md5URLString = [TKDownloadUtils md5StringFromString:downloadPath];
    tempPath = [[TKDownloadUtils incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return tempPath == nil ? nil : [NSURL fileURLWithPath:tempPath];
}

+ (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;

    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"Incomplete"];
    }

    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

+ (BOOL)validateResumeData:(NSData *)data {
    if (!data || [data length] < 1) return NO;
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    return YES;
}
@end
