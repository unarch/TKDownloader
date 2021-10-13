//
//  TKDownloadManager.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TKAbstractDownloadTask;

@interface TKDownloadManager : NSObject

/// 下载操作存储map，只读属性，key是url的md5值，value是DBaseDownloadOperation对象
@property (nonatomic, strong, readonly) NSMutableDictionary *operatons;

/// 最大同时下载数目
@property (nonatomic, assign) NSInteger maxOperationCount;

/// 是否信任无效或者过期证书，默认为：NO
@property (nonatomic, assign) BOOL allowInvalidCertificates;

/// 是否验证 domain
@property (nonatomic, assign) BOOL validatesDomainName;

+ (instancetype)shareManager;

/// 添加下载任务
/// @param task 下载任务
- (void)addDownloadTask:(TKAbstractDownloadTask *)task;

/// 取消下载任务
/// @param task 下载任务
- (void)cancelDownloadTask:(TKAbstractDownloadTask *)task;


@end

NS_ASSUME_NONNULL_END
