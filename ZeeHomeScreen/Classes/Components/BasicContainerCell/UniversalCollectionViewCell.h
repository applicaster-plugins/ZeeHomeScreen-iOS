//
//  UniversalCollectionViewCell.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//


@import ZappPlugins;
#import <Foundation/Foundation.h>
#import "ComponentDelegate.h"
@class ComponentModel;
@class ComponentProtocol;

/**
 *  This cell used as container for all components. Do not remove or modify anything without premission
 */
@interface UniversalCollectionViewCell: UICollectionViewCell

@property (nullable, nonatomic, strong) UIViewController<ComponentProtocol> *componentViewController;

- (void)setComponentModel:(nullable ComponentModel *)componentModel
                    model:(nullable NSObject *)model
                     view:(nullable UIView *)view
                 delegate:(nullable id<ComponentDelegate>)delegate
     parentViewController:(nullable UIViewController *)parentViewController;

- (void)setBackgroundImage:(nullable NSString *)imageName;

@end
