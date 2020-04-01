//
//  ComponentModel+Customization.h
//  ZeeHomeScreen
//
//  Created by Miri on 18/02/2020.
//

@import UIKit;
@import ZappPlugins;
@protocol ComponentProtocol;

extern NSString * const kZeeCellTappedShareButtonNotification;
extern NSString * const kZeeCellTappedCleanButtonNotification;
extern NSString * const kZeeCellTappedBackButtonNotification;
extern NSString * const kZeeCellSetupSearchBarNotification;

static NSNotificationName const ZeeComponentLoaded = @"CAComponentLoaded";

typedef NS_ENUM(NSInteger, ZeeComponentState) {
    ZeeComponentStateNormal,
    ZeeComponentStateSelected,
    ZeeComponentStateHighlighted,
    ZeeComponentStateDisabled
};

typedef NS_ENUM(NSInteger, ZeeComponentEndDisplayingReason)
{
    ZeeComponentEndDisplayingReasonUndefined = 0,
    ZeeComponentEndDisplayingReasonCellQueued = 1,
    ZeeComponentEndDisplayingReasonParent = 2
};

#pragma mark - AttributeKeys
extern NSString *const kAttributeImageTagKey;
extern NSString *const kAttributeImageModeKey;
extern NSString *const kAttributeParentImageTagKey;
extern NSString *const kAttributeBackgroundImageTagKey;
extern NSString *const kAttributeBackgroundImageNameKey;
extern NSString *const kAttributeUniversalCellBackgroundImageNameKey;
extern NSString *const kAttributeLogoImageTagKey;
extern NSString *const kAttributeUseImageBaseFallbackKey;

extern NSString *const kAttributesWidthPercentKey;
extern NSString *const kAttributesWidthPixelKey;
extern NSString *const kAttributesHeightPercentKey;
extern NSString *const kAttributesHeightPixelKey;
extern NSString *const kAttributesHeightRemainingAfterPixelKey;
extern NSString *const kAttributesAspectRatioKey;

extern NSString *const kAttributeBackgroundColorKey;
extern NSString *const kAttributeBackgroundLabelTextKey;
extern NSString *const kAttributeBackgroundLabelKey;
extern NSString *const kAttributeAdUnitKey;
extern NSString *const kAttributeBannerTypeKey;
extern NSString *const kAttributeBackgroundKey;

extern NSString *const kAttributeDateFormatKey;
extern NSString *const kAttributeTodayDateFormatKey;

extern NSString *const kAttributeInlinePlayerEnabledKey;
extern NSString *const kAttributeInlinePlayerShouldNotAutoPlayKey;
extern NSString *const kAttributeInlinePlayerShouldAutoPlayMute;

// Collection attributes
extern NSString *const kAttributesLineSpacingKey;
extern NSString *const kAttributesInterItemSpacingKey;
extern NSString *const kAttributeScrollDirectionKey;
extern NSString *const kAttributeIsOrderByRTLKey;
extern NSString *const kAttributeShowsHorizontalScrollIndicatorKey;
extern NSString *const kAttributeShowsVerticalScrollIndicatorKey;
extern NSString *const kAttributeBouncesKey;
extern NSString *const kAttributePagingKey;

extern NSString *const kAttributesInsetTopKey;
extern NSString *const kAttributesInsetLeftKey;
extern NSString *const kAttributesInsetBottomKey;
extern NSString *const kAttributesInsetRightKey;

extern NSString *const kAttributesHeaderInsetLeftKey;
extern NSString *const kAttributesHeaderInsetRightKey;

extern NSString *const kAttributesFooterInsetLeftKey;
extern NSString *const kAttributesFooterInsetRightKey;

extern NSString *const kAttributeImageShadowKey;
extern NSString *const kAttributeImageItemKey;
extern NSString *const kAttributeImageNameKey;

extern NSString *const kAttributesPaddingTopKey;
extern NSString *const kAttributesPaddingLeftKey;
extern NSString *const kAttributesPaddingBottomKey;
extern NSString *const kAttributesPaddingRightKey;

extern NSString *const kAttributeRepeatGroupsKey;
extern NSString *const kAttributeRepeatSectionBodyKey;
extern NSString *const kAttributeRepeatSectionBodyEnabledKey;
extern NSString *const kAttributeRepeatSectionBodyPatternKey;

// Labels
extern NSString *const kAttributeLabelParentTitleKey;
extern NSString *const kAttributeLabelTitleKey;
extern NSString *const kAttributeLabelSubTitleKey;
extern NSString *const kAttributeLabelDescriptionKey;
extern NSString *const kAttributeLabelPromotionKey;
extern NSString *const kAttributeLabelTimeKey;
extern NSString *const kAttributeLabelAuthorKey;

extern NSString *const kAttributeLabelBroadcastTimeKey;
extern NSString *const kAttributeLabelDurationKey;
extern NSString *const kAttributeLabelActionKey;
extern NSString *const kAttributeLabelCategoryTypeKey;
extern NSString *const kAttributeLabelDetailsKey;
extern NSString *const kAttributeLabelHintKey;

// ProgressBars
extern NSString *const kAttributeBroadcastTimeProgressBarKey;

// TextViews
extern NSString *const kAttributeTextViewDescriptionKey;

// Segmented control
extern NSString *const kAttributesSegmentedControlWidthPixelKey;

// Carousel
extern NSString *const kCarouselAutoSwipeDisabledTypeKey;
extern NSString *const kCarouselCyclicDisabledTypeKey;

