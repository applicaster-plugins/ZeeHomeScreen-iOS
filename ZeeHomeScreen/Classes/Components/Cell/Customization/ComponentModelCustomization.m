//
//  ComponentModel+Customization.m
//  ZeeHomeScreen
//
//  Created by Miri on 18/02/2020.
//


@import ZappPlugins;
@import ApplicasterSDK;

#import "ComponentModelCustomization.h"

#import <ApplicasterSDK/APAtomEntry.h>
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>
#import <ZeeHomeScreen/ComponentsCustomization.h>

NSString *const kAttributesWidthPercentKey              = @"width_percent";
NSString *const kAttributesWidthPixelKey                = @"width_pixel";
NSString *const kAttributesHeightPercentKey             = @"height_percent";
NSString *const kAttributesHeightPixelKey               = @"height_pixel";
NSString *const kAttributesHeightRemainingAfterPixelKey = @"height_remaining_after_pixel";
NSString *const kAttributesAspectRatioKey               = @"aspect_ratio";

NSString *const kAttributesLineSpacingKey               = @"line_spacing";
NSString *const kAttributesInterItemSpacingKey          = @"interitem_spacing";
NSString *const kAttributeScrollDirectionKey            = @"scroll_direction";
NSString *const kAttributeIsOrderByRTLKey               = @"is_order_by_rtl";

NSString *const kAttributeShowsHorizontalScrollIndicatorKey = @"shows_horizontal_scroll_indicator";
NSString *const kAttributeShowsVerticalScrollIndicatorKey   = @"shows_vertical_scroll_indicator";
NSString *const kAttributeBouncesKey                    = @"bounces";
NSString *const kAttributePagingKey                     = @"paging";

NSString *const kAttributesInsetTopKey                  = @"inset_top";
NSString *const kAttributesInsetLeftKey                 = @"inset_left";
NSString *const kAttributesInsetBottomKey               = @"inset_bottom";
NSString *const kAttributesInsetRightKey                = @"inset_right";

NSString *const kAttributesHeaderInsetLeftKey           = @"header_inset_left";
NSString *const kAttributesHeaderInsetRightKey          = @"header_inset_right";

NSString *const kAttributesFooterInsetLeftKey           = @"header_inset_left";
NSString *const kAttributesFooterInsetRightKey          = @"header_inset_right";

NSString *const kAttributesPaddingTopKey                = @"padding_top";
NSString *const kAttributesPaddingLeftKey               = @"padding_left";
NSString *const kAttributesPaddingBottomKey             = @"padding_bottom";
NSString *const kAttributesPaddingRightKey              = @"padding_right";

NSString *const kAttributeRepeatGroupsKey               = @"repeat_group";
NSString *const kAttributeRepeatSectionBodyKey          = @"repeat_section_body";
NSString *const kAttributeRepeatSectionBodyEnabledKey   = @"enabled";
NSString *const kAttributeRepeatSectionBodyPatternKey   = @"pattern";

NSString *const kAttributeBackgroundColorKey            = @"background_color";
NSString *const kAttributeBackgroundLabelTextKey        = @"background_label_text";
NSString *const kAttributeBackgroundLabelKey            = @"background_label";
NSString *const kAttributeAdUnitKey                     = @"ad_unit";
NSString *const kAttributeBannerTypeKey                 = @"banner_type";
NSString *const kAttributeBackgroundKey                 = @"background";


NSString *const kAttributeBorderColorKey                = @"border_color";
NSString *const kAttributeHintViewColorKey              = @"hint_view_color";
NSString *const kAttributeBorderWidthKey                = @"border_width";

NSString *const kAttributeShouldAutoHideWhenEmptyKey    = @"should_auto_hide_when_empty";

NSString *const kAttributeMaskImageNameKey              = @"mask_image_name";

NSString *const kAttributeCornerRadiusKey              = @"corner_radius";

//
NSString *const kAttributeImageModeKey                  = @"image_mode";
NSString *const kAttributeImageTagKey                   = @"image_tag";
NSString *const kAttributeParentImageTagKey             = @"parent_image_tag";
NSString *const kAttributeBackgroundImageTagKey         = @"background_image_tag";
NSString *const kAttributeBackgroundImageNameKey        = @"background_image_name";
NSString *const kAttributeUniversalCellBackgroundImageNameKey        = @"universal_cell_background_image_name";
NSString *const kAttributeUseImageBaseFallbackKey       = @"use_image_base_fallback";


NSString *const kAttributeLogoImageTagKey               = @"logo_image_tag";
NSString *const kAttributeImageScaleKey                 = @"image_scale";

NSString *const kAttributeMediaTypeKey                  = @"media_type";
NSString *const kAttributeVideoScaleKey                 = @"video_scale";

NSString *const kAttributeDateFormatKey                 = @"date_format";
NSString *const kAttributeTodayDateFormatKey            = @"today_date_format";

NSString *const kAttributeInlinePlayerEnabledKey        = @"inline_player_enabled";
NSString *const kAttributeInlinePlayerShouldNotAutoPlayKey  = @"inline_player_should_not_auto_play";
NSString *const kAttributeInlinePlayerShouldAutoPlayMute    = @"inline_player_should_auto_mute";

// Carousel
NSString *const kCarouselAutoSwipeDisabledTypeKey       = @"auto_swipe_disabled";
NSString *const kCarouselCyclicDisabledTypeKey          = @"cyclic_disabled";

// Page control
NSString *const kAttributePageControlBarHeightKey       = @"page_control_bar_height";
NSString *const kAttributePageControlBarSpacingKey      = @"page_control_bar_spacing";
NSString *const kAttributePageControlSelectedColorKey   = @"page_control_color_selected";
NSString *const kAttributePageControlNormalColorKey     = @"page_control_color_normal";

// Labels
NSString *const kAttributeLabelParentTitleKey           = @"label_parent_title";
NSString *const kAttributeLabelTitleKey                 = @"label_title";
NSString *const kAttributeLabelSubTitleKey              = @"label_subtitle";
NSString *const kAttributeLabelTimeKey                  = @"label_time";
NSString *const kAttributeLabelPromotionKey             = @"label_promotion";
NSString *const kAttributeLabelDurationKey              = @"label_duration";
NSString *const kAttributeLabelBroadcastTimeKey         = @"label_broadcast_time";
NSString *const kAttributeLabelDescriptionKey           = @"label_description";
NSString *const kAttributeLabelActionKey                = @"label_action";
NSString *const kAttributeLabelAuthorKey                = @"label_author";
NSString *const kAttributeLabelDetailsKey               = @"label_article_details";
NSString *const kAttributeLabelCategoryTypeKey          = @"label_category_type";
NSString *const kAttributeLabelHintKey                  = @"label_hint";

// ProgressBars
NSString *const kAttributeBroadcastTimeProgressBarKey   = @"progress_bar_broadcast_time";

// TextViews
NSString *const kAttributeTextViewDescriptionKey       = @"text_view_description";

// Segmented control
// This key requires to have collectionWidthConstraint connected to the picker collection to update its value
NSString *const kAttributesSegmentedControlWidthPixelKey     = @"segmented_control_width_pixel";

// Cells
NSString *const kAttributeCellPlaceholderImageNameKey  = @"placeholder_image_name";

//Images
NSString *const kAttributeImageShadowKey               = @"image_shadow";
NSString *const kAttributeImageItemKey                 = @"image_item";
NSString *const kAttributeImageNameKey                 = @"image_name";

NSString *const kAttributeCellDontAllowInfoKey         = @"dont_allow_info";
NSString *const kAttributeCellDontAllowCellFlipping    = @"dont_allow_cell_flipping";

