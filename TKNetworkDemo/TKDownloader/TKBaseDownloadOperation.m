//
//  TKBaseDownloadOperation.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKBaseDownloadOperation.h"
#import "TKAbstractDownloadExecutor.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "TKDownloadManager.h"
#import "TKDownloadUtils.h"
#import <pthread.h>

@interface TKBaseDownloadOperation ()

@property (nonatomic, strong, readwrite) NSMutableSet *tasks;
@property (nonatomic, strong, readwrite) NSURLSessionDownloadTask *sessionDownloadTask;

@end

@implementation TKBaseDownloadOperation
pthread_rwlock_t taskRwlock;

@synthesize tasks = _tasks;
@synthesize sessionDownloadTask = _sessionDownloadTask;

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_rwlock_init(&taskRwlock, NULL);
    }
    return self;
}

- (void)addDownloadTask:(TKAbstractDownloadTask *)task {
    if (!task || [self.tasks containsObject:task]) {
        return;
    }
    if (self.tasks.count == 0) {
        self.sessionDownloadTask = [self makeSessionDownloadTaskWithTask:task];
    }
    
    pthread_rwlock_wrlock(&taskRwlock);
    [self.tasks addObject:task];
    pthread_rwlock_unlock(&taskRwlock);

    self.url = task.url;
}


- (NSURLSessionDownloadTask *)makeSessionDownloadTaskWithTask:(TKAbstractDownloadTask *)downloadTask {
    TKAbstractDownloadExecutor *executor = [self madeExecutorWithTask:downloadTask];
    NSURLSessionDownloadTask *sessionDownloadTask = [executor downloadWithTask:downloadTask progress:^(NSProgress * _Nonnull progress) {
        pthread_rwlock_rdlock(&taskRwlock);
        for (TKAbstractDownloadTask *task in self.tasks) {
            if (task.downloadProgressBlock) {
                task.downloadProgressBlock(progress);
            }
        }
        pthread_rwlock_unlock(&taskRwlock);

    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            pthread_rwlock_rdlock(&taskRwlock);
            for (TKAbstractDownloadTask *tempTask in self.tasks) {
                if (tempTask.downloadFailBlock) {
                    tempTask.downloadFailBlock(self.sessionDownloadTask, error);
                }
            }
            pthread_rwlock_unlock(&taskRwlock);
        } else {
            pthread_rwlock_rdlock(&taskRwlock);
            for (TKAbstractDownloadTask *tempTask in self.tasks) {
                if (tempTask.downloadCompletionBlock) {
                    tempTask.downloadCompletionBlock(self.sessionDownloadTask, filePath.absoluteString);
                }
            }
            pthread_rwlock_unlock(&taskRwlock);
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(onDownloadFinsh:filePath:error:operation:)]) {
            [self.delegate onDownloadFinsh:self.url filePath:filePath.absoluteString error:error operation:self];
        }
        pthread_rwlock_wrlock(&taskRwlock);
        [self.tasks removeAllObjects];
        pthread_rwlock_unlock(&taskRwlock);
    }];
    return sessionDownloadTask;
}

- (TKAbstractDownloadExecutor *)madeExecutorWithTask:(TKAbstractDownloadTask *)task {
    NSString *className = [task executorClassName];
    if (!className || className.length == 0) {
        className = @"TKAFDownloadExecutor";
    }
    Class nclass = NSClassFromString(className);
    TKAbstractDownloadExecutor *executor = nil;
    executor = [nclass new];
    return executor;
}

- (void)start {
    if (!self.sessionDownloadTask) {
        return;
    }
    [self.sessionDownloadTask resume];
}

- (void)cancelTask:(TKAbstractDownloadTask *)task {
    if (!self.sessionDownloadTask || !task) {
        return;
    }
    NSString *path = [TKDownloadUtils downloadPathWithPath:task.downloadFilePath url:task.url];
    NSURL *localUrl = [TKDownloadUtils incompleteDownloadTempPathForDownloadPath:path];
    if ( localUrl != nil) {
        [self.sessionDownloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [resumeData writeToURL:localUrl atomically:YES];
        }];
    }
    pthread_rwlock_wrlock(&taskRwlock);
    if ([self.tasks containsObject:task]) {
        [self.tasks removeAllObjects];
    }
    pthread_rwlock_unlock(&taskRwlock);
}

- (NSMutableSet *)tasks {
    if (!_tasks) {
        _tasks = [NSMutableSet new];
    }
    return _tasks;
}


@end
