//
//  UniversalCollectionViewHeaderFooterView.m
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

#import "UniversalCollectionViewHeaderFooterView.h"
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>

@implementation UniversalCollectionViewHeaderFooterView

-(void)prepareForReuse {
    [super prepareForReuse];

    _delegate = nil;

    [self.componentViewController removeViewFromParentViewController];
    _componentViewController = nil;
}

-(void)setComponentViewController:(UIViewController<ComponentProtocol> *)componentViewController {
    if (_componentViewController != nil) {
        [_componentViewController removeViewFromParentViewController];
    }
    
    _componentViewController = componentViewController;

    [self addSubview:_componentViewController.view];
    [_componentViewController.view setInsetsFromParent:UIEdgeInsetsZero];
    _componentViewController.view.backgroundColor = UIColor.clearColor;
}

-(void)setBackgroundImage:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
//    if (self.width > image.size.width) {
//        //resize image to cell size
//        image = [image imageScaledToFitSize:self.size];
//    }
    self.backgroundColor = [UIColor colorWithPatternImage:image];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches
          withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];

    if ([self.delegate respondsToSelector:@selector(headerFooterViewDidSelect:)]) {
        [self.delegate headerFooterViewDidSelect:self];
    }
}

@end
