//
//  ComponentProtocol.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

@protocol ComponentDelegate;
@protocol ComponentModelProtocol;

extern NSString * const kZeeCellTappedShareButtonNotification;
extern NSString * const kZeeCellTappedCleanButtonNotification;
extern NSString * const kZeeCellTappedBackButtonNotification;
extern NSString * const kZeeCellSetupSearchBarNotification;

static NSNotificationName const ZeeComponentLoaded = @"CAComponentLoaded";

typedef NS_ENUM(NSInteger, ZeeComponentState) {
    ZeeComponentStateNormal,
    ZeeComponentStateSelected,
    ZeeComponentStateHighlighted,
    ZeeComponentStateDisabled
};

typedef NS_ENUM(NSInteger, ZeeComponentEndDisplayingReason)
{
    ZeeComponentEndDisplayingReasonUndefined = 0,
    ZeeComponentEndDisplayingReasonCellQueued = 1,
    ZeeComponentEndDisplayingReasonParent = 2
};

@protocol ComponentProtocol <NSObject>

@required

- (void)setComponentModel:(NSObject <ComponentModelProtocol> *)componentModel;
- (void)setComponentDataSourceModel:(NSObject *)dataSource;

@optional

@property (nonatomic, strong) NSObject *selectedModel;
@property (nonatomic, strong) NSObject *componentDataSourceModel;
@property (nonatomic, strong) NSObject <ComponentModelProtocol> *componentModel;
@property (nonatomic, weak) id <ComponentDelegate> delegate;

- (void)setDataSource:(id)dataSource;
- (void)setComponentDataSource:(id)componentDataSource;

- (void)setupCustomizationDictionary;

- (void)setupAppDefaultDefinitions;
- (void)setupComponentDefinitions;

- (void)prepareComponentForReuse;
- (void)loadComponent;
- (void)reloadComponent;
- (void)reloadComponentWithNotification:(NSNotification *)notification;
- (void)rebuildComponent;
- (void)needUpdateLayout;
- (void)didEndDisplayingWithReason:(ZeeComponentEndDisplayingReason)reason;
- (void)didStartDisplaying;
@end

