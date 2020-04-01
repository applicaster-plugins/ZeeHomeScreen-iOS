//
//  ComponentsCustomization.m
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//


#import "ComponentsCustomization.h"
#import <ApplicasterSDK/APAtomEntry.h>
#import <ApplicasterSDK/APAtomFeed.h>
#import <ApplicasterSDK/APCategory.h>
#import <ZeeHomeScreen/AbstractModel.h>
#import <ZeeHomeScreen/CommandPattern.h>
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>
@import ApplicasterSDK;

@implementation ComponentsCustomization

+ (id)valueFromDictionary:(NSDictionary *)dictionary
                forScreen:(NSString *)screenId
                 forModel:(NSObject *)model
                  withKey:(NSString *)key {
    
    if ([screenId isNotEmptyOrWhiteSpaces]) {
        NSDictionary *customDict = [self customizationDictionaryFromDictionary:dictionary
                                                                      screenId:screenId
                                                                        prefix:ModelPrefixALL];
        if (customDict)  {
            //Now check if there is specific relation to model
            id retVal = [self valueFromDictionary:customDict forModel:model withKey:key];
            //if there is specific relation to model
            if ([retVal isNotEmpty]) {
                 return retVal;
            }
            //else - return relation to screen
            return customDict[key];
        }
    }
    return nil;
}

+ (id)valueFromDictionary:(NSDictionary *)dictionary
                 forModel:(NSObject *)model
           componentModel:(ComponentModel *)componentModel
                  withKey:(NSString *)key {
    id retVal = dictionary[key];
    NSArray *keyPathes = nil;
    if ([key rangeOfString:@"/"].location != NSNotFound) {
        keyPathes = [key componentsSeparatedByString:@"/"];
    }
    
    if ([dictionary[@"header_cell"] isKindOfClass:[NSDictionary class]] &&
        componentModel == YES) {
        NSDictionary *headerDict = dictionary[@"header_cell"];
        retVal = [self valueFromDictionary:headerDict
                                  forModel:model
                            componentModel:componentModel
                                   withKey:key];
    } else if (keyPathes.count > 1) {
        id object = dictionary;
        for (NSString *key in keyPathes) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                if (object[key]) {
                    object = object[key];
                } else {
                    object = nil;
                    break;
                }
            }
        }
        if (object) {
            retVal = object;
        } else {
            retVal = [self valueFromDictionary:dictionary
                                      forModel:model
                                componentModel:componentModel
                                       withKey:[keyPathes lastObject]];
        }
    }
    else if ([model isNotEmpty]) {
        NSDictionary *modelData = nil;
        
        NSDictionary *customDict = [self customizationDictionaryFromDictionary:dictionary
                                                                         model:model
                                                                        prefix:ModelPrefixALL];
        if (customDict)  {
            modelData = customDict;
        } else {
            if ([model isKindOfClass:[APAtomEntry class]]) {
                modelData = dictionary[@"atom_entry"];
                if (modelData[key]) {
                    retVal = modelData[key];
                }
                APAtomEntry *atomEntry = (APAtomEntry *)model;
                switch (atomEntry.entryType) {
                    case APEntryTypeVideo:
                        if (modelData[@"video_nature"]) {
                            modelData = modelData[@"video_nature"];
                        }
                        break;
                    case APEntryTypeLink:
                        if (modelData[@"link_nature"]) {
                            modelData = modelData[@"link_nature"];
                        }
                        //adding support for opening url_scheme as atom entry link
                        else if ([key isEqualToString:@"url_scheme"] && [atomEntry.link isNotEmptyOrWhiteSpaces]) {
                            modelData = @{key: atomEntry.link};
                        }
                    default:
                        break;
                }
            }
            else if ([model conformsToProtocol:@protocol(APProgramProtocol)]) {
                modelData = dictionary[@"program"];
                if (modelData[key]) {
                    retVal = modelData[key];
                }
                NSObject <APProgramProtocol> *programItem = (NSObject <APProgramProtocol> *)model;
                modelData = [self extractModelForProgramAccordingToState: programItem modelData:modelData];
            }
        }
        
        if (modelData[key]) {
            retVal = modelData[key];
        }
    }
    
    if ([CommandPattern hasCommandInObject:retVal]) {
        APModel *modelInstance = nil;
        NSDictionary *modelObject = nil;
        if ([model isKindOfClass:[APModel class]]) {
            modelInstance = (APModel*)model;
            modelObject = [modelInstance respondsToSelector:@selector(object)] ? modelInstance.object : nil;
        }
        CAAbstractModel *abstractModel = [[CAAbstractModel alloc] initWithDictionary:modelObject];
        abstractModel.originModel = model;
        retVal = [CommandPattern resultFromCommand:retVal
                                               model:abstractModel];
    }

    return retVal;
}

