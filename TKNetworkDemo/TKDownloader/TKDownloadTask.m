//
//  TKDownloadTask.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKDownloadTask.h"
#import "TKDownloadManager.h"

@implementation TKDownloadTask

+ (TKDownloadTask *)downloadWithURLString:(NSString *)URLString
                         downloadFilePath:(NSString *)filePath
                               parameters:(id)parameters
                                  headers:(NSDictionary<NSString *,NSString *> *)headers
                                 progress:(TKDownloadProgressBlock)downloadProgress
                                  success:(TKDownloadCompletionBlock)success
                                  failure:(TKDownloadFailBlock)failure {
    TKDownloadTask *task = [TKDownloadTask new];
    task.url = URLString;
    task.downloadFilePath = filePath;
    if (headers && headers.allKeys.count > 0) {
        task.header = [headers copy];
    }
    task.parameters = parameters;
    task.downloadProgressBlock = downloadProgress;
    task.downloadCompletionBlock = success;
    task.downloadFailBlock = failure;
    return task;
}

- (NSString *)operationClassName {
    return @"TKBaseDownloadOperation";
}

- (NSString *)executorClassName {
    return @"TKAFDownloadExecutor";
}

- (void)start {
    [[TKDownloadManager shareManager] addDownloadTask:self];
}

- (void)cancel {
    [[TKDownloadManager shareManager] cancelDownloadTask:self];
}


@end
