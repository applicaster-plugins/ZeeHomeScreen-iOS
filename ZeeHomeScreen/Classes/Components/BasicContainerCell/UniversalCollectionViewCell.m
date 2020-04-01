//
//  UniversalCollectionViewCell.m
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

#import "UniversalCollectionViewCell.h"
#import "CarouselViewController.h"
#import <ZeeHomeScreen/ComponenttFactory.h>
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>

@interface UniversalCollectionViewCell()

@property (nonatomic, strong) NSLayoutConstraint *cellWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *cellHeightConstraint;

- (void)updateFlexibilityConstraints:(ComponentModel *)componentModel;

@end

@implementation UniversalCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    if ([self.componentViewController respondsToSelector:@selector(prepareComponentForReuse)]) {
        [self.componentViewController prepareComponentForReuse];
    }
}

-(void)setComponentViewController:(UIViewController<ComponentProtocol> *)componentViewController {
    _componentViewController = componentViewController;
}

- (void)setComponentModel:(nullable ComponentModel *)componentModel
                    model:(nullable NSObject *)model
                     view:(nullable UIView *)view
                 delegate:(nullable id<ComponentDelegate>)delegate
     parentViewController:(nullable UIViewController *)parentViewController
{
    
    
//    if (self.componentViewController == nil) {
        self.componentViewController = [ComponenttFactory componentViewControllerWithComponentModel:componentModel
                                                                                           andModel:model
                                                                                            forView:view
                                                                                           delegate:delegate
                                                                               parentViewController:parentViewController];
//    }

    if ([self.componentViewController respondsToSelector:@selector(setDelegate:)]) {
        self.componentViewController.delegate = delegate;
    }

    if ([self.componentViewController respondsToSelector:@selector(setComponentDataSourceModel:)]) {
        self.componentViewController.componentDataSourceModel = componentModel;
    }

    if ([self.componentViewController respondsToSelector:@selector(setComponentModel:)]) {
        self.componentViewController.componentModel = componentModel;
    }

//    if (componentModel.attributes[kAttributesFlexibleHeight] || componentModel.attributes[kAttributesFlexibleWidth]) {
//        [self updateFlexibilityConstraints:componentModel];
//    }
}

- (void)setBackgroundImage:(nullable NSString *)imageName {
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
