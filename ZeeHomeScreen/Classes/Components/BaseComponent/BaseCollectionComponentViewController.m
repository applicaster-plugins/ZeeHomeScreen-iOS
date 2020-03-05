//
//  BaseCollectionComponentViewController.m
//
//  Created by Miri
//
//

@import ApplicasterSDK;

#import "ComponenttFactory.h"
#import "BaseCollectionComponentViewController.h"
//#import "ComponentModel+Customization.h"
#import "RefreshManager.h"

@interface BaseCollectionComponentViewController ()

@end

@implementation BaseCollectionComponentViewController

- (void)setupComponentDefinitions:(NSDictionary*)attributes {
    self.collectionMinimumLineSpacing = [attributes[@"line_spacing"] floatValue];
    self.collectionMinimumLineSpacing = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:self.collectionMinimumLineSpacing];
    
    self.collectionMinimumInteritemSpacing = [attributes[@"interitem_spacing"] floatValue];
    self.collectionMinimumInteritemSpacing = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:self.collectionMinimumInteritemSpacing];
    
    CGFloat topInset = [attributes[@"inset_top"] floatValue];
    topInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:topInset];
    
    CGFloat leftInset = [attributes[@"inset_left"] floatValue];
    leftInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:leftInset];
    
    CGFloat bottomInset = [attributes[@"inset_bottom"] floatValue];
    bottomInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:bottomInset];
    
    CGFloat rightInset = [attributes[@"inset_right"] floatValue];
    rightInset = [APScreenMultiplierConverter convertedValueForScreenMultiplierWithValue:rightInset];
    
    self.collectionInsets = UIEdgeInsetsMake(topInset,
                                             leftInset,
                                             bottomInset,
                                             rightInset);
}

@end
