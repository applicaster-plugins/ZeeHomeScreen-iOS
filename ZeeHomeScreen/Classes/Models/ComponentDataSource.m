//
//  ComponentDataSource.m
//
//  Created by Anton Klysa on 25.03.2020.
//

#import "ComponentDataSource.h"

#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>
#import <ApplicasterSDK/ApplicasterSDK.h>
#import <ApplicasterSDK/ApplicasterSDK-Swift.h>

@implementation ComponentDataSource

#pragma mark - NSObject

- (instancetype)init {
    if (self = [super init]) {
        self.modelType = APModelTypeNone;
        self.idString  = nil;
        self.uiTagString = nil;
        _model     = nil;
        _dataSourceLimit = NSIntegerMax;
        self.groupDataSourceID = nil;
        self.parentDataSource = NO;
        self.manuallySet = NO;
        self.topParentDataSourceModel = NO;
        self.isSectionEmpty = NO;
        self.customDataSource = none;
        self.adUnit = nil;
    }
    return self;
}

#pragma mark - Public Methods

-(void)parseDataSourceWithDictionary:(NSDictionary *)dataDictionary {
    _object = dataDictionary;
    
    NSNumber *idNumber = [[dataDictionary objectForKey:kComponentDataSourceIDKey] isKindOfClass:[NSNumber class]] ? [dataDictionary objectForKey:kComponentDataSourceIDKey] : nil;
    self.idString = idNumber ? [NSString stringWithFormat:@"%@",idNumber] : nil;
    
    self.uiTagString = [[dataDictionary objectForKey:kComponentDataSourceUITagKey] isKindOfClass:[NSString class]] ? [[dataDictionary objectForKey:kComponentDataSourceUITagKey] lowercaseString] : nil;
    
    NSString *modelTypeString = [[dataDictionary objectForKey:kComponentDataSourceTypeKey] isKindOfClass:[NSString class]] ? [[dataDictionary objectForKey:kComponentDataSourceTypeKey] lowercaseString] : nil;
    self.modelType = [self modelTypeByString:modelTypeString];
    
    if (self.modelType == APModelTypeNone) {
        NSString *customDataSourceModel = [[dataDictionary objectForKey:kComponentCustomDataSourceTypeKey] isKindOfClass:[NSString class]] ? [[dataDictionary objectForKey:kComponentCustomDataSourceTypeKey] lowercaseString] : nil;
        self.customDataSource = [self customDataSourceTypeByString:customDataSourceModel];
    }
    _modelLoaderType = [[dataDictionary objectForKey:kComponentDataSourceLoaderTypeKey] isKindOfClass:[NSString class]] ? [[dataDictionary objectForKey:kComponentDataSourceLoaderTypeKey] lowercaseString] : nil;
    
    self.groupDataSourceID = [[dataDictionary objectForKey:kComponentDataSourceGroupTypeKey] isKindOfClass:[NSString class]] ? [[dataDictionary objectForKey:kComponentDataSourceGroupTypeKey] lowercaseString] : nil;

    self.parentDataSource = [[dataDictionary objectForKey:kComponentDataParentKey] isKindOfClass :[NSNumber class]] ? [[dataDictionary objectForKey:kComponentDataParentKey] boolValue] : false;
    
    self.manuallySet = [[dataDictionary objectForKey:kComponentManuallySetKey] isKindOfClass :[NSNumber class]] ? [[dataDictionary objectForKey:kComponentManuallySetKey] boolValue] : false;
    
    self.isSectionEmpty = [[dataDictionary objectForKey:kComponentSectionEmptyKey] isKindOfClass :[NSNumber class]] ? [[dataDictionary objectForKey:kComponentSectionEmptyKey] boolValue] : false;
    
    self.topParentDataSourceModel = [[dataDictionary objectForKey:kComponentTopParentModelKey] isKindOfClass :[NSNumber class]] ? [[dataDictionary objectForKey:kComponentTopParentModelKey] boolValue] : false;
    
    self.adUnit = [[dataDictionary objectForKey:kComponentDataSourceAdUnitKey] isKindOfClass:[NSString class]] ? [dataDictionary objectForKey:kComponentDataSourceAdUnitKey] : nil;
    
    self.noDataDictionary = [[dataDictionary objectForKey:kComponentNoDataViewKey] isKindOfClass :[NSDictionary class]] ? [dataDictionary objectForKey:kComponentNoDataViewKey] : nil;
    if ([dataDictionary[kAttributesLimitInDataSourceKey] isKindOfClass:[NSNumber class]]) {
        NSUInteger value = [dataDictionary[kAttributesLimitInDataSourceKey] integerValue];
        if (value > 0) {
            _dataSourceLimit = value;
        }
    }
    
    self.loadSecondLevel = [dataDictionary[kAttributesLoadSecondLevelDataSourceKey] isKindOfClass:[NSNumber class]] ? [dataDictionary[kAttributesLoadSecondLevelDataSourceKey] boolValue] : NO;
};

