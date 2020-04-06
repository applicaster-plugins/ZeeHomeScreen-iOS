//
//  ComponentDelegate.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//


@class APModel;
@protocol ComponentModelProtocol;
@protocol ComponentProtocol;

@protocol ComponentDelegate <NSObject>

@optional

- (BOOL)shouldLoadDataSourceForModel:(NSObject *)model
                      componentModel:(NSObject <ComponentModelProtocol> *)componentModel
                     completionBlock:(void (^)(NSArray *dataSource))completion;

// Other

- (NSObject *)topParentForComponentModel:(NSObject <ComponentModelProtocol> *)componentModel
                     withDataSourceModel:(NSObject *)model;

- (void)handleCloseScreen;

- (NSURLRequestCachePolicy)cachePolicyForDataSourceModel:(NSObject *)model
                                          componentModel:(NSObject <ComponentModelProtocol> *)componentModel;

- (void)componentViewController:(UIViewController <ComponentProtocol>*)componentViewController
                 didSelectModel:(NSObject *)model
                 componentModel:(NSObject <ComponentModelProtocol> *)componentModel
                    atIndexPath:(NSIndexPath *)indexPath
                     completion:(void (^)(UIViewController *targetViewController))completion;

- (void)loadingFinishedWithNotification:(NSNotification *)notification;


- (void)componentViewController:(UIViewController <ComponentProtocol>*)componentViewController
        didChangedContentOffset:(CGPoint)contentOffset;

- (void)addRefreshTaskAfterDelay:(NSTimeInterval)delay;
- (APModel *)currenlySelectedModel;

/**
 Remove item displayed in the component delegate by model and component model
 */
- (void)removeComponentForModel:(NSObject *)model
              andComponentModel:(NSObject <ComponentModelProtocol> *)componentModel;
- (void)reloadComponentForModel:(NSObject *)model
andComponentModel:(NSObject <ComponentModelProtocol> *)componentModel;

@end
