//
//  UniversalCollectionViewCell.h
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

@import UIKit;

@protocol ComponentProtocol;

@interface UniversalCollectionViewCell: UICollectionViewCell

@property (nonatomic, weak) UIViewController<ComponentProtocol> *componentViewController;
@property (nonatomic) BOOL parentHandlesReusingComponent;

- (void)setBackgroundImage:(NSString *)imageName;

@end
