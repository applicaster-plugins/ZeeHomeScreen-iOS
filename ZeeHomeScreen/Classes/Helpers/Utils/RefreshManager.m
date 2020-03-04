//
//  RefreshManager.m
//  ModularAppSDK
//
//

#import "RefreshManager.h"
#import "objc/runtime.h"

NSString *const RefreshNotification = @"RefreshNotification";
NSString *const StartRefreshScreenNotification = @"StartRefreshScreenNotification";
NSString *const ShowRefreshViewNotification = @"ShowRefreshViewNotification";
NSString *const RemoveRefreshViewNotification = @"RemoveRefreshViewNotification";


@interface RefreshManager()
    @property (nonatomic, strong) NSMutableSet *cachedItemsSet;
@end

@implementation RefreshManager

+ (instancetype) sharedInstance
{
    static RefreshManager* __sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [RefreshManager new];
        __sharedInstance.cachedItemsSet = [NSMutableSet new];
    });

    return __sharedInstance;
}

- (void)registerForRefresh:(id)refreshTaskKey
                afterDelay:(CGFloat)delay {
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(refreshItem:)
                                               object:refreshTaskKey];
    if (refreshTaskKey) {
        [self.cachedItemsSet addObject:refreshTaskKey];
    }
    [self performSelector:@selector(refreshItem:)
               withObject:refreshTaskKey
               afterDelay:delay];
}

- (void)unregisterFromRefresh:(id)refreshTaskKey{
    [self removeRefreshTaskKeyFromSet:refreshTaskKey];
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(refreshItem:)
                                               object:refreshTaskKey];
}

- (void)refreshItem:(id)uniqueKey{
    [self removeRefreshTaskKeyFromSet:uniqueKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:RefreshNotification
                                                        object:uniqueKey];
}

- (void)removeRefreshTaskKeyFromSet:(id)refreshTaskKey {
    if ([self.cachedItemsSet containsObject:refreshTaskKey]) {
        [self.cachedItemsSet removeObject:refreshTaskKey];
    }
}

@end
