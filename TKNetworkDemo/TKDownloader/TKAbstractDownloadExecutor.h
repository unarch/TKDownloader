//
//  TKAbstractDownloadExecutor.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import <Foundation/Foundation.h>
#import "TKAbstractDownloadTask.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^TKDownloadExecutorProgressBlock)(NSProgress * _Nonnull progress);

typedef void(^TKDownloadExecutorCompletionBlock)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error);


@interface TKAbstractDownloadExecutor : NSObject

/// 下载进度block
@property (nonatomic, copy) TKDownloadExecutorProgressBlock downloadProgressBlock;

/// 下载完成block
@property (nonatomic, copy) TKDownloadExecutorCompletionBlock downloadCompletionBlock;

+ (id)shareExecutor;

/// 执行下载函数
/// @param task 下载任务
/// @param progress 下载进度回调
/// @param completionHandler 下载完成回调
- (NSURLSessionDownloadTask *)downloadWithTask:(TKAbstractDownloadTask *)task
                                      progress:(nullable TKDownloadExecutorProgressBlock)progress
                             completionHandler:(nullable TKDownloadExecutorCompletionBlock)completionHandler;


@end

NS_ASSUME_NONNULL_END