// TODO: Make this method more correct
- (void)setModel:(NSObject *)model {
    if (_model != model) {
        _model = model;
        self.customDataSource = none;
        
        if ([model isKindOfClass:[APModel class]]) {
            APModel *applicasterModel = (APModel *)model;
            if ([applicasterModel respondsToSelector:@selector(uiTag)]) {
                self.uiTagString = applicasterModel.uiTag;
            }
            if ([applicasterModel respondsToSelector:@selector(uniqueID)]) {
                self.idString = applicasterModel.uniqueID;
            }
            
            self.modelType = APModelTypeNone;
            if ([applicasterModel isKindOfClass:[APCategory class]]) {
                if ([applicasterModel isMemberOfClass:[APAtomFeed class]]) {
                    self.modelType = APModelTypeAtomFeed;
                } else if ([applicasterModel isMemberOfClass:[APItemList class]]) {
                    self.modelType = APModelTypeItemList;
                } else if ([[(APCategory *)applicasterModel linkURL] isNotEmpty]) {
                    self.modelType = APModelTypeLinkCategory;
                } else {
                    self.modelType = APModelTypeCategory;
                }
            } else if ([applicasterModel isMemberOfClass:[APVodItem class]]) {
                self.modelType = APModelTypeVodItem;
            } else if ([applicasterModel isMemberOfClass:[APChannel class]]) {
                self.modelType = APModelTypeChannel;
            } else if ([applicasterModel isMemberOfClass:[APCollection class]]) {
                self.modelType = APModelTypeCollection;
            } else if ([applicasterModel isMemberOfClass:[APChannel class]]) {
                self.modelType = APModelTypeChannel;
            }
        } else if ([model isMemberOfClass:[APAtomEntry class]]) {
            self.modelType = APModelTypeAtomEntry;
        } else if ([model isKindOfClass:[APBannerModel class]])
        {
            self.modelType = APModelTypeBanner;
        }
    }
}

#pragma mark -

- (APModelTypes)modelTypeByString:(NSString *)modelTypeString {
    if ([modelTypeString isEqualToString:kComponentAPModelCollectionTypeKey]) {
        return APModelTypeCollection;
    } else if ([modelTypeString isEqualToString:kComponentAPModelCategoryTypeKey]) {
        return APModelTypeCategory;
    } else if ([modelTypeString isEqualToString:kComponentAPModelVodItemTypeKey]) {
        return APModelTypeVodItem;
    } else if ([modelTypeString isEqualToString:kComponentAPModelItemListTypeKey]) {
        return APModelTypeItemList;
    } else if ([modelTypeString isEqualToString:kComponentAPModelChannelItemTypeKey]){
        return APModelTypeChannel;
    } else if ([modelTypeString isEqualToString:kComponentAPModelLinkCategoryTypeKey]){
        return APModelTypeLinkCategory;
    } else if ([modelTypeString isEqualToString:kComponentAPModelBannerTypeKey]){
        return APModelTypeBanner;
    } else {
        return APModelTypeNone;
    }
}

- (CACustomDataSourceType)customDataSourceTypeByString:(NSString *)customDataSourceTypeString {
    CACustomDataSourceType retVal = none;
    
    if ([customDataSourceTypeString isEqualToString:kComponentCustomDataSourceFavoritesKey]) {
        retVal = favorites;
    }
    else if ([customDataSourceTypeString isEqualToString:kComponentCustomDataSourceHqmeKey]) {
        retVal = hqme;
    }
    
    return retVal;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.modelType = [[decoder decodeObjectForKey:@"modelType"] integerValue];
        self.idString = [decoder decodeObjectForKey:@"idString"];
        self.uiTagString = [decoder decodeObjectForKey:@"uiTagString"];
        self.groupDataSourceID = [decoder decodeObjectForKey:@"groupDataSourceID"];
        self.adUnit = [decoder decodeObjectForKey:@"adUnit"];
        self.parentDataSource = [[decoder decodeObjectForKey:@"parentDataSource"] boolValue];
        self.manuallySet = [[decoder decodeObjectForKey:@"manuallySet"] boolValue];
        self.isSectionEmpty = [[decoder decodeObjectForKey:@"section_empty"] boolValue];
        self.topParentDataSourceModel = [[decoder decodeObjectForKey:@"topParentDataSourceModel"] boolValue];
        _modelLoaderType = [decoder decodeObjectForKey:@"modelLoaderType"];
        self.noDataDictionary = [decoder decodeObjectForKey:@"noDataDictionary"];
        self.model = [decoder decodeObjectForKey:@"model"];
        _dataSourceLimit = [[decoder decodeObjectForKey:@"dataSourceLimit"] integerValue];
        self.collectionChildMetaData = [decoder decodeObjectForKey:@"collectionChildMetaData"];
        self.urlScheme = [decoder decodeObjectForKey:@"urlScheme"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:[NSNumber numberWithInteger:_modelType] forKey:@"modelType"];
    [encoder encodeObject:_idString forKey:@"idString"];
    [encoder encodeObject:_uiTagString forKey:@"uiTagString"];
    [encoder encodeObject:_groupDataSourceID forKey:@"groupDataSourceID"];
    [encoder encodeObject:_adUnit forKey:@"adUnit"];
    [encoder encodeObject:[NSNumber numberWithBool:_parentDataSource] forKey:@"parentDataSource"];
    [encoder encodeObject:[NSNumber numberWithBool:_manuallySet] forKey:@"manuallySet"];
    [encoder encodeObject:[NSNumber numberWithBool:_isSectionEmpty] forKey:@"section_empty"];
    [encoder encodeObject:[NSNumber numberWithBool:_topParentDataSourceModel] forKey:@"topParentDataSourceModel"];
    [encoder encodeObject:_modelLoaderType forKey:@"modelLoaderType"];
    [encoder encodeObject:_noDataDictionary forKey:@"noDataDictionary"];
    [encoder encodeObject:_model forKey:@"model"];
    [encoder encodeObject:[NSNumber numberWithInteger:_dataSourceLimit] forKey:@"dataSourceLimit"];
    [encoder encodeObject:_collectionChildMetaData forKey:@"collectionChildMetaData"];
    [encoder encodeObject:_urlScheme forKey:@"urlScheme"];

}

@end
