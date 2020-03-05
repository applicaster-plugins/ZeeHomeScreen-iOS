//
//  BaseComponentViewController.m
//
//  Created by Miri
//

#import "BaseComponentViewController.h"
//#import "ComponentModel+Customization.h"
#import "RefreshManager.h"

@import ApplicasterSDK;

@interface BaseComponentViewController ()

@end

@implementation BaseComponentViewController

- (void)setupComponentDefinitions:(NSDictionary*)attributes {
    //Must be implemented in subclasses
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshTaskUniqueKey = [NSObject new];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshComponentNotification:)
                                                 name:RefreshNotification
                                               object:self.refreshTaskUniqueKey];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:RefreshNotification
                                                  object:nil];
}

- (void)refreshComponentNotification:(NSNotification *)notification {
    [self cancelRefreshTask];
}

- (void)prepareComponentForReuse {
    [self cancelRefreshTask];
}

- (void)addRefreshTaskAfterDelay:(NSTimeInterval)delay {
    if(delay > 0){
        NSDate *refreshTime = [[NSDate date] dateByAddingTimeInterval:delay];
        if((self.nextRefreshTime == nil || [refreshTime isBefore:self.nextRefreshTime])){
            self.nextRefreshTime = refreshTime;
            [[RefreshManager sharedInstance] registerForRefresh:self.refreshTaskUniqueKey
                                                       afterDelay:delay];
        }
    }
}

- (void)cancelRefreshTask {
    self.nextRefreshTime = nil;
    
    [[RefreshManager sharedInstance] unregisterFromRefresh:self.refreshTaskUniqueKey];
}

- (void)registerRefreshTaskIfNeeded:(NSObject *)dataSource {
    // We want to refresh if the current datasource defines expiration time.
    if([dataSource conformsToProtocol:@protocol(APExpirable)]) {
        [self cancelRefreshTask];
        
        id<APExpirable> expirableModel = (id<APExpirable>)dataSource;
        NSDate *expiresAt = [expirableModel expiresAt];
        [self addRefreshTaskAfterDelay:[expiresAt timeIntervalSinceNow]];
    }
}

@end