+ (NSDictionary *)extractModelForProgramAccordingToState:(NSObject <APProgramProtocol> *)program
                                               modelData:(NSDictionary *) modelData {
    
    // Live Program
    if ([program isPlaying]) {
        if (modelData[@"live_state"]) {
            modelData = modelData[@"live_state"];
        }
    }
    //Future program
    else if ([program.startsAt isAfter:[NSDate date]]) {
        if (modelData[@"future_state"]) {
            modelData = modelData[@"future_state"];
        }
    }
    // Past programm
    else {
        if (modelData[@"past_state"]) {
            modelData = modelData[@"past_state"];
        }
    }
    return modelData;
}

+ (NSDictionary *)customizationDictionaryFromDictionary:(NSDictionary *)dictionary
                                               screenId:(NSString *)screenId
                                                 prefix:(ModelPrefix)prefix {
    NSDictionary *retVal = nil;
    NSArray *prefixesArray = [self arrayOfPrefixesByPrefix:prefix
                                               forScreenId:screenId];
    
    for (NSString *searchedKey in prefixesArray) {
        if (dictionary[searchedKey]) {
            retVal = dictionary[searchedKey];
            break;
        }
    }
    return retVal;
}


+ (NSDictionary *)customizationDictionaryFromDictionary:(NSDictionary *)dictionary
                                                  model:(NSObject *)model
                                                 prefix:(ModelPrefix)prefix {
    NSDictionary *retVal = nil;
    NSArray *prefixesArray = [self arrayOfPrefixesByPrefix:prefix
                                                  forModel:model];
    
    for (NSString *searchedKey in prefixesArray) {
        if (dictionary[searchedKey]) {
            retVal = dictionary[searchedKey];
            break;
        }
    }
    return retVal;
}

+ (NSArray *)arrayOfPrefixesByPrefix:(ModelPrefix)prefix
                         forScreenId:(NSString *)screenId{
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    switch (prefix) {
        case ModelPrefixScreenID:
        case ModelPrefixALL:
            [retVal addObject:[NSString stringWithFormat:@"screen_id.%@",screenId]];
            break;
        default:
            break;
    }
    return retVal;
}

+ (NSArray *)arrayOfPrefixesByPrefix:(ModelPrefix)prefix
                            forModel:(NSObject *)model {
    APModel *modelInstance = (APModel*)model;
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    switch (prefix) {
        case ModelPrefixNone:
            break;
        case ModelPrefixID:
            
            if ([modelInstance isKindOfClass:[APModel class]] && [modelInstance respondsToSelector:@selector(uniqueID)]) {
                [retVal addObject:[NSString stringWithFormat:@"id.%@",modelInstance.uniqueID]];
            }
            break;
        case ModelPrefixALL:
            if ([modelInstance isKindOfClass:[APModel class]] && [modelInstance respondsToSelector:@selector(uniqueID)]) {
                [retVal addObject:[NSString stringWithFormat:@"id.%@",modelInstance.uniqueID]];
            }
            break;
        default:
            break;
    }
    return retVal;
}

+ (id)valueFromDictionary:(NSDictionary *)dictionary
                 forModel:(NSObject *)model
                  withKey:(NSString *)key {
    return [self valueFromDictionary:dictionary
                            forModel:model
                      componentModel:nil
                             withKey:key];
}


//+ (id)dictionaryFromComponentModel:(NSObject *)model {
//
//    if ([model isKindOfClass:[ComponentModel class]] == YES) {
//        NSString *styleName =
//    }
//
//    return [self valueFromDictionary:dictionary
//                            forModel:model
//                      componentModel:nil
//                             withKey:key];
//}


@end
