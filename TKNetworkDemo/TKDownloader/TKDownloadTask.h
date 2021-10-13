//
//  TKDownloadTask.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKAbstractDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKDownloadTask : TKAbstractDownloadTask

+ (TKDownloadTask *)downloadWithURLString:(NSString *)URLString
                                downloadFilePath:(NSString *)filePath
                                      parameters:(nullable id)parameters
                                         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                        progress:(nullable TKDownloadProgressBlock)downloadProgress
                                         success:(nullable TKDownloadCompletionBlock)success
                                         failure:(nullable TKDownloadFailBlock)failure;


@end

NS_ASSUME_NONNULL_END
