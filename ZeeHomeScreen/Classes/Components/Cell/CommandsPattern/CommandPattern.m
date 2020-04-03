//
//  CommandPattern.m
//  
//
//  Created by Miri on 18/02/2020.
//
//
@import ZappSDK;
#import "CommandPattern.h"
#import <ZappSDK/CAAbstractModel.h>
#import <ZappSDK/CAAppDefineComponent.h>
@import ApplicasterSDK;

static NSDictionary *__conditionMethodsDictionary;

@implementation CommandPattern : NSObject

+ (BOOL)hasCommandInObject:(id)object {
    BOOL retVal = NO;
    if ([object isKindOfClass:[NSString class]] && [object hasPrefix:@"${"]) {
        retVal = YES;
    }
    
    return retVal;
}

+ (id)resultFromCommand:(NSString *)command
                  model:(CAAbstractModel *)model {
    id retVal = nil;
    if ([self hasPathCommandInCommand:command]) {
        retVal = [self objectFromPathCommand:command
                                       model:model];
    }
    else if ([self hasConditionCommandInCommand:command]) {
        retVal = [self objectFromConditionCommand:command
                                            model:model];
    } else {
        APLoggerError(@"Can't return result from command, No command found!");
    }
    
    return retVal;
}

#pragma mark Path

+ (BOOL)hasPathCommandInCommand:(NSString *)command {
    BOOL retVal = NO;
    NSArray *arr = [self matchesInString:command
                            regexPattern:@"^\\$\\{\\w+\\}\\.\\w+"];
    if ([arr count] == 1) {
        retVal = YES;
    }
    
    return retVal;
}

+ (id)objectFromPathCommand:(NSString *)pathCommand
                      model:(CAAbstractModel *)model {
    id retVal = nil;
    NSString *pathCommandOnly = [[self stringsArrayInString:pathCommand
                                    matchingRegexPattern:@"^\\$\\{\\w+\\}(\\.\\w+)*"] firstObject];
    
    NSArray *pathCommandComponents = [self stringsArrayInString:pathCommandOnly
                                         matchingRegexPattern:@"\\w+"];
    
    CAAbstractModel *pathModel = [self pathModelFromPathVariable:[pathCommandComponents firstObject]
                                                           model:model];
    
    NSMutableArray *pathKeyComponents = [NSMutableArray arrayWithArray:pathCommandComponents];
    [pathKeyComponents removeObjectAtIndex:0]; // Remove model key
    NSString *commandResult = [self recursiveValueFromPathKeys:pathKeyComponents
                                       object:pathModel.object];
    if (!commandResult) {
        commandResult = @"<null>";
    } else if ([commandResult isKindOfClass:[NSNumber class]]) {
        commandResult = [(NSNumber *)commandResult boolValue] ? @"Yes" : @"No";
    }
    
    retVal = [pathCommand stringByReplacingOccurrencesOfString:pathCommandOnly
                                                    withString:commandResult];
    if ([retVal isEqualToString:@"<null>"]) {
        retVal = nil;
    }
    
    return retVal;
}

