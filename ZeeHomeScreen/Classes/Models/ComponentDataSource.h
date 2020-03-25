//
//  ComponentDataSource.h
//
//  Created by Anton Klysa on 25.03.2020.
//

#import <Foundation/Foundation.h>

@class APCollectionChildMetadata;

typedef NS_ENUM(NSUInteger, CACustomDataSourceType) {
    none = 0,
    favorites,
    hqme,
    userAccountComponent
};

static NSString *const kComponentAPModelCollectionTypeKey     = @"collection";
static NSString *const kComponentAPModelCategoryTypeKey       = @"category";
static NSString *const kComponentAPModelVodItemTypeKey        = @"voditem";
static NSString *const kComponentAPModelChannelItemTypeKey    = @"channel";
static NSString *const kComponentAPModelItemListTypeKey       = @"item_list";
static NSString *const kComponentAPModelLinkCategoryTypeKey   = @"link_category";
static NSString *const kComponentAPModelBannerTypeKey         = @"banner";

static NSString *const kComponentDataSourceLoaderTypeKey      = @"loader_type";

static NSString *const kComponentDataSourceIDKey              = @"id";
static NSString *const kComponentDataSourceUITagKey           = @"ui_tag";
static NSString *const kComponentDataSourceTypeKey            = @"type";
static NSString *const kComponentDataSourceAdUnitKey          = @"ad_unit";

static NSString *const kComponentDataSourceGroupTypeKey       = @"group_datasource_id";
static NSString *const kComponentDataParentKey                = @"parent_datasource";
static NSString *const kComponentManuallySetKey               = @"manually_set";
static NSString *const kComponentSectionEmptyKey              = @"section_empty";

static NSString *const kComponentCustomDataSourceTypeKey      = @"custom_data_source";
static NSString *const kComponentCustomDataSourceFavoritesKey = @"favorites";
static NSString *const kComponentCustomDataSourceHqmeKey    = @"hqme";

static NSString *const kComponentTopParentModelKey            = @"top_parent_datasource";
static NSString *const kComponentNoDataViewKey                = @"no_data_view";
static NSString *const kAttributesLimitInDataSourceKey        = @"datasource_limit";

static NSString *const kAttributesLoadSecondLevelDataSourceKey= @"loadTwoLevels";


typedef NS_ENUM(NSUInteger, APModelTypes) {
    APModelTypeNone = 0,
    APModelTypeCollection,
    APModelTypeCategory,
    APModelTypeAtomFeed,
    APModelTypeVodItem,
    APModelTypeAtomEntry,
    APModelTypeChannel,
    APModelTypeItemList,
    APModelTypeLinkCategory,
    APModelTypeBanner
};


@class APModel;

@interface ComponentDataSource : NSObject

@property (nonatomic, assign) APModelTypes modelType;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *uiTagString;
@property (nonatomic, strong) NSString *groupDataSourceID;
@property (nonatomic, strong) NSString *adUnit;
@property (nonatomic, assign) BOOL parentDataSource;
@property (nonatomic, assign) BOOL manuallySet;
@property (nonatomic, assign) BOOL isSectionEmpty;
@property (nonatomic, assign) BOOL topParentDataSourceModel;
@property (nonatomic, assign) BOOL loadSecondLevel;
@property (nonatomic, strong, readonly)NSDictionary *object;
@property (nonatomic, strong) NSURL *urlScheme;

@property (nonatomic, strong, readonly) NSString *modelLoaderType;

@property (nonatomic, strong) NSDictionary *noDataDictionary;

@property (nonatomic, strong) NSObject *model;
@property (nonatomic, assign, readonly) NSInteger dataSourceLimit;

// Updates for every child of the applicaster collection model.
@property (nonatomic, strong) APCollectionChildMetadata *collectionChildMetaData;
@property (nonatomic, assign) CACustomDataSourceType customDataSource;
#pragma mark - Public Methods

- (void)parseDataSourceWithDictionary:(NSDictionary *)dataDictionary;

@end