// Page control
extern NSString *const kAttributePageControlBarHeightKey;
extern NSString *const kAttributePageControlBarSpacingKey;
extern NSString *const kAttributePageControlSelectedColorKey;
extern NSString *const kAttributePageControlNormalColorKey;

//
extern NSString *const kAttributesSelectedIndicatorImageKey;
extern NSString *const kAttributesIndicatorImageKey;

// Cells
extern NSString *const kAttributeCellDontAllowInfoKey;

extern NSString *const kAttributeCellPlaceholderImageNameKey;

extern NSString *const kAttributeCellDontAllowCellFlipping;

//Images
extern NSString *const kAttributeImageShadowKey;
extern NSString *const kAttributeImageItemKey;

//Videos
extern NSString *const kAttributeVideoScaleKey;

//
extern NSString *const kAttributeBorderColorKey;
extern NSString *const kAttributeBorderWidthKey;
extern NSString *const kAttributeCornerRadiusKey;
extern NSString *const kAttributeHintViewColorKey;
extern NSString *const kAttributeShouldAutoHideWhenEmptyKey;

// Promo Video
extern NSString *const kAttributePromoVideoContainer;
extern NSString *const kAttributePromoVideoKey;
extern NSString *const kAttributePromoDisplayAnimation;

// Actions
extern NSString *const kAttributeLinkCategoryActionPushKey;
extern NSString *const kAttributeDontAllowDidSelectActionsKey;
extern NSString *const kAttributeUsePromotionNameAsTitleKey;
extern NSString *const kAttributeUsePromotionNameAsTitleForCategoryKey;
extern NSString *const kAttributeAllowWhitespacesKey;
extern NSString *const kAttributeAutoScrollOnSelectionKey;

extern NSString *const kAttributeLabelCustomizationFontNameKey;
extern NSString *const kAttributeLabelCustomizationFontSizeKey;
extern NSString *const kAttributeLabelCustomizationFontColorKey;

//Screen Picker
extern NSString *const kScreenPickerMarginKey;

@class APProgram;
@class ComponentModel;
@class CellModel;

@interface ComponentModelCustomization : NSObject

- (id)valueForAttributeKey:(NSString *)key
                 withModel:(NSObject *)model;

- (NSURL *)customizationForImageURLForAttibuteKey:(NSString *)key
                                        withModel:(NSObject *)model;

+ (void)customizationForLabel:(UILabel *)label
              labelDictionary:(NSDictionary *)labelDictionary
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState;

- (void)customizationForLabel:(UILabel *)label
                 attributeKey:(NSString *)attributeKey
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState;

- (void)customizationForLabel:(UILabel *)label
              labelDictionary:(NSDictionary *)labelDictionary
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState;

- (void)customizationForLabel:(UILabel *)label
              labelDictionary:(NSDictionary *)labelDictionary
             fontSizeMultiply:(CGFloat)fontSizeMultiply
          lineSpacingMultiply:(CGFloat)lineSpacingMultiply
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState;

- (void)customizationForView:(UIView *)view
                 attibuteKey:(NSString *)key
                   withModel:(NSObject *)model;

- (void)customizationForLabel:(UILabel *)label
                 attributeKey:(NSString *)attributeKey
                    withModel:(CellModel *)model
             fontSizeMultiply:(CGFloat)fontSizeMultiply
          lineSpacingMultiply:(CGFloat)lineSpacingMultiply
               componentState:(ZeeComponentState)componentState;

- (void)customizationForButton:(UIButton *)button
                  attributeKey:(NSString *)attributeKey
   defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                     withModel:(NSObject *)model
                    withDelegate:(UIViewController <ComponentProtocol> *)delegate;

- (void)customizationForTextView:(UITextView *)textView
                    attributeKey:(NSString *)key
                       withModel:(NSObject *)model
                fontSizeMultiply:(CGFloat)fontSizeMultiply;

- (void)customizationForTextView:(UITextView *)textField
                    attributeKey:(NSString *)key
                       withModel:(NSObject *)model;

- (void)customizationForImageView:(UIImageView *)imageView
                     attributeKey:(NSString *)attributeKey
      defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                        withModel:(NSObject *)model
                   componentState:(ZeeComponentState)componentState;

- (void)customizationForImageView:(UIImageView *)imageView
                     attributeKey:(NSString *)attributeKey
             attributesDictionary:(NSDictionary *)attributesDictionary
      defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                        withModel:(NSObject *)model
                   componentState:(ZeeComponentState)componentState;

//- (void)customizationForActivityIndicator:(CAActivityIndicatorContainerView *)activityIndicatorContainerView
//                             attributeKey:(NSString *)attributeKey
//                                withModel:(NSObject *)model;

- (id)valueOfCustomizationDictionary:(NSDictionary *)dictionary
                            forModel:(NSObject *)model
                             withKey:(NSString *)key;

- (NSArray *)allValuesCustomizationDictionary:(NSDictionary *)dictionary
                                      forKey:(NSString *)key;

- (UIColor *)colorForAttributeKey:(NSString *)attributeKey
                   attributesDict:(NSDictionary *)attributesDict
                        withModel:(NSObject *)model
                   componentState:(ZeeComponentState)componentState;

- (UIFont *)fontForAttributesDict:(NSDictionary *)attributesDict
                        withModel:(NSObject *)model
                 fontSizeMultiply:(CGFloat)fontSizeMultiply
                   componentState:(ZeeComponentState)componentState;

@end