+ (id)recursiveValueFromPathKeys:(NSArray *)pathKeys
                          object:(NSDictionary *)object {
    id retVal = nil;
    NSString *currentKey = [pathKeys firstObject];
    if ([pathKeys count] > 1) {
        NSDictionary *newObject = object[currentKey];
        if ([newObject isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *newPathKeys = [NSMutableArray arrayWithArray:pathKeys];
            [newPathKeys removeObjectAtIndex:0]; // Remove current key
            retVal = [self recursiveValueFromPathKeys:[newPathKeys copy]
                                               object:newObject];
        }
    }
    else {
        retVal = object[currentKey];
    }
    
    return retVal;
}

+ (CAAbstractModel *)pathModelFromPathVariable:(NSString *)pathVariable
                                         model:(CAAbstractModel *)model {
    __block CAAbstractModel *retVal = nil;
    
    if ([pathVariable isKindOfClass:[NSString class]] && [model isKindOfClass:[CAAbstractModel class]]) {
        if ([pathVariable isEqualToString:@"MODEL"]) {
            retVal = model;
        }
        else {
            [[CAAppDefineComponent sharedInstance] abstractModelForAbstractModelName:pathVariable completion:^(CAAbstractModel *abstractModel, NSError *error) {
                retVal = abstractModel;
            }];
        }
    }
    
    return retVal;
}

#pragma mark Condition

+ (BOOL)hasConditionCommandInCommand:(NSString *)command {
    BOOL retVal = NO;
    NSArray *arr = [self matchesInString:command
                            regexPattern:@"^\\$\\{(.+)\\} \\? (.+) : (.+)"];
    if ([arr count] == 1) {
        retVal = YES;
    }
    
    return retVal;
}

+ (id)objectFromConditionCommand:(NSString *)command
                           model:(CAAbstractModel *)model {
    id retVal = nil;
    static NSUInteger kConditionIndex = 0;
    static NSUInteger kTrueValueIndex = 1;
    static NSUInteger kFalseValueIndex = 2;
    
    NSArray *commandComponents = [self groupArrayInString:command
                                     matchingRegexPattern:@"^\\$\\{(.+)\\} \\? (.+) : (.+)"];
    
    NSString *condition = commandComponents[kConditionIndex];
    
    if ([self hasCommandInObject:condition]) {
        condition = [self resultFromCommand:condition
                                      model:model];
    }
    
    NSString *resultString = [self resultFromCondition:condition
                                                 model:model];
    
    if (resultString) {
        if ([resultString compare:@"Yes" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            retVal = [commandComponents[kTrueValueIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        else {
            retVal = [commandComponents[kFalseValueIndex] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }
    
    if ([retVal isEqualToString:@"<null>"] || !resultString) {
        retVal = nil;
    }
    
    return retVal;
}

// Return @"Yes" for true, @"No" for false or nil
+ (NSString *)resultFromCondition:(NSString *)condition
                      model:(CAAbstractModel *)model {
    NSString *retVal = nil;
    BOOL boolValue = NO;
//    NSString *methodName = [self conditionMethodMappedName:condition];
//
//    if ([methodName length] > 0) {
//        //start condition method and get the results fo it
//        SEL selector = NSSelectorFromString(methodName);
//        CACommandPattern *commandPattern = [CACommandPattern new];
//        if ([commandPattern respondsToSelector:selector]) {
//            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
//                                        [self instanceMethodSignatureForSelector:selector]];
//            [invocation setSelector:selector];
//            [invocation setTarget:commandPattern];
//            if ([methodName doesStringContainString:@":"]) {
//                NSUInteger methodParameterIndex = 2;
//                [invocation setArgument:&model atIndex:methodParameterIndex];
//            }
//
//            [invocation invoke];
//            [invocation getReturnValue:&boolValue];
//
//            retVal = boolValue ? @"Yes" : @"No";
//        }
//        else {
//            APLoggerError(@"Not found condition rule, returning true value");
//        }
//    }
//    else if ([condition length] > 0) {
//        if (([condition compare:@"Yes" options:NSCaseInsensitiveSearch] == NSOrderedSame) ||
//             ([condition compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
//            retVal = @"Yes";
//        } else if (([condition compare:@"No" options:NSCaseInsensitiveSearch] == NSOrderedSame) ||
//                   ([condition compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame)) {
//            retVal = @"No";
//        }
//    }
    retVal = @"No";
    return retVal;
}

+ (NSString *)conditionMethodMappedName:(NSString *)conditionName{
    NSString *retVal = nil;
    
    if ([conditionName isNotEmpty]) {
        [self mappingConditionsDictionary];
        NSString *className = __conditionMethodsDictionary[conditionName];
        if ([className isNotEmptyOrWhiteSpaces]) {
            retVal = className;
        }
    }
    
    return retVal;
}

+ (void)mappingConditionsDictionary {
//    if (__conditionMethodsDictionary == nil) {
//        NSString *path = [[ComponentsSDK  bundle] pathForResource:@"CAComponentsConditionsMapping" ofType:@"plist"];
//        __conditionMethodsDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
//    }
}


#pragma mark Condition

- (BOOL)isSubscribed {
    return ([[[APApplicasterController sharedInstance] endUserProfile] latestVoucherDomainTypeApp] != nil);
}

- (BOOL)isSubscribedOrFreeItem:(CAAbstractModel *)model {
    BOOL retVal = NO;
    if ([self isSubscribed]) {
        retVal = YES;
    }
    else if ([model.originModel isKindOfClass:[APVodItem class]]) {
        APVodItem *vodItem = (APVodItem *)model.originModel;
        retVal = [vodItem isFree];
    }
    
    return retVal;
}

#pragma mark - Regex helpers


+ (NSArray *)stringsArrayInString:(NSString *)string
             matchingRegexPattern:(NSString *)pattern {
    NSArray *retVal = nil;
    
    NSArray *matchesFound = [self matchesInString:string
                                     regexPattern:pattern];
    if (matchesFound) {
        NSMutableArray *resultsArray = [NSMutableArray new];
        for (NSTextCheckingResult *match in matchesFound) {
            [resultsArray addObject:[string substringWithRange:[match range]]];
        }
        retVal = [resultsArray copy];
    }
    
    return retVal;
}

+ (NSArray *)groupArrayInString:(NSString *)string
           matchingRegexPattern:(NSString *)pattern {
    NSArray *retVal = nil;
    
    NSArray *matchesFound = [self matchesInString:string
                                     regexPattern:pattern];
    if (matchesFound) {
        NSMutableArray *resultsArray = [NSMutableArray new];
        for (NSTextCheckingResult *match in matchesFound) {
            for (NSUInteger index = 1; index < [match numberOfRanges]; index++) {
                [resultsArray addObject:[string substringWithRange:[match rangeAtIndex:index]]];
            }
        }
        retVal = [resultsArray copy];
    }
    
    return retVal;
}

+ (NSArray *)matchesInString:(NSString *)string
                regexPattern:(NSString *)pattern {
    NSArray *retVal = nil;
    NSError *error = nil;
    NSRange searchedRange = NSMakeRange(0, [string length]);
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    retVal = [regex matchesInString:string
                            options:0
                              range:searchedRange];
    return retVal;
}
@end
