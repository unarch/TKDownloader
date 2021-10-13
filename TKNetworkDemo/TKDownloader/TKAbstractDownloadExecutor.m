//
//  TKAbstractDownloadExecutor.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKAbstractDownloadExecutor.h"

@implementation TKAbstractDownloadExecutor

+ (id)shareExecutor {
    static TKAbstractDownloadExecutor *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareExecutor];
}

- (NSURLSessionDownloadTask *)downloadWithTask:(TKAbstractDownloadTask *)task
                                      progress:(TKDownloadExecutorProgressBlock)downloadProgress
                             completionHandler:(TKDownloadExecutorCompletionBlock)completionHandler {
    return nil;
}


@end
