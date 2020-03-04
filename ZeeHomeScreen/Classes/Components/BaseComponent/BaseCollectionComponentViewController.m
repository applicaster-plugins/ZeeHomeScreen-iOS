//
//  BaseCollectionComponentViewController.m
//
//  Created by Miri
//
//

@import ApplicasterSDK;

#import "ComponenttFactory.h"
#import "BaseCollectionComponentViewController.h"
#import "ComponentModel+Customization.h"
#import "RefreshManager.h"

@interface BaseCollectionComponentViewController ()

@end

@implementation BaseCollectionComponentViewController

- (void)setupComponentDefinitions:(NSDictionary*)attributes {
    self.collectionMinimumLineSpacing = [attributes[kAttributesLineSpacingKey] floatValue];
    self.collectionMinimumLineSpacing = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:self.collectionMinimumLineSpacing];
    
    self.collectionMinimumInteritemSpacing = [attributes[kAttributesInterItemSpacingKey] floatValue];
    self.collectionMinimumInteritemSpacing = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:self.collectionMinimumInteritemSpacing];
    
    CGFloat topInset = [attributes[kAttributesInsetTopKey] floatValue];
    topInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:topInset];
    
    CGFloat leftInset = [attributes[kAttributesInsetLeftKey] floatValue];
    leftInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:leftInset];
    
    CGFloat bottomInset = [attributes[kAttributesInsetBottomKey] floatValue];
    bottomInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:bottomInset];
    
    CGFloat rightInset = [attributes[kAttributesInsetRightKey] floatValue];
    rightInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:rightInset];
    
    self.collectionInsets = UIEdgeInsetsMake(topInset,
                                             leftInset,
                                             bottomInset,
                                             rightInset);
}

@end
