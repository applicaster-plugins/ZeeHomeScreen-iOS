//
//  CarouselViewController.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

@import ApplicasterUIKit;
#import "ComponentDelegate.h"

@protocol ComponentProtocol;
@protocol ComponentDelegate;

@class APImageView;
@class CellModel;
@class ComponentModel;
@class DatasourceManager;
@class ComponentProtocol;

extern NSString * const kCarouselSwipedNotification;


@interface CarouselViewController : UIViewController  <ComponentProtocol, ComponentDelegate, APPromotionViewDataSource, APPromotionViewDelegate>

@property (nonatomic, weak) id <ComponentDelegate> delegate;

@property (nonatomic, weak) IBOutlet APPromotionView *carouselView;
@property (nonatomic, weak) IBOutlet UIView *borderView;
@property (strong, nonatomic) IBOutletCollection(APImageView) NSArray *imageViewCollectin;

@end
