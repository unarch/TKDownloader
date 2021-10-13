//
//  TKAbstractDownloadTask.m
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/22.
//

#import "TKAbstractDownloadTask.h"

@interface TKAbstractDownloadTask ()

@property (nonatomic, strong) NSMutableDictionary  <NSString *, NSString *> *mutableRequestHeaders;

@end

@implementation TKAbstractDownloadTask

- (void)start {
    
}

- (void)cancel {
    
}

- (NSString *)operationClassName {
    return nil;
}

- (NSString *)executorClassName {
    return nil;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (!field || field.length == 0) {
        return;
    }
    [self.mutableRequestHeaders setValue:value forKey:field];
}

- (NSMutableDictionary<NSString *,NSString *> *)mutableRequestHeaders {
    if (!_mutableRequestHeaders) {
        _mutableRequestHeaders = [NSMutableDictionary new];
    }
    return _mutableRequestHeaders;
}


@end
