//
//  BaseComponentViewController.h
//
//  Created by Miri
//

#import <UIKit/UIKit.h>

@interface BaseComponentViewController : UIViewController
@property (nonatomic, strong) NSDate *nextRefreshTime;
@property (nonatomic, strong) NSObject *refreshTaskUniqueKey;
@property (nonatomic, assign) BOOL shouldInvalidateCache;


- (void)setupComponentDefinitions:(NSDictionary*)attributes;

/*
 Make sure to call super in any subclass of this class.
 */
- (void)refreshComponentNotification:(NSNotification *)notification;

/*
 Cancel the current refresh task when the component is being reloaded.
 */
- (void)cancelRefreshTask;

/*
 Make sure to call super in any subclass of this class.
 */
- (void)prepareComponentForReuse;

- (void)addRefreshTaskAfterDelay:(NSTimeInterval)delay;

/**
 This method registers to the refresh if the given data requires so.
 Make sure to call this method everytime after the component's datasource is being set.
 
 This method first calls the `cancelRefreshTask` method to cancel any old existing refresh tasks.
 */
- (void)registerRefreshTaskIfNeeded:(NSObject *)dataSource;

@end
