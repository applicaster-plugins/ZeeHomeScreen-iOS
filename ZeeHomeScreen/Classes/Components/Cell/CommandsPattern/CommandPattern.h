//
//  CommandPattern.h
//  
//
//  Created by Miri on 18/02/2020.
//
//

#import <Foundation/Foundation.h>
@class AbstractModel;

@interface CommandPattern : NSObject

+ (BOOL)hasCommandInObject:(id)object;

+ (id)resultFromCommand:(NSString *)command
                  model:(AbstractModel *)modCACommandPatternrnmark;

// Path command should follow this convection "${model}.tes1.test2"

+ (BOOL)hasPathCommandInCommand:(NSString *)command;

// MODEL
// ZAPP_STYLES

+ (AbstractModel *)pathModelFromPathVariable:(NSString *)pathVariable
                                         model:(AbstractModel *)model;

// Condition command should follow this convection  "${condition} ? trueValue : falseValue"

+ (BOOL)hasConditionCommandInCommand:(NSString *)command;

@end
