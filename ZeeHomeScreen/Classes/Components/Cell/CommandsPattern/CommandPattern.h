//
//  CommandPattern.h
//  
//
//  Created by Miri on 18/02/2020.
//
//

@import ApplicasterSDK;

#import <Foundation/Foundation.h>
#import "CAAbstractModel.h"

@class CAAbstractModel;

@interface CommandPattern : NSObject

+ (BOOL)hasCommandInObject:(id)object;

+ (id)resultFromCommand:(NSString *)command
                  model:(CAAbstractModel *)modCACommandPatternrnmark;

// Path command should follow this convection "${model}.tes1.test2"

+ (BOOL)hasPathCommandInCommand:(NSString *)command;

// MODEL
// ZAPP_STYLES

+ (CAAbstractModel *)pathModelFromPathVariable:(NSString *)pathVariable
                                         model:(CAAbstractModel *)model;

// Condition command should follow this convection  "${condition} ? trueValue : falseValue"

+ (BOOL)hasConditionCommandInCommand:(NSString *)command;

@end