//
NSString *const kAttributesSelectedIndicatorImageKey   = @"selected_indicator_image_name";
NSString *const kAttributesIndicatorImageKey           = @"indicator_image_name";

//
NSString *const kAttributeCMSColor                      = @"cms_color";
NSString *const kAttributeValue                         = @"value";

// Promo Video

NSString *const kAttributePromoVideoContainer          = @"promo_video_container";
NSString *const kAttributePromoVideoKey                = @"promo_video_key";
NSString *const kAttributePromoDisplayAnimation        = @"display_animation_type";

// Actions
NSString *const kAttributeLinkCategoryActionPushKey    = @"link_categroy_push";
NSString *const kAttributeDontAllowDidSelectActionsKey = @"dont_allow_did_select_actions";
NSString *const kAttributeUsePromotionNameAsTitleKey   = @"use_promotion_name_as_title";
NSString *const kAttributeUsePromotionNameAsTitleForCategoryKey   = @"use_promotion_name_as_title_for_category";

NSString *const kAttributeAllowWhitespacesKey          = @"allow_whitespaces";

NSString *const kAttributeAutoScrollOnSelectionKey = @"auto_scroll_on_selection";

//Screen Picker
NSString *const kScreenPickerMarginKey                 = @"screen_picker_margin";

@interface NSMutableDictionary (uniteWithDictionary)
/**
 Adds to the receiving dictionary the entries from another dictionary.
 If both dictionaries contain the same key, the receiving dictionary’s previous value object for that key is overridden.
 Support in multi-level dictionaries: If both the reciving dictionary and otherDictionary contain the same key with a dictionary as a value,
 the values of that dictionary which exist only at the recieve dictionary will remain untouched. All other values will be overridden.

 @param otherDictionary .
 */
- (void)uniteWithDictionary:(NSDictionary *)otherDictionary;

@end

@implementation NSMutableDictionary (uniteWithDictionary)

