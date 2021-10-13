//
//  TKDownloadManager.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKDownloadManager.h"
#import "TKBaseDownloadOperation.h"
#import "TKDownloadUtils.h"
#import "TKJumpQueue.h"

#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface TKDownloadManager ()<TKBaseDownloadOperationDelegate>

@property (nonatomic, strong, readwrite) NSMutableDictionary *operatons;
@property (nonatomic, strong) TKJumpQueue *pendingQueue;
@property (nonatomic, strong) NSMutableArray *doingQueue;
@property (nonatomic, strong) dispatch_queue_t serQueue;



@end

@implementation TKDownloadManager

+ (instancetype)shareManager {
    static TKDownloadManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        _instance.maxOperationCount = 1;
        
    });
    return _instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.serQueue = dispatch_queue_create("com.tkdownloadmanage.serial", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [self shareManager];
}

- (void)addDownloadTask:(TKAbstractDownloadTask *)task {
    NSString *key = [TKDownloadUtils md5StringFromString:task.url];
    
    __block TKBaseDownloadOperation *op;
    
    dispatch_async(_serQueue, ^{
        
        op = [self.operatons objectForKey:key];
        if (!op) {
            op = [TKBaseDownloadOperation new];
            op.delegate = self;
            [self.operatons setObject:op forKey:key];
        }
        [op addDownloadTask:task];
    });

    
    
    
    dispatch_barrier_async(_serQueue, ^{
        BOOL doing = NO;
        doing = [self.doingQueue containsObject:op];
        if (NO == doing) {
            [self.pendingQueue setObject:op forKey:key];
        }
        if( ! [self tryJoinOperation]) {
            if (task.waitingBlock) {
                task.waitingBlock(self.pendingQueue.totalCount);
            }
        }
    });
}
/*
 尝试从等待队列中启动第一个任务
 */
- (BOOL)tryJoinOperation {
    if (self.pendingQueue.totalCount <= 0) {
        return NO;
    }
    
    if(self.doingQueue.count >= self.maxOperationCount) {
        return NO;
    }
    TKBaseDownloadOperation *front = [self.pendingQueue popObjectFront];
    [front start];
    [self.doingQueue addObject:front];
    return YES;
}

- (BOOL)tryRemoveOperation:(TKBaseDownloadOperation *)op {
    NSString *key = [TKDownloadUtils md5StringFromString:op.url];
    [self.pendingQueue removeObjectForKey:key];
    
    BOOL exist = [self.doingQueue containsObject:op];
    
    if (exist) {
        [self.doingQueue removeObject:op];
    }
    return YES;
}

- (void)cancelDownloadTask:(TKAbstractDownloadTask *)task {
    if (!task) {
        return;
    }
    NSString *key = [TKDownloadUtils md5StringFromString:task.url];

    dispatch_barrier_async(_serQueue, ^{
        TKBaseDownloadOperation *op = [self.operatons objectForKey:key];
        if (!op) {
            return;
        }
        [op cancelTask:task];
        [self tryRemoveOperation: op];
        
        [self.operatons removeObjectForKey:key];
        [self tryJoinOperation];
    });
}

- (void)onDownloadFinsh:(NSString *)url filePath:(NSString *)filePath error:(NSError *)error operation:(TKBaseDownloadOperation *)operation {
    NSString *key = [TKDownloadUtils md5StringFromString:url];
    dispatch_barrier_async(_serQueue, ^{
        [self.doingQueue removeObject:operation];
        [self.operatons removeObjectForKey:key];
        [self tryJoinOperation];
    });
}

- (NSMutableDictionary *)operatons {
    if (!_operatons) {
        _operatons = [NSMutableDictionary new];
    }
    return _operatons;
}

- (TKJumpQueue *)pendingQueue {
    if (!_pendingQueue) {
        _pendingQueue = [[TKJumpQueue alloc] init];
        _pendingQueue.name = @"TKDownloadManage.pendingQueue";
    }
    return _pendingQueue;
}

- (NSMutableArray *)doingQueue {
    if (!_doingQueue) {
        _doingQueue = [[NSMutableArray alloc] init];
        
    }
    return _doingQueue;
}

@end
