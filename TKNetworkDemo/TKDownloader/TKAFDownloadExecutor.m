//
//  TKAFDownloadExecutor.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKAFDownloadExecutor.h"
#import "AFNetworking.h"
#import "TKDownloadManager.h"
#import "TKDownloadUtils.h"

@interface TKAFDownloadExecutor ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation TKAFDownloadExecutor

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSURLSessionDownloadTask *)downloadWithTask:(TKAbstractDownloadTask *)task
                                      progress:(TKDownloadExecutorProgressBlock)progress
                             completionHandler:(nullable TKDownloadExecutorCompletionBlock)completionHandler {
    NSError * __autoreleasing error = nil;
    _manager = [self madeManagerWtih:task];
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForTask:task];
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:@"GET" URLString:task.url parameters:task.parameters error:&error];
    
    NSString *downloadTargetPath = [TKDownloadUtils downloadPathWithPath:task.downloadFilePath url:task.url];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTargetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTargetPath error:nil];
    }
    BOOL resumeSucceeded = NO;
    __block NSURLSessionDownloadTask *downloadTask = nil;
    NSURL *localUrl = [TKDownloadUtils incompleteDownloadTempPathForDownloadPath:downloadTargetPath];
    if (localUrl != nil) {
        BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:localUrl.path];
        NSData *data = [NSData dataWithContentsOfURL:localUrl];
        BOOL resumeDataIsValid = [TKDownloadUtils validateResumeData:data];
        BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
        if (canBeResumed) {
            @try {
                downloadTask = [self.manager downloadTaskWithResumeData:data progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
                } completionHandler:completionHandler];
                resumeSucceeded = YES;
            } @catch (NSException *exception) {
                resumeSucceeded = NO;
            }
        }
    }
    if (!resumeSucceeded) {
        downloadTask = [self.manager downloadTaskWithRequest:urlRequest progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
        } completionHandler:completionHandler];
    }
    return downloadTask;
}

- (AFHTTPSessionManager *)madeManagerWtih:(TKAbstractDownloadTask *)task {
    AFHTTPSessionManager *manager = nil;
    if (task.downloadType == TKDownloadTypeBackground) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadDone:) name:AFNetworkingTaskDidCompleteNotification object:nil];
        manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.TKDownload"]];
    } else {
        manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:nil];
    }
    AFSecurityPolicy *securityPolicy =  [AFSecurityPolicy defaultPolicy];
    // 客户端是否信任非法证书
    securityPolicy.allowInvalidCertificates = [[TKDownloadManager shareManager] allowInvalidCertificates];
    // 是否在证书域字段中验证域名
    securityPolicy.validatesDomainName = [[TKDownloadManager shareManager] validatesDomainName];
    manager.securityPolicy = securityPolicy;
    return manager;
}

- (void)downLoadDone:(NSNotification *)notification {
    NSLog(@"downLoadDone === %@",notification.userInfo);
}

- (AFHTTPRequestSerializer *)requestSerializerForTask:(TKAbstractDownloadTask *)task {
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    if (task.authorizationHeaderArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:task.authorizationHeaderArray.firstObject password:task.authorizationHeaderArray.lastObject];
    }
    if (task.header != nil) {
          for (NSString *key in task.header.allKeys) {
              [requestSerializer setValue:task.header[key] forHTTPHeaderField:key];
          }
    }
    return requestSerializer;
    
}

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:nil];
    }
    return _manager;
}

@end
