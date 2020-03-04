//
//  CarouselViewController.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

@import ApplicasterUIKit;
#import "ComponentProtocol.h"
#import "ComponentDelegate.h"

@protocol ComponentProtocol;
@protocol ComponentDelegate;

@class APImageView;

extern NSString * const kCACarouselSwipedNotification;


@interface CarouselViewController : UIViewController  <ComponentProtocol, ComponentDelegate, APPromotionViewDataSource, APPromotionViewDelegate>

@property (nonatomic, weak) id <ComponentDelegate> delegate;

@property (nonatomic, weak) IBOutlet APPromotionView *carouselView;
@property (nonatomic, weak) IBOutlet UIView *borderView;
@property (strong, nonatomic) IBOutletCollection(APImageView) NSArray *imageViewCollectin;

@end