- (void)uniteWithDictionary:(NSDictionary *)otherDictionary {
    for (id key in otherDictionary) {
        id value = otherDictionary[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
             NSDictionary *internalDict = self[key];
            if (internalDict == nil) {
                [self setValue:value forKey:key];
            }
            else {
                id internalCustomizationObject = [internalDict mutableCopy];
                NSMutableDictionary *combinedCustomizationDict = [(NSDictionary *)value mutableCopy];

                if ([internalCustomizationObject isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *mutableInternalDict = [(NSDictionary *)internalCustomizationObject mutableCopy];
                    [mutableInternalDict uniteWithDictionary:combinedCustomizationDict];
                    if (mutableInternalDict) {
                        combinedCustomizationDict = mutableInternalDict;
                    }
                }
                [self setValue:[combinedCustomizationDict copy] forKey:key];
            }
        }
        else {
            [self setValue:value forKey:key];
        }
    }
}

@end

@interface NSString (ZeeComponentState)

- (NSString *)stateAttributeKeyForComponentState:(ZeeComponentState)componentState;

@end

@implementation NSString (ZeeComponentState)

- (NSString *)stateAttributeKeyForComponentState:(ZeeComponentState)componentState {
    NSString *retVal = self;
    if ([retVal isNotEmptyOrWhiteSpaces]) {
        switch (componentState) {
            case ZeeComponentStateSelected:
                retVal = [retVal stringByAppendingString:@"_selected"];
                break;
            case ZeeComponentStateHighlighted:
                retVal = [retVal stringByAppendingString:@"_highlighted"];
                break;
            case ZeeComponentStateDisabled:
                retVal = [retVal stringByAppendingString:@"_disabled"];
                break;
            default:
                break;
        }
    }
    return retVal;
}

@end

@implementation ComponentModelCustomization


- (id)valueForAttributeKey:(NSString *)key
                 withModel:(ComponentModel *)model {
    id retVal = nil;
    
    NSString *type = model.containerType;
    NSString *cellKey = model.cellKey;
    NSMutableDictionary *customizationDict = [[self customizationStyleForModel:model] mutableCopy];
    NSDictionary *cellDict = [CustomizationManager dataForZappLayout:cellKey zappComponentType:type zappFamily:@"FAMILY_GANGES"];
    if (customizationDict == nil) { //the customization is taken only from the attributes, no customization in the componentCustomizationDictionary
        retVal = [self valueOfCustomizationDictionary:cellDict
                                             forModel:model
                                              withKey:key];
    }
    else {
        [customizationDict uniteWithDictionary:cellDict];
        retVal = [self valueOfCustomizationDictionary:[customizationDict copy]
                                             forModel:model
                                              withKey:key];
    }
    
    return retVal;
}
/*
- (id)valueForAttributeKey:(NSString *)key
                 withModel:(ComponentModel *)model {
    id retVal = nil;

    NSString *type = model.containerType;
    NSString *cellKey = model.cellKey;
    NSDictionary *cellDict = [CustomizationManager dataForZappLayout:cellKey zappComponentType:type zappFamily:@"FAMILY_GANGES"];
    id value = [cellDict objectForKey:key];

    if (value == nil) { //the customization is taken only from the attributes, no customization in the componentCustomizationDictionary
    }
    else {
        if ([value isKindOfClass:NSDictionary.class]) {
            retVal = [self valueOfCustomizationDictionary:[value copy]
            forModel:model
             withKey:key];
        } else {

            retVal = [self valueOfCustomizationDictionary:@{key: value}
            forModel:model
             withKey:key];
        }


    }

    return retVal;
}
*/
- (id)valueOfCustomizationDictionary:(NSDictionary *)dictionary forModel:(NSObject *)model withKey:(NSString *)key {
    id retVal = [ComponentsCustomization valueFromDictionary:dictionary
                                                      forModel:model
                                                       withKey:key];
    
    return retVal;
}

- (NSURL *)customizationForImageURLForAttibuteKey:(NSString *)key
                                        withModel:(NSObject *)model {
    NSString *imageURLString = nil;
    NSString *imageTag = nil;
    NSString *imageScale = nil;
    NSURL *retVal = nil;

    imageTag = [self valueForAttributeKey:key withModel:model];
    
    if ([imageTag isNotEmptyOrWhiteSpaces]) {
        //model is conforming protocol APAtomEntryProtocol and use imageScale
        if ([model conformsToProtocol:@protocol(APAtomEntryProtocol)] && [imageScale isNotEmptyOrWhiteSpaces]) {
            APAtomEntry *entryModel = (APAtomEntry *)model;
            imageScale = [self valueForAttributeKey:kAttributeImageScaleKey
                                          withModel:model];
            if ([entryModel respondsToSelector:@selector(imageNamed:)]) {
                imageURLString = [entryModel imageNamed:[NSString stringWithFormat:@"%@-%@",imageTag, imageScale]];
            }
        }
        
        //We are trying to get image from tag for the rest of the cases
        if (imageURLString == nil && [model respondsToSelector:@selector(imageNamed:)]) {
            imageURLString = imageTag ? [(id)model imageNamed:imageTag] : nil;
        }
        
        if ([imageURLString isNotEmptyOrWhiteSpaces]) {
            if ([[ZAAppConnector sharedInstance].connectivityDelegate isOffline]) {
                retVal = [[APCacheManager shared] getLocalPathForUrlString:imageURLString useMd5UrlFilename:YES];
            }
            else {
                retVal = [NSURL URLWithString:imageURLString];
            }
        }
        else if ([[self valueForAttributeKey:kAttributeUseImageBaseFallbackKey withModel:model] boolValue]) {
            //image url is empty - go to default
            imageURLString = nil;
            if (([imageTag isEqualToString:@"image_base"] == NO) && [(id)model respondsToSelector:@selector(imageNamed:)]) {
                imageURLString = [(id)model imageNamed:@"image_base"];
            }

            if ([imageURLString isNotEmptyOrWhiteSpaces]) {
                retVal = [NSURL URLWithString:imageURLString];
            }
        }
    }
    return retVal;
}

- (void)customizationForView:(UIView *)view
                 attibuteKey:(NSString *)key
                   withModel:(NSObject *)model {
    NSDictionary *viewDictionary = [self valueForAttributeKey:key withModel:model];
     
    if ([viewDictionary isNotEmpty]) {
        if ([viewDictionary[kAttributeBackgroundColorKey] isNotEmpty]) {
            NSString *colorString = viewDictionary[kAttributeBackgroundColorKey];
            view.backgroundColor = [UIColor colorWithRGBAHexString:colorString];
        }
        
        //kAttributeCornerRadiusKey
        NSString *attributeValue = [self attributeValueForAttribute:kAttributeCornerRadiusKey
                                               attributesDictionary:viewDictionary
                                        defaultAttributesDictionary:nil
                                                          withModel:model
                                                     componentState:ZeeComponentStateNormal];
        if ([attributeValue isKindOfClass:[NSString class]]) {
            CGFloat cornerRadius = [attributeValue floatValue];
            view.layer.cornerRadius = cornerRadius;
        } else {
            view.layer.cornerRadius = 0;
        }
        
        if (viewDictionary != nil) {
            UIColor *color = [self colorForAttributeKey:kAttributeBackgroundColorKey
                                         attributesDict:viewDictionary
                                              withModel:model
                                         componentState:ZeeComponentStateNormal];
            
            if ([color isNotEmpty]) {
                view.backgroundColor = color;
            }
        }
        UIColor *borderColor = [self colorForAttributeKey:kAttributeBorderColorKey
                                           attributesDict:viewDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([borderColor isNotEmpty]) {
            view.layer.borderColor = [borderColor CGColor];
        }
        
        attributeValue = [self attributeValueForAttribute:kAttributeBorderWidthKey
                                     attributesDictionary:viewDictionary
                              defaultAttributesDictionary:nil
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([attributeValue isKindOfClass:[NSNumber class]]) {
            CGFloat borderWidth = [attributeValue floatValue];
            view.layer.borderWidth = borderWidth;
        } else {
            view.layer.borderWidth = 0;
        }
        
        attributeValue = [self attributeValueForAttribute:kAttributeCornerRadiusKey
                                     attributesDictionary:viewDictionary
                              defaultAttributesDictionary:nil
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([attributeValue isKindOfClass:[NSNumber class]] ||
            [attributeValue isKindOfClass:[NSString class]]) {
            CGFloat cornerRadius = [attributeValue floatValue];
            view.layer.cornerRadius = cornerRadius;
        } else {
            view.layer.cornerRadius = 0;
        }
    }
}

- (void)customizationForButton:(UIButton *)button
                  attributeKey:(NSString *)attributeKey
   defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                     withModel:(NSObject *)model
                  withDelegate:(UIViewController <ComponentProtocol> *)delegate {
    
    if (button) {
        NSDictionary *attributesDictionary = [self valueForAttributeKey:attributeKey
                                                              withModel:model];
        if ([attributesDictionary[kAttributeLabelCustomizationHiddenKey] isKindOfClass:[NSNumber class]]) {
            BOOL hidden = [attributesDictionary[kAttributeLabelCustomizationHiddenKey] boolValue];
            button.hidden = hidden;
//            button.componentHidden = hidden;
            if (hidden) {
                // If the element is hidden then we don't need to customize the label.
                return;
            }
        }
//        if ([button isKindOfClass:[CAButton class]] && attributesDictionary) {
//            CAButton *componentButton = (CAButton *)button;
//            if ([delegate conformsToProtocol:@protocol(CAComponentProtocol)]) {
//                [componentButton setDelegate:delegate];
//                [componentButton setButtonTypeFromString:attributesDictionary[@"type"]];
//                NSDictionary *actionDataSource = attributesDictionary[@"action_data_source"];
//                if ([actionDataSource isKindOfClass:[NSDictionary class]]) {
//                    [componentButton setDataModelKey:actionDataSource[@"model_key"]];
//                    [componentButton setScheme:actionDataSource[@"scheme"]];
//                    [componentButton addTarget:componentButton action:@selector(handleButtonElementAction:)
//                              forControlEvents:UIControlEventTouchUpInside];
//                    if ([componentButton buttonHiddenForState]) {
//                        // If the element is hidden then we don't need to customize the label.
//                        return;
//                    }
//                }
//            }
//        }
        NSString *attributeValue = [self attributeValueForAttribute:kAttributeImageNameKey
                                               attributesDictionary:attributesDictionary
                                        defaultAttributesDictionary:defaultAttributesDictionary
                                                          withModel:model
                                                     componentState:ZeeComponentStateNormal];
        
        if ([attributeValue isKindOfClass:[NSString class]] &&
            [attributeValue isNotEmptyOrWhiteSpaces]) {
            UIImage *image = nil;
            if ([attributeValue hasSuffix:@"gif"]) {
                image = [UIImage animatedImageNamed:attributeValue];
            } else {
                image = [UIImage imageNamed:attributeValue];
            }
            
            [button setImage:image forState:UIControlStateNormal];
        }
        
        //kAttributeImageNameKey
        attributeValue = [self attributeValueForAttribute:kAttributeImageNameKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateHighlighted];
        
        if ([attributeValue isKindOfClass:[NSString class]] &&
            [attributeValue isNotEmptyOrWhiteSpaces]) {
            [button setImage:[UIImage imageNamed:attributeValue]
                    forState:UIControlStateHighlighted];
        }
        
        //kAttributeImageNameKey
        attributeValue = [self attributeValueForAttribute:kAttributeImageNameKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateSelected];
        
        if ([attributeValue isKindOfClass:[NSString class]] &&
            [attributeValue isNotEmptyOrWhiteSpaces]) {
            [button setImage:[UIImage imageNamed:attributeValue] forState:UIControlStateSelected];
        }
        
        //kAttributeBackgroundImageNameKey
        attributeValue = [self attributeValueForAttribute:kAttributeBackgroundImageNameKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([attributeValue isKindOfClass:[NSString class]] &&
            [attributeValue isNotEmptyOrWhiteSpaces]) {
            [button setBackgroundImage:[UIImage imageNamed:attributeValue] forState:UIControlStateNormal];
        }

        
        //kAttributeLabelTitleKey
        UILabel *label = button.titleLabel;
        [self customizationForLabel:label
                       attributeKey:kAttributeLabelTitleKey
                          withModel:model
                     componentState:ZeeComponentStateNormal];
        
        [button setAttributedTitle:label.attributedText forState:UIControlStateNormal];
        
        //kAttributeBorderColorKey
        UIColor *borderColor = [self colorForAttributeKey:kAttributeBorderColorKey
                                           attributesDict:attributesDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([borderColor isNotEmpty]) {
            button.layer.borderColor = [borderColor CGColor];
        }
        
        //kAttributeBorderWidthKey
        attributeValue = [self attributeValueForAttribute:kAttributeBorderWidthKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([attributeValue isKindOfClass:[NSNumber class]]) {
            CGFloat borderWidth = [attributeValue floatValue];
            button.layer.borderWidth = borderWidth;
        } else {
            button.layer.borderWidth = 0;
        }
        
        //kAttributeCornerRadiusKey
        attributeValue = [self attributeValueForAttribute:kAttributeCornerRadiusKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:ZeeComponentStateNormal];
        
        if ([attributeValue isKindOfClass:[NSNumber class]]) {
            CGFloat cornerRadius = [attributeValue floatValue];
            button.layer.cornerRadius = cornerRadius;
        } else {
            button.layer.cornerRadius = 0;
        }

    }
}

- (id)attributeValueForAttribute:(NSString *)attributeKey
                    attributesDictionary:(NSDictionary *)attributesDictionary
             defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                               withModel:(NSObject *)model
                          componentState:(ZeeComponentState)componentState {
    
    NSString *customizationKey = [attributeKey stateAttributeKeyForComponentState:componentState];
    NSString *retVal = defaultAttributesDictionary[customizationKey];
    
    if ([customizationKey isKindOfClass:[NSString class]] && attributesDictionary != nil) {
        retVal = [self valueOfCustomizationDictionary:attributesDictionary
                                             forModel:model
                                              withKey:customizationKey];
    }
    
    if (retVal == nil && componentState != ZeeComponentStateNormal) {
        retVal =  [self attributeValueForAttribute:attributeKey
                              attributesDictionary:attributesDictionary
                       defaultAttributesDictionary:defaultAttributesDictionary
                                         withModel:model
                                    componentState:ZeeComponentStateNormal];
    }
    return retVal;
}

//LabelCustomization
NSString *const kAttributeLabelCustomizationFontNameKey       = @"font_name";
NSString *const kAttributeLabelCustomizationFontNameBoldKey   = @"font_name_bold";
NSString *const kAttributeLabelCustomizationFontNameItalicKey = @"font_name_italic";
NSString *const kAttributeLabelCustomizationFontSizeKey       = @"font_size";
NSString *const kAttributeLabelCustomizationFontColorKey      = @"font_color";
NSString *const kAttributeLabelCustomizationTextKey           = @"text";
NSString *const kAttributeLabelCustomizationDataKey           = @"data_key";
NSString *const kAttributeLabelCustomizationDataArrayKey      = @"data_array_key";
NSString *const kAttributeLabelCustomizationDataArrayPositionKey   = @"data_array_key_position";
NSString *const kAttributeLabelCustomizationLocalizationKey   = @"localization_key";

// Label Letter Case
NSString *const kAttributeLabelCustomizationLetterCaseKey               = @"letter_case";
NSString *const kAttributeLabelCustomizationLetterCaseLowerCaseKey      = @"lowercase";
NSString *const kAttributeLabelCustomizationLetterCaseUpperCaseKey      = @"uppercase";
NSString *const kAttributeLabelCustomizationLetterCaseCapitalizeCaseKey = @"capitalize";

// Label Hidden
NSString *const kAttributeLabelCustomizationHiddenKey  = @"hidden";

// Label Number Of Lines
NSString *const kAttributeLabelCustomizationNumberOfLines  = @"number_of_lines";

// Label Minimum Scale Factor
NSString *const kAttributeLabelCustomizationMinimumScaleFactor  = @"minimum_scale_factor";

// Label Line BreakMode
NSString *const kAttributeLabelCustomizationLineBreakModeKey = @"line_break_mode";
NSString *const kAttributeLabelCustomizationLineBreakModeHeadKey = @"head";
NSString *const kAttributeLabelCustomizationLineBreakModeMiddleKey = @"middle";
NSString *const kAttributeLabelCustomizationLineBreakModeTailKey = @"tail";

// Label Align
NSString *const kAttributeLabelCustomizationTextAlignmentModeKey = @"text_alignment";
NSString *const kAttributeLabelCustomizationTextAlignmentModeLeftKey = @"left";
NSString *const kAttributeLabelCustomizationTextAlignmentModeCenterKey = @"center";
NSString *const kAttributeLabelCustomizationTextAlignmentModeRightKey = @"right";
NSString *const kAttributeLabelCustomizationTextAlignmentModeJustifiedKey = @"justified";
NSString *const kAttributeLabelCustomizationTextAlignmentModeNaturalKey = @"natural";

// Kerning
NSString *const kAttributeLabelCustomizationTextKerningKey = @"text_kerning";

// Line Height
NSString *const kAttributeLabelCustomizationTextLineSpacingKey = @"text_line_spacing";
static NSString *const kAttributeLabelCustomizationMinimumLineHeightKey = @"text_min_line_height";
static NSString *const kAttributeLabelCustomizationMaximumLineHeightKey = @"text_max_line_height";

// Label Shadow
NSString *const kAttributeLabelCustomizationTextShadowKey = @"text_shadow";
NSString *const kAttributeLabelCustomizationTextShadowOffsetKey = @"shadow_offset";
NSString *const kAttributeLabelCustomizationTextShadowOffsetWidthKey = @"width";
NSString *const kAttributeLabelCustomizationTextShadowOffsetHeightKey = @"height";
NSString *const kAttributeLabelCustomizationTextShadowBlurRadiusKey = @"shadow_blur_radius";
NSString *const kAttributeLabelCustomizationTextShadowColorKey = @"shadow_color";
NSString *const kAttributeLabelCustomizationHighlightTitleBackgroundColorKey = @"highlight_title_background_color";

// Label ignore defaults
NSString *const kAttributeLabelCustomizationIgnoreDefaultsKey = @"ignore_defaults";

- (id)valueFromDictionary:(NSDictionary *)dictionary
                    model:(NSObject *)model
                      key:(NSString *)key
           componentState:(ZeeComponentState)componentState {
    id retVal = nil;
    if (dictionary) {
        retVal = [self valueOfCustomizationDictionary:dictionary
                                             forModel:model
                                              withKey:[key stateAttributeKeyForComponentState:componentState]];
        if (componentState != ZeeComponentStateNormal && retVal == nil) {
            retVal = [self valueOfCustomizationDictionary:dictionary
                                                 forModel:model
                                                  withKey:[key stateAttributeKeyForComponentState:ZeeComponentStateNormal]];
        }
    }
    
    return retVal;
}

+ (void)customizationForLabel:(UILabel *)label
              labelDictionary:(NSDictionary *)labelDictionary
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState {
//    ComponentModel *dummyComponent = [[ComponentModel alloc] init];
//    [dummyComponent customizationForLabel:label
//                          labelDictionary:labelDictionary
//                                withModel:model
//                           componentState:componentState];
}

- (void)customizationForLabel:(UILabel *)label
              labelDictionary:(NSDictionary *)labelDictionary
             fontSizeMultiply:(CGFloat)fontSizeMultiply
          lineSpacingMultiply:(CGFloat)lineSpacingMultiply
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState {
    if (label) {
        
        if ([labelDictionary isNotEmpty]) {
            
            id hiddenValue = [self valueOfCustomizationDictionary:labelDictionary
                                                         forModel:model
                                                          withKey:kAttributeLabelCustomizationHiddenKey];
            BOOL shouldHide = YES;
            if([hiddenValue isKindOfClass:[NSNumber class]]) {
                BOOL hidden = [hiddenValue boolValue];
                shouldHide = hidden;
                label.hidden = hidden;
//                label.componentHidden = hidden;
                
                if (hidden) {
                    // If the text is hidden then we don't need to customize the label.
                    return;
                }
            }
            else if ([labelDictionary[kAttributeLabelCustomizationHiddenKey] isKindOfClass:[NSNumber class]]) {
                BOOL hidden = [labelDictionary[kAttributeLabelCustomizationHiddenKey] boolValue];
                shouldHide = hidden;
                label.hidden = hidden;
//                label.componentHidden = hidden;
                
                if (hidden) {
                    // If the text is hidden then we don't need to customize the label.
                    return;
                }
            }
            
            //Default Values
            BOOL ignoreDefaults = NO;
            if ([labelDictionary[kAttributeLabelCustomizationIgnoreDefaultsKey] isKindOfClass:[NSNumber class]]) {
                ignoreDefaults = [labelDictionary[kAttributeLabelCustomizationIgnoreDefaultsKey] boolValue];
            }
            
            if (!ignoreDefaults) {
//                CGFloat fontSize = [CAUIBuilderRealScreenSizeHelper resizeFontSizeWithComponentModel:self
//                                                                                               value:12];
//                [label setFont:[UIFont systemFontOfSize:fontSize]];
                [label setTextColor:[UIColor purpleColor]];
                [label setHidden:NO];
                [label setLineBreakMode:NSLineBreakByTruncatingTail];
            }
            
            if ([labelDictionary[kAttributeLabelCustomizationTextKey] isKindOfClass:[NSString class]] ||
                [labelDictionary[kAttributeLabelCustomizationLocalizationKey] isKindOfClass:[NSString class]]) {
                NSString *text = labelDictionary[kAttributeLabelCustomizationTextKey] ?: @"";

                if ([ZAAppConnector sharedInstance].localizationDelegate && [labelDictionary[kAttributeLabelCustomizationLocalizationKey]isKindOfClass:[NSString class]]) {
                    text = [[ZAAppConnector sharedInstance].localizationDelegate localizationStringByKey:labelDictionary[kAttributeLabelCustomizationLocalizationKey]
                                                  defaultString:text];
                }
                label.text = text;
            } else if ([labelDictionary[kAttributeLabelCustomizationDataKey] isKindOfClass:[NSString class]]) {
                NSString *dataKey = labelDictionary[kAttributeLabelCustomizationDataKey];
//                if ([model isKindOfClass:[CAAbstractModel class]]) {
//                    label.text = [(CAAbstractModel *)model objectForKey:dataKey expactedClass:[NSString class]];
//                } else
                    if ([model conformsToProtocol:@protocol(APAtomEntryProtocol)]) {
                    id modelData = [(id<APAtomEntryProtocol>)model extensions][dataKey];
                    if ([modelData isKindOfClass:[NSString class]]) {
                        label.text = (NSString *)modelData;
                    } else {
                        label.text = nil;
                    }
                }
            } else if ([labelDictionary[kAttributeLabelCustomizationDataArrayKey] isKindOfClass:[NSString class]]) {
                NSString *dataArrayKey = labelDictionary[kAttributeLabelCustomizationDataArrayKey];
                
                if ([model conformsToProtocol:@protocol(APAtomEntryProtocol)]) {
                    id modelData = [(id<APAtomEntryProtocol>)model extensions][dataArrayKey];
                    
                    if ([modelData isKindOfClass:[NSArray class]]) {
                        NSArray *arrayData = (NSArray*)modelData;
                        
                        if ([labelDictionary[kAttributeLabelCustomizationDataArrayPositionKey] isKindOfClass:[NSString class]]) {
                            NSInteger dataPosKey = [labelDictionary[kAttributeLabelCustomizationDataArrayPositionKey] integerValue];
                            
                            if (arrayData.count > dataPosKey) {
                                label.text = [arrayData objectAtIndex:dataPosKey];
                            } else {
                                label.text = nil;
                            }
                        }
                    }
                }
            }
            
            // if `hidden` key is set to `NO` do not hide if text is nil or zero length
            if (shouldHide) {
                if (label.text == nil || label.text.length == 0) {
                    label.hidden = YES;
//                    label.componentHidden = YES;
                } else {
                    label.hidden = NO;
//                    label.componentHidden = NO;
                }
            }
            
            NSString *stringCase = [self valueFromDictionary:labelDictionary
                                                       model:model
                                                         key:kAttributeLabelCustomizationLetterCaseKey
                                              componentState:componentState];
            
            if ([stringCase isKindOfClass:[NSString class]]) {
                if ([stringCase isEqualToString:kAttributeLabelCustomizationLetterCaseLowerCaseKey]) {
                    label.text = [label.text lowercaseString];
                } else if ([stringCase isEqualToString:kAttributeLabelCustomizationLetterCaseUpperCaseKey]) {
                    label.text = [label.text uppercaseString];
                } else if ([stringCase isEqualToString:kAttributeLabelCustomizationLetterCaseCapitalizeCaseKey]) {
                    label.text = [label.text capitalizedString];
                }
            }
            
            UIColor *color = [self colorForAttributeKey:kAttributeLabelCustomizationFontColorKey
                                         attributesDict:labelDictionary
                                              withModel:model
                                         componentState:componentState];
            if ([color isNotEmpty]) {
                label.textColor = color;
            }
            
            NSMutableAttributedString *attributedString = nil;
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            [style setLineBreakMode:label.lineBreakMode];
            [style setAlignment:label.textAlignment];
            [style setLineSpacing:lineSpacingMultiply * label.font.lineHeight];
            
            
            if (label.text.length > 0) {
                attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
            }
            
            UIFont *font = [self fontForAttributesDict:labelDictionary withModel:model fontSizeMultiply:fontSizeMultiply componentState:componentState];
            if (font != nil) {
                [label setFont:font];
                
                if (attributedString && font) {
                    [attributedString addAttribute:NSFontAttributeName
                                             value:font
                                             range:NSMakeRange(0, [label.text length])];
                }
            }
            
            NSNumber *numberOfLines = [self valueFromDictionary:labelDictionary
                                                          model:model
                                                            key:kAttributeLabelCustomizationNumberOfLines
                                                 componentState:componentState];
            
            if ([numberOfLines isKindOfClass:[NSNumber class]]) {
                [label setNumberOfLines:[numberOfLines integerValue]];
            }
            
            NSNumber *minimumScaleFactor = [self valueFromDictionary:labelDictionary
                                                               model:model
                                                                 key:kAttributeLabelCustomizationMinimumScaleFactor
                                                      componentState:componentState];
            
            if ([minimumScaleFactor isKindOfClass:[NSNumber class]]) {
                [label setMinimumScaleFactor:[minimumScaleFactor floatValue]];
            }
            
            NSString *breakMode = [self valueFromDictionary:labelDictionary
                                                      model:model
                                                        key:kAttributeLabelCustomizationLineBreakModeKey
                                             componentState:componentState];
            
            if ([breakMode isKindOfClass:[NSString class]]) {
                NSLineBreakMode lineBreakMode = NSLineBreakByTruncatingTail;
                if ([breakMode isEqualToString:kAttributeLabelCustomizationLineBreakModeHeadKey]) {
                    lineBreakMode = NSLineBreakByTruncatingHead;
                } else if ([breakMode isEqualToString:kAttributeLabelCustomizationLineBreakModeMiddleKey]) {
                    lineBreakMode = NSLineBreakByTruncatingMiddle;
                } else if ([breakMode isEqualToString:kAttributeLabelCustomizationLineBreakModeTailKey]) {
                    lineBreakMode = NSLineBreakByTruncatingTail;
                }
                [style setLineBreakMode:lineBreakMode];
                [label setLineBreakMode:lineBreakMode];
            }
            
            NSString *textAlignment = [self valueFromDictionary:labelDictionary
                                                          model:model
                                                            key:kAttributeLabelCustomizationTextAlignmentModeKey
                                                 componentState:componentState];
            
            if ([textAlignment isKindOfClass:[NSString class]]) {
                
                NSTextAlignment alignment = NSTextAlignmentLeft;
                if ([textAlignment isEqualToString:kAttributeLabelCustomizationTextAlignmentModeLeftKey]) {
                    alignment = NSTextAlignmentLeft;
                } else if ([textAlignment isEqualToString:kAttributeLabelCustomizationTextAlignmentModeCenterKey]) {
                    alignment = NSTextAlignmentCenter;
                } else if ([textAlignment isEqualToString:kAttributeLabelCustomizationTextAlignmentModeRightKey]) {
                    alignment = NSTextAlignmentRight;
                } else if ([textAlignment isEqualToString:kAttributeLabelCustomizationTextAlignmentModeJustifiedKey]) {
                    alignment = NSTextAlignmentJustified;
                } else if ([textAlignment isEqualToString:kAttributeLabelCustomizationTextAlignmentModeNaturalKey]) {
                    alignment = NSTextAlignmentNatural;
                }
                [label setTextAlignment:alignment];
                [style setAlignment:alignment];
            }
            
            BOOL needUseAttributeString = NO;
            
            if (attributedString) {
                
                NSString *lineSpacing = [self valueFromDictionary:labelDictionary
                                                            model:model
                                                              key:kAttributeLabelCustomizationTextLineSpacingKey
                                                   componentState:componentState];
                
                if ([lineSpacing isKindOfClass:[NSNumber class]]) {
                    style.lineSpacing = [lineSpacing floatValue];
                    needUseAttributeString = YES;
                }

                NSString *minimumLineHeightString = [self valueFromDictionary:labelDictionary
                                                                        model:model
                                                                          key:kAttributeLabelCustomizationMinimumLineHeightKey
                                                               componentState:componentState];
                if ([minimumLineHeightString isKindOfClass:[NSNumber class]]) {
                    style.minimumLineHeight = [minimumLineHeightString floatValue];
                    needUseAttributeString = YES;
                }

                NSString *maximumLineHeightString = [self valueFromDictionary:labelDictionary
                                                                        model:model
                                                                          key:kAttributeLabelCustomizationMaximumLineHeightKey
                                                               componentState:componentState];
                if ([maximumLineHeightString isKindOfClass:[NSNumber class]]) {
                    style.maximumLineHeight = [maximumLineHeightString floatValue];
                    needUseAttributeString = YES;
                }
                
                NSString *highlightedTextBackgroundColor = [self valueFromDictionary:labelDictionary
                                                                        model:model
                                                                          key:kAttributeLabelCustomizationHighlightTitleBackgroundColorKey
                                                               componentState:componentState];
                if ([highlightedTextBackgroundColor isKindOfClass:[NSString class]]) {
                    UIColor *backgroundColor = [UIColor colorWithRGBHexString:highlightedTextBackgroundColor];
                    [attributedString addAttribute:NSBackgroundColorAttributeName
                                      value:backgroundColor
                                      range:NSMakeRange(0, [attributedString length])];
                    needUseAttributeString = YES;
                }

                NSNumber *kerning = [self valueFromDictionary:labelDictionary
                                                        model:model
                                                          key:kAttributeLabelCustomizationTextKerningKey
                                               componentState:componentState];
                
                if ([kerning isKindOfClass:[NSNumber class]]) {
                    [attributedString addAttribute:NSKernAttributeName
                                             value:kerning
                                             range:NSMakeRange(0, [label.text length])];
                    needUseAttributeString = YES;
                }
                
                NSDictionary *shadowData = [self valueFromDictionary:labelDictionary
                                                               model:model
                                                                 key:kAttributeLabelCustomizationTextShadowKey
                                                      componentState:componentState];
                
                NSShadow *shadow = [[NSShadow alloc] init];
                
                if ([shadowData isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *shadowOffsetData = [self valueFromDictionary:shadowData
                                                                         model:model
                                                                           key:kAttributeLabelCustomizationTextShadowOffsetKey
                                                                componentState:componentState];
                    if ([shadowOffsetData isKindOfClass:[NSDictionary class]]) {
                        NSNumber *shadowOffsetWidth = [self valueFromDictionary:shadowOffsetData
                                                                          model:model
                                                                            key:kAttributeLabelCustomizationTextShadowOffsetWidthKey
                                                                 componentState:componentState];
                        NSNumber *shadowOffsetHeight = [self valueFromDictionary:shadowOffsetData
                                                                           model:model
                                                                             key:kAttributeLabelCustomizationTextShadowOffsetHeightKey
                                                                  componentState:componentState];
                        if ([shadowOffsetWidth isKindOfClass:[NSNumber class]] &&
                            [shadowOffsetHeight isKindOfClass:[NSNumber class]]) {
                            
                            shadow.shadowOffset = CGSizeMake([shadowOffsetData[kAttributeLabelCustomizationTextShadowOffsetWidthKey] floatValue],
                                                             [shadowOffsetData[kAttributeLabelCustomizationTextShadowOffsetHeightKey] floatValue]);
                            
                        }
                    }
                }
                
                NSNumber *shadowBlurRadius = [self valueFromDictionary:shadowData
                                                                 model:model
                                                                   key:kAttributeLabelCustomizationTextShadowBlurRadiusKey
                                                        componentState:componentState];
                
                if ([shadowBlurRadius isKindOfClass:[NSNumber class]]) {
                    shadow.shadowBlurRadius = [shadowBlurRadius floatValue] ;
                }
                
                NSString *shadowColor = [self valueFromDictionary:shadowData
                                                            model:model
                                                              key:kAttributeLabelCustomizationTextShadowColorKey
                                                   componentState:componentState];
                
                if ([shadowColor isKindOfClass:[NSString class]]) {
                    shadow.shadowColor = [UIColor colorWithRGBAHexString:shadowColor] ;
                }
                [attributedString addAttribute:NSShadowAttributeName
                                         value:shadow
                                         range:NSMakeRange(0, [label.text length])];
                needUseAttributeString = YES;
            }
            
            if (needUseAttributeString) {
                [attributedString addAttribute:NSParagraphStyleAttributeName
                                         value:style
                                         range:NSMakeRange(0, [label.text length])];
                label.attributedText = attributedString;
                
            }
            
            if ([labelDictionary[kAttributeBackgroundColorKey] isNotEmpty]) {
                label.backgroundColor = [self colorForAttributeKey:kAttributeBackgroundColorKey
                                                    attributesDict:labelDictionary
                                                         withModel:model
                                                    componentState:ZeeComponentStateNormal];
            }
        }
    }

}

- (void)customizationForLabel:(UILabel *)label
              labelDictionary:(NSDictionary *)labelDictionary
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState {
    [self customizationForLabel:label
                labelDictionary:labelDictionary
               fontSizeMultiply:1
            lineSpacingMultiply:0
                      withModel:model
                 componentState:componentState];
}

- (void)customizationForLabel:(UILabel *)label
                 attributeKey:(NSString *)attributeKey
                    withModel:(NSObject *)model
               componentState:(ZeeComponentState)componentState {
    [self customizationForLabel:label
                   attributeKey:attributeKey
                      withModel:model
               fontSizeMultiply:1.0f
            lineSpacingMultiply:0.f
                 componentState:componentState];
}

- (void)customizationForLabel:(UILabel *)label
                 attributeKey:(NSString *)attributeKey
                    withModel:(CellModel *)model
             fontSizeMultiply:(CGFloat)fontSizeMultiply
          lineSpacingMultiply:(CGFloat)lineSpacingMultiply
               componentState:(ZeeComponentState)componentState {
 
    NSString *type = model.containerType;
    NSString *cellKey = model.cellKey;
    NSDictionary *cellDict = [CustomizationManager dataForZappLayout:cellKey zappComponentType:type zappFamily:@"FAMILY_GANGES"];
    NSDictionary *labelDict = [cellDict objectForKey:attributeKey];
    [self customizationForLabel:label
                labelDictionary:labelDict
               fontSizeMultiply:fontSizeMultiply
            lineSpacingMultiply:lineSpacingMultiply
                      withModel:model
                 componentState:componentState];
}

- (NSDictionary *)componentStylesMappingDictionary {
    NSDictionary *retVal = nil;
    
    NSArray<ZPPluginModel *> *pluginModels = [ZPPluginManager pluginModels:@"cell_style_family"];
    for (ZPPluginModel *pluginModel in pluginModels) {
        NSBundle *bundle = [ZPPluginManager bundleForModelClass:pluginModel];
        if ([bundle pathForResource:@"ZeeHomeScreen_ZLComponentsMapping" ofType:@"plist"] != nil) {
            retVal = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"ZeeHomeScreen_ZLComponentsMapping" ofType:@"plist"]];
        }
    }
    
    return retVal;
}

- (void)customizationForTextView:(UITextView *)textView
                    attributeKey:(NSString *)key
                       withModel:(NSObject *)model
                fontSizeMultiply:(CGFloat)fontSizeMultiply {
    if (textView) {
        textView.hidden = NO;
        textView.textColor = [UIColor purpleColor];
        
        NSDictionary *textViewDictionary = [self valueForAttributeKey:key withModel:model];
        if ([textViewDictionary isNotEmpty]) {
            
            if ([textViewDictionary[kAttributeLabelCustomizationHiddenKey] isKindOfClass:[NSNumber class]]) {
                BOOL hidden = [textViewDictionary[kAttributeLabelCustomizationHiddenKey] boolValue];
                textView.hidden = hidden;
//                textView.componentHidden = hidden;
                
                if (hidden) {
                    // If the element is hidden then we don't need to customize the label.
                    return;
                }
            }
            
            NSString *fontName = [self valueFromDictionary:textViewDictionary
                                                     model:model
                                                       key:kAttributeLabelCustomizationFontNameKey
                                            componentState:ZeeComponentStateNormal];
            
            NSString *fontSize = [self valueFromDictionary:textViewDictionary
                                                     model:model
                                                       key:kAttributeLabelCustomizationFontSizeKey
                                            componentState:ZeeComponentStateNormal];
            
            if (fontName && fontSize) {
                CGFloat fontSizeFloat = [fontSize floatValue] * fontSizeMultiply;
                UIFont *newFont = [UIFont fontWithName:fontName
                                                  size:fontSizeFloat];
                [textView setFont:newFont];
            }
            
            UIColor *textColor = [self colorForAttributeKey:kAttributeLabelCustomizationFontColorKey
                                             attributesDict:textViewDictionary
                                                  withModel:model
                                             componentState:ZeeComponentStateNormal];
            if (textColor) {
                [textView setTextColor:textColor];
            }
            
            NSString *insetTop = [self valueFromDictionary:textViewDictionary
                                                     model:model
                                                       key:kAttributesInsetTopKey
                                            componentState:ZeeComponentStateNormal];
            
            NSString *insetLeft = [self valueFromDictionary:textViewDictionary
                                                      model:model
                                                        key:kAttributesInsetLeftKey
                                             componentState:ZeeComponentStateNormal];
            
            NSString *insetBottom = [self valueFromDictionary:textViewDictionary
                                                        model:model
                                                          key:kAttributesInsetBottomKey
                                               componentState:ZeeComponentStateNormal];
            
            NSString *insetRight = [self valueFromDictionary:textViewDictionary
                                                       model:model
                                                         key:kAttributesInsetRightKey
                                              componentState:ZeeComponentStateNormal];
            
            if (insetTop && insetLeft && insetRight && insetBottom) {
                UIEdgeInsets insets = UIEdgeInsetsMake([textViewDictionary[kAttributesInsetTopKey] floatValue],
                                                       [textViewDictionary[kAttributesInsetLeftKey] floatValue],
                                                       [textViewDictionary[kAttributesInsetBottomKey] floatValue],
                                                       [textViewDictionary[kAttributesInsetRightKey] floatValue]);
                textView.contentInset = insets;
            }
            
            if ([textViewDictionary[kAttributeLabelCustomizationTextKey] isKindOfClass:[NSString class]] ||
                [textViewDictionary[kAttributeLabelCustomizationLocalizationKey] isKindOfClass:[NSString class]]) {
                NSString *text = textViewDictionary[kAttributeLabelCustomizationTextKey] ?: @"";
                
                if ([ZAAppConnector sharedInstance].localizationDelegate && [textViewDictionary[kAttributeLabelCustomizationLocalizationKey]isKindOfClass:[NSString class]]) {
                    text = [[ZAAppConnector sharedInstance].localizationDelegate localizationStringByKey:textViewDictionary[kAttributeLabelCustomizationLocalizationKey]
                                                                                           defaultString:text];
                }
                textView.text = text;
            }
        }
    }
}
- (void)customizationForTextView:(UITextView *)textView
                    attributeKey:(NSString *)key
                       withModel:(NSObject *)model {
    [self customizationForTextView:textView
                      attributeKey:key
                         withModel:model
                  fontSizeMultiply:1.0];
}

- (void)customizationForImageView:(UIImageView *)imageView
                     attributeKey:(NSString *)attributeKey
             attributesDictionary:(NSDictionary *)attributesDictionary
      defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                        withModel:(NSObject *)model
                   componentState:(ZeeComponentState)componentState {
    if (imageView) {
        
        if ([attributesDictionary[kAttributeLabelCustomizationDataKey] isKindOfClass:[NSString class]]) {
            NSString *dataKey = attributesDictionary[kAttributeLabelCustomizationDataKey];
            if ([model conformsToProtocol:@protocol(APAtomEntryProtocol)]) {
                id modelData = [(id<APAtomEntryProtocol>)model extensions][dataKey];
                if ([modelData isKindOfClass:[NSNumber class]]) {
                    if ([modelData boolValue]) {
                        imageView.hidden = false;
                    } else {
                        imageView.hidden = true;
                    }
                }
            }
        }
        
        if ([attributesDictionary[kAttributeLabelCustomizationHiddenKey] isKindOfClass:[NSNumber class]]) {
            BOOL hidden = [attributesDictionary[kAttributeLabelCustomizationHiddenKey] boolValue];
            imageView.hidden = hidden;
//            imageView.componentHidden = hidden;
            
            if (hidden) {
                // If the element is hidden then we don't need to customize the label.
                return;
            }
        }
        
        NSString *attributeValue = [self attributeValueForAttribute:kAttributeImageNameKey
                                               attributesDictionary:attributesDictionary
                                        defaultAttributesDictionary:defaultAttributesDictionary
                                                          withModel:model
                                                     componentState:componentState];
        
        if ([attributeValue isKindOfClass:[NSString class]] &&
            [attributeValue isNotEmptyOrWhiteSpaces]) {
            [imageView setImage:[UIImage imageNamed:attributeValue]];
        }
        
        if (attributesDictionary != nil) {
            UIColor *color = [self colorForAttributeKey:kAttributeBackgroundColorKey
                                         attributesDict:attributesDictionary
                                              withModel:model
                                         componentState:componentState];
            
            if ([color isNotEmpty]) {
                imageView.backgroundColor = color;
            }
        }
        UIColor *borderColor = [self colorForAttributeKey:kAttributeBorderColorKey
                                           attributesDict:attributesDictionary
                                                withModel:model
                                           componentState:componentState];
        
        if ([borderColor isNotEmpty]) {
            imageView.layer.borderColor = [borderColor CGColor];
        }
        
        attributeValue = [self attributeValueForAttribute:kAttributeBorderWidthKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:componentState];
        
        if ([attributeValue isKindOfClass:[NSNumber class]]) {
            CGFloat borderWidth = [attributeValue floatValue];
            imageView.layer.borderWidth = borderWidth;
        } else {
            imageView.layer.borderWidth = 0;
        }
        
        attributeValue = [self attributeValueForAttribute:kAttributeCornerRadiusKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:componentState];
        
        if ([attributeValue isKindOfClass:[NSNumber class]] ||
            [attributeValue isKindOfClass:[NSString class]]) {
            CGFloat cornerRadius = [attributeValue floatValue];
            imageView.layer.cornerRadius = cornerRadius;
        } else {
            imageView.layer.cornerRadius = 0;
        }
        
        
        attributeValue = [self attributeValueForAttribute:kAttributeMaskImageNameKey
                                     attributesDictionary:attributesDictionary
                              defaultAttributesDictionary:defaultAttributesDictionary
                                                withModel:model
                                           componentState:componentState];
        if (attributeValue) {
            CALayer *mask = [CALayer layer];
            mask.contents = (id)[[UIImage imageNamed:attributeValue] CGImage];
            mask.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
            imageView.layer.mask = mask;
            imageView.layer.masksToBounds = YES;
        }
    }
}

- (void)customizationForImageView:(UIImageView *)imageView
                     attributeKey:(NSString *)attributeKey
      defaultAttributesDictionary:(NSDictionary *)defaultAttributesDictionary
                        withModel:(NSObject *)model
                   componentState:(ZeeComponentState)componentState {
    NSDictionary *attributesDictionary = [self valueForAttributeKey:attributeKey
                                                          withModel:model];
    return [self customizationForImageView:imageView
                              attributeKey:attributeKey
                      attributesDictionary:attributesDictionary
               defaultAttributesDictionary:defaultAttributesDictionary
                                 withModel:model
                            componentState:componentState];
}

#pragma mark - Color

- (UIColor *)colorForAttributeKey:(NSString *)attributeKey
                   attributesDict:(NSDictionary *)attributesDict
                        withModel:(NSObject *)model
                   componentState:(ZeeComponentState)componentState {
    NSString *customizationKey = [attributeKey stateAttributeKeyForComponentState:componentState];
 
    UIColor *retVal = nil;
    if ([customizationKey isKindOfClass:[NSString class]]) {

        id attribute = nil;
        if (!attributesDict) {
            attribute = [self valueForAttributeKey:customizationKey
                                         withModel:model];
        } else {
            attribute = [self valueOfCustomizationDictionary:attributesDict
                                                    forModel:model
                                                     withKey:customizationKey];
        }

        if ([attribute isKindOfClass:[NSDictionary class]]) {
            NSDictionary *attributeDictionary = (NSDictionary *)attribute;
            if ([attributeDictionary[kAttributeCMSColor] isKindOfClass:[NSNumber class]] && [attributeDictionary[kAttributeCMSColor] boolValue]) {
                UIColor *color = [self modelColorWithFallbackLogic:model];
                if (color) {
                    retVal = color;
                }
            }
            if (retVal == nil) {
                NSString *colorString = [self valueOfCustomizationDictionary:attributeDictionary
                                                                    forModel:model
                                                                     withKey:kAttributeValue];
                if ([colorString isKindOfClass:[NSString class]]) {
                    retVal = [UIColor colorWithRGBAHexString:colorString];
                }
            }
        }
        else if ([attribute isKindOfClass:[NSString class]]) {
            NSString *colorString = (NSString *)attribute;
            retVal = [UIColor colorWithRGBAHexString:colorString];
        }
    }
    if (!retVal && componentState != ZeeComponentStateNormal) {
        retVal = [self colorForAttributeKey:attributeKey
                             attributesDict:attributesDict
                                  withModel:model
                             componentState:ZeeComponentStateNormal];
    }
    return retVal;
}

- (UIFont *)fontForAttributesDict:(NSDictionary *)attributesDict
                        withModel:(NSObject *)model
                 fontSizeMultiply:(CGFloat)fontSizeMultiply
                   componentState:(ZeeComponentState)componentState {
    UIFont *result = nil;
    
    NSString *fontName = [self valueFromDictionary:attributesDict
                                             model:model
                                               key:kAttributeLabelCustomizationFontNameKey
                                    componentState:componentState];
    
    NSString *fontSize = [self valueFromDictionary:attributesDict
                                             model:model
                                               key:kAttributeLabelCustomizationFontSizeKey
                                    componentState:componentState];
    
    if ([fontSize isKindOfClass:[NSString class]]) {
        CGFloat fontSizeFloat = [fontSize floatValue] * fontSizeMultiply;
//        fontSizeFloat = [CAUIBuilderRealScreenSizeHelper resizeFontSizeWithComponentModel:self value:fontSizeFloat];
        
        UIFont *font = [UIFont systemFontOfSize:fontSizeFloat];
        
        if ([fontName isKindOfClass:[NSString class]]) {
            font = [UIFont fontWithName:fontName size:fontSizeFloat] ?: font;
            if (!font) {
                APLoggerError(@"%@ was not found!", fontName);
            }
        }

        result = font;
    }
    
    return result;
}

#pragma mark - Private

- (NSArray *)allValuesCustomizationDictionary:(NSDictionary *)dictionary
                                       forKey:(NSString *)key {
    return [self findAllValuesInDictionary:dictionary
                                    forKey:key];
}

- (NSArray *)findAllValuesInDictionary:(NSDictionary *)dictionary
                                forKey:(NSString *)key {
    NSMutableArray *retVal = [NSMutableArray new];
    NSArray *allKeys = [dictionary allKeys];
    
    for (NSString *currentKey in allKeys) {
        if ([currentKey isEqualToString:key]) {
//            NSString *result = [self valueOfCustomizationDictionary:dictionary
//                                                           forModel:self.dataSource.model
//                                                            withKey:key];
//            if (result) {
//                [retVal addObject:result];
//            }
        } else if ([dictionary[currentKey] isKindOfClass:[NSDictionary class]]) {
            [retVal addObjectsFromArray:[self findAllValuesInDictionary:dictionary[currentKey]
                                                                 forKey:key]];
        }
    }
    
    return [retVal copy];
}

- (NSDictionary *)customizationStyleForModel:(NSObject *)model {
    NSDictionary *retVal = nil;
//    NSDictionary *customizationDictionary = [CAAppDefineComponent sharedInstance].componentCustomizationDictionary;
//    NSString *customizationKey = [self valueOfCustomizationDictionary:self.style forModel:model withKey:@"cs_tag"];
//    if ([customizationKey isKindOfClass:[NSString class]]) {
//        if ([customizationDictionary[customizationKey] isNotEmpty]) {
//            retVal = customizationDictionary[customizationKey];
//        }
//
//        NSString *parentKey = [[customizationKey componentsSeparatedByString:@":"] lastObject];
//        if ([customizationDictionary[parentKey] isNotEmpty] && ![parentKey isEqualToString:customizationKey]) {
//            NSMutableDictionary *fullDict = [customizationDictionary[parentKey] mutableCopy];
//            [fullDict uniteWithDictionary:retVal];
//            retVal = [fullDict copy];
//        }
//    }
    
    return retVal;
}

- (UIColor *)modelColorWithFallbackLogic:(NSObject *)model {
    UIColor *retVal = nil;
    
    if ([model conformsToProtocol:@protocol(APUICustomizationProtocol)]) {
        NSString *colorString = nil;
        
        if ([model respondsToSelector:@selector(modelColor)]) {
            colorString = [(NSObject <APUICustomizationProtocol> *)model modelColor];
        }
        
        if (![colorString isKindOfClass:[NSString class]] && [colorString length] == 0) {
            if ([model conformsToProtocol:@protocol(APUICustomizationExtendedProtocol)]) {
                if ([model respondsToSelector:@selector(modelShowCategoryColor)]) {
                    colorString = [(NSObject <APUICustomizationExtendedProtocol> *)model modelShowCategoryColor];
                }
                
                if (![colorString isKindOfClass:[NSString class]] && [colorString length] == 0) {
                    colorString = [(NSObject <APUICustomizationExtendedProtocol> *)model modelTopLevelCategoryColor];
                }
            }
        }
        
        if ([colorString isKindOfClass:[NSString class]] && [colorString length] > 0) {
            retVal = [UIColor colorWithARGBHexString:colorString];
        }
    }

    return retVal;
}

@end
