//
//  TKAbstractDownloadTask.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, TKDownloadType) {
    TKDownloadTypeNomal,        //正常下载
    TKDownloadTypeBackground    //后台下载
};

typedef void(^TKDownloadFailBlock)(NSURLSessionTask * _Nullable task, NSError *_Nonnull error);

typedef void(^TKDownloadProgressBlock)(NSProgress * _Nonnull progress);

typedef void(^TKDownloadCompletionBlock)(NSURLSessionTask * _Nullable task, NSString * _Nullable filePath);

typedef void(^TKDownloadWaitingBlock)(NSInteger waitingCount);

@interface TKAbstractDownloadTask : NSObject


/// 下载url
@property (nonatomic, copy) NSString *url;

/// 下载请求头
@property (nonatomic, copy) NSDictionary *header;

/// 下载请求参数
@property (nonatomic, strong) id parameters;

/// 下载文件本地存储地址
@property (nonatomic, copy) NSString *downloadFilePath;

/// 鉴权参数
@property (nonatomic, strong) NSArray *authorizationHeaderArray;

/// 下载失败回调
@property (nonatomic, copy) TKDownloadFailBlock downloadFailBlock;

/// 下载进度回调
@property (nonatomic, copy) TKDownloadProgressBlock downloadProgressBlock;

/// 下载完成回调
@property (nonatomic, copy) TKDownloadCompletionBlock downloadCompletionBlock;

/// 下载数量超出进入等待状态回调
@property (nonatomic, copy) TKDownloadWaitingBlock waitingBlock;

/// 下载类型
@property (nonatomic, assign) TKDownloadType downloadType;

/// 绑定的下载执行器类名
- (NSString *)executorClassName;

/// 绑定的下载操作类名
- (NSString *)operationClassName;

/// 设置header
/// @param value value
/// @param field field
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/// 下载开始
- (void)start;

/// 下载取消
- (void)cancel;



@end

NS_ASSUME_NONNULL_END
