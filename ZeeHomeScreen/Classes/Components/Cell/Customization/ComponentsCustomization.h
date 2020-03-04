//
//  ComponentsCustomization.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

#import <Foundation/Foundation.h>

@class ComponentModel;

#pragma mark - Enums
typedef NS_OPTIONS(NSInteger, ModelPrefix) {
    ModelPrefixNone    = 0,
    ModelPrefixID      = 1 << 0,
    ModelPrefixScreenID  = 1 << 1,
    ModelPrefixALL     = ModelPrefixID | ModelPrefixScreenID
};

@interface ComponentsCustomization : NSObject

+ (id)valueFromDictionary:(NSDictionary *)dictionary
                 forModel:(NSObject *)model
                  withKey:(NSString *)key;

+ (id)valueFromDictionary:(NSDictionary *)dictionary
                 forModel:(NSObject *)model
           componentModel:(ComponentModel *)componentModel
                  withKey:(NSString *)key;

+ (id)valueFromDictionary:(NSDictionary *)dictionary
                forScreen:(NSString *)screenId
                 forModel:(NSObject *)model
                  withKey:(NSString *)key;

+ (NSDictionary *)customizationDictionaryFromDictionary:(NSDictionary *)dictionary
                                                  model:(NSObject *)model
                                                 prefix:(ModelPrefix)prefix;

+ (NSDictionary *)customizationDictionaryFromDictionary:(NSDictionary *)dictionary
                                               screenId:(NSString *)screenId
                                                 prefix:(ModelPrefix)prefix;
@end
