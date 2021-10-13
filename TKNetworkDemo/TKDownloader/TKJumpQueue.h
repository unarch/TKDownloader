//
//  TKJumpQueue.h
//  TKNetworkDemo
//
//  Created by unarch on 2021/6/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TKJumpQueue : NSObject

#pragma mark - Attribute
///=============================================================================
/// @name Attribute
///=============================================================================
/** The name of the queue. Default is nil. */
@property (nullable, copy) NSString *name;


#pragma mark - Limit
///=============================================================================
/// @name Limit
///=============================================================================


/**
 If `YES`, the key-value pair will be released on main thread, otherwise on
 background thread. Default is NO.
 是否在主线程销毁对象，比如uiview/calayer需要
 
 @discussion You may set this value to `YES` if the key-value object contains
 the instance which should be released in main thread (such as UIView/CALayer).
 */
@property BOOL releaseOnMainThread;

/**
 If `YES`, the key-value pair will be released asynchronously to avoid blocking
 the access methods, otherwise it will be released in the access method
 (such as removeObjectForKey:). Default is YES.
 */
@property BOOL releaseAsynchronously;


#pragma mark - Access Methods
///=============================================================================
/// @name Access Methods
///=============================================================================

/**
 返回对象的个数
 */
- (NSUInteger)totalCount;

/**
 返回Key的Value是否在队列中
 不影响元素在队列中的位置
 @param key An object identifying the value. If nil, just return `NO`.
 @return Whether the key is in queue.
 */
- (BOOL)containsObjectForKey:(id)key;

/**
 返回Key的Value对象
 不影响元素在队列中的位置
 @param key An object identifying the value. If nil, just return nil.
 @return The value associated with key, or nil if no value is associated with key.
 */
- (nullable id)objectForKey:(id)key;

/**
  返回当前队首的key
  不影响元素在队列中的位置
 */
- (nullable id)frontObjectKey;

/**
  返回当前队尾的对象
  不影响元素在队列中的位置
 */
- (nullable id)backObjectKey;

/**
 往队列中插入Key - Value
 影响元素在队列中的位置，会将元素放到队首
 @param object The object to be stored in the queue. If nil, it calls `removeObjectForKey:`.
 @param key    The key with which to associate the value. If nil, this method has no effect.
 @discussion Unlike an NSMutableDictionary object, a cache does not copy the key
 objects that are put into it.
 */
- (void)setObject:(nullable id)object forKey:(id)key;

/**
   返回队首的对象并且将其从队列中移除
 */
- (nullable id)popObjectFront;

/**
 删除在队列中的key
 
 @param key The key identifying the value to be removed. If nil, this method has no effect.
 */
- (void)removeObjectForKey:(id)key;

/**
 立即删除所有对象
 Empties the queue immediately.
 */
- (void)removeAllObjects;


@end

NS_ASSUME_NONNULL_END

