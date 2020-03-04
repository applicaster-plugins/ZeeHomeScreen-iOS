//
//  RefreshManager.h
//  ModularAppSDK
//
//

#import <Foundation/Foundation.h>

/**
 Notification that is sent when a refreshable item needs to be refreshed. The object will be the given refreshTaskKey you used in the registerForRefresh method - So you need to add observer to this notification with this exact object.
 */
extern NSString *const RefreshNotification;

/**
 Notification that is sent to refresh a screen needs to be refreshed. (for example: after click on refresh view)
 */
extern NSString *const StartRefreshScreenNotification;

/**
 Notification that is sent when needs to show the refresh view.
 */
extern NSString *const ShowRefreshViewNotification;

/**
 Notification that is sent when needs to remove the refresh view.
 */
extern NSString *const RemoveRefreshViewNotification;

@interface RefreshManager : NSObject


+ (instancetype) sharedInstance;

/**
 @param refreshTaskKey - Should be some uniqeue key that identifies this task. In order to cancel the task or identify your refresh notification you must keep the same key object!
 */
- (void)registerForRefresh:(id)refreshTaskKey
                afterDelay:(CGFloat)delay;

/**
  @param refreshTaskKey - Use the same key object that you have used when you called the registerForRefresh method.
 */
- (void)unregisterFromRefresh:(id)refreshTaskKey;

@end
