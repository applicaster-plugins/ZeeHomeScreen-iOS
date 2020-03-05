//
//  ComponenttFactory.h
//  ZeeHomeScreen
//
//  Created by Miri on 11.12.19.
//

#import "ComponenttFactory.h"

@class APModel;
@class ComponentModel;

@class ComponentViewController;
@protocol ComponentProtocol;
@protocol ComponentDelegate;

@interface ComponenttFactory : NSObject

#pragma mark - Public Methods

+ (UIViewController <ComponentProtocol>  *)componentViewControllerWithComponentModel:(ComponentModel *)componentModel
                                                                              andModel:(NSObject *)model
                                                                               forView:(UIView *)view
                                                                              delegate:(id <ComponentDelegate>) delegate
                                                                  parentViewController:(UIViewController *)parentViewController;

+ (UIViewController <ComponentProtocol> *)viewControllerForComponentModel:(ComponentModel *)componentModel
                                                                withModel:(APModel *)model;

@end
