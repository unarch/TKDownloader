//
//  TKBaseDownloadOperation.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import <Foundation/Foundation.h>
#import "TKAbstractDownloadTask.h"
NS_ASSUME_NONNULL_BEGIN


@class TKBaseDownloadOperation;

@protocol TKBaseDownloadOperationDelegate <NSObject>

/// 下载完成回调
/// @param url url
/// @param filePath filePath 本地文件路径
/// @param error error 下载错误
/// @param operation 回传operation
- (void)onDownloadFinsh:(NSString *)url
               filePath:(NSString *)filePath
                  error:(NSError *)error
              operation:(TKBaseDownloadOperation *)operation;


@end


@interface TKBaseDownloadOperation : NSObject

/// 下载地址
@property (nonatomic, copy) NSString *url;

/// 同一下载地址的下载任务队列 只读属性，修改用添加取消函数
@property (nonatomic, strong, readonly) NSMutableSet *tasks;

/// 下载的sessionDownloadTask 只读属性
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *sessionDownloadTask;

@property (nonatomic, weak) id <TKBaseDownloadOperationDelegate> delegate;

/// 添加下载任务
/// @param task task
- (void)addDownloadTask:(TKAbstractDownloadTask *)task;

/// 下载开始
- (void)start;

/// 取消队列中某个下载任务
/// @param task task
- (void)cancelTask:(TKAbstractDownloadTask *)task;


@end

NS_ASSUME_NONNULL_END
