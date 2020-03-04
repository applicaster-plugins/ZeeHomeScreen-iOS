//
//  UniversalCollectionViewHeaderFooterView.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//


@import UIKit;

@protocol ComponentProtocol;
@protocol UniversalCollectionViewHeaderFooterViewDelegate;

@interface UniversalCollectionViewHeaderFooterView : UICollectionReusableView
@property (nonatomic, strong) UIViewController <ComponentProtocol> *componentViewController;
@property (nonatomic, weak)id <UniversalCollectionViewHeaderFooterViewDelegate>delegate;
-(void)setBackgroundImage:(NSString *) imageName;
@end

@protocol UniversalCollectionViewHeaderFooterViewDelegate <NSObject>
- (void)headerFooterViewDidSelect:(UniversalCollectionViewHeaderFooterView *)headerFooterView;
@end
