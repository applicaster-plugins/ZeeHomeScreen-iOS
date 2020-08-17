//
//  ComponenttFactory.h
//  ZeeHomeScreen
//
//  Created by Miri on 11.12.19.
//

@class ComponentModel;

@protocol ComponentProtocol;

@interface ComponenttFactory : NSObject

#pragma mark - Public Methods

+ (UIViewController <ComponentProtocol> *)viewControllerForComponentModel:(ComponentModel *)componentModel;

@end
