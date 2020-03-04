//
//  BaseCollectionComponentViewController.h
//
//
//  Created by Miri
//
//

#import <UIKit/UIKit.h>
#import "BaseComponentViewController.h"

@interface BaseCollectionComponentViewController : BaseComponentViewController

@property (nonatomic, assign) CGFloat collectionMinimumLineSpacing;
@property (nonatomic, assign) CGFloat collectionMinimumInteritemSpacing;
@property (nonatomic, assign) UIEdgeInsets collectionInsets;

@end
