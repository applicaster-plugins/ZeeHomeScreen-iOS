//
//  UniversalCollectionViewCell.m
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

#import "UniversalCollectionViewCell.h"
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>

@interface UniversalCollectionViewCell()

@property (nonatomic) NSLayoutConstraint *cellWidthConstraint;
@property (nonatomic) NSLayoutConstraint *cellHeightConstraint;

- (void)updateFlexibilityConstraints:(ComponentModel *)componentModel;

@end

@implementation UniversalCollectionViewCell

-(void)prepareForReuse {
    [super prepareForReuse];

    if (self.parentHandlesReusingComponent) {
        if ([self.componentViewController respondsToSelector:@selector(prepareComponentForReuse)]) {
            [self.componentViewController prepareComponentForReuse];
        }
    } else {
        [self.componentViewController removeViewFromParentViewController];
        _componentViewController = nil;
    }
}

-(void)setComponentViewController:(UIViewController<ComponentProtocol> *)componentViewController {
    if (_componentViewController != nil) {
        [_componentViewController removeViewFromParentViewController];
    }

    _componentViewController = componentViewController;

    [self.contentView addSubview:_componentViewController.view];
    [_componentViewController.view setInsetsFromParent:UIEdgeInsetsZero];
    _componentViewController.view.backgroundColor = UIColor.clearColor;
}

- (void)setBackgroundImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if (self.width > image.size.width) {
        //resize image to cell size
        image = [image imageScaledToFitSize:self.size];
    }
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}

// MARK: - Private functions

- (void)updateFlexibilityConstraints:(ComponentModel *)componentModel
{
//    self.cellHeightConstraint.active = NO;
//    self.cellWidthConstraint.active = NO;

    // The frame's height should be set by the collection view's layout, so we can fix the constant constraints
    // using those values

//    NSNumber *flexibleHeight = componentModel.attributes[kAttributesFlexibleHeight];
//    if ([flexibleHeight isKindOfClass:[NSNumber class]] && [flexibleHeight boolValue])
//    {
//        self.cellWidthConstraint.constant = CGRectGetWidth(self.frame);
//        self.cellWidthConstraint.active = YES;
//    }
//
//    NSNumber *flexibleWidth = componentModel.attributes[kAttributesFlexibleWidth];
//    if ([flexibleWidth isKindOfClass:[NSNumber class]] && [flexibleWidth boolValue])
//    {
//        self.cellHeightConstraint.constant = CGRectGetHeight(self.frame);
//        self.cellHeightConstraint.active = YES;
//    }
}

@end
