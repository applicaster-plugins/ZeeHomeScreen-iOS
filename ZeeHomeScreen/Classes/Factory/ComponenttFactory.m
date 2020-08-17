//
//  ComponenttFactory.m
//  ZeeHomeScreen
//
//  Created by Miri on 11.12.19.
//

@import ApplicasterSDK;

#import "ComponenttFactory.h"
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>

@protocol ComponentDelegate;

@interface ComponenttFactory (){
    
}

@end

@implementation ComponenttFactory

#pragma mark - Definitions

+ (NSString *)viewControllerClassNameforType:(NSString *)type {
    NSString *retVal;
    if ([type isEqualToString:@"HERO"]) {
        retVal = @"CarouselViewController";
    }
    else  if ([type isEqualToString:@"HORIZONTAL_LIST"]) {
        retVal = @"SectionCompositeViewController";
    }
    else  if ([type isEqualToString:@"LAZY_LOADING"]) {
        retVal = @"LazyLoadingViewController";
    }
    else if ([type isEqualToString:@"BANNER"]) {
        retVal = @"BannerCellViewController";
    }
    else {
        retVal = @"CellViewController";
    }
    return retVal;
}

+ (UIViewController <ComponentProtocol> *)viewControllerFromXibName:(NSString *)nibName
                                                       forType:(NSString *)type {
    
    NSString *className = [self viewControllerClassNameforType:type];
    UIViewController <ComponentProtocol> *viewController = nil;

    Class classFromName = NSClassFromString(className);
    if (!classFromName) {
        NSString *classNameWithModule = [NSString stringWithFormat:@"ZeeHomeScreen.%@", className];
        classFromName = NSClassFromString(classNameWithModule);
    }

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    //check if the bundle has the nib before initializing with it
    if ([bundle pathForResource:nibName ofType:@"nib"] != nil) {
        viewController = [[classFromName alloc] initWithNibName:nibName
                                                         bundle:bundle];
    }
    
    //Get xibs from cell style family plugins
    if (viewController == nil) {
        NSArray<ZPPluginModel *> *pluginModels = [ZPPluginManager pluginModels:@"cell_style_family"];
        for (ZPPluginModel *pluginModel in pluginModels) {
            NSBundle *bundle = [ZPPluginManager bundleForModelClass:pluginModel];
            if ([bundle pathForResource:nibName ofType:@"nib"] != nil) {
                viewController = [[classFromName alloc] initWithNibName:nibName bundle:bundle];
            }
            
            if (viewController) {
                break;
            }
        }
    }
    
    if (viewController == nil && classFromName != nil) {
        viewController = [[classFromName alloc] init];
    }

//
//    NSMutableArray *pluginModels = [ZPPluginManager pluginModels:@"cell_style_family"];
//    for (ZPPluginModel *item in pluginModels) {
//        NSBundle *bundle = [ZPPluginManager bundleForModelClass:item];
//        if ([bundle pathForResource:nibName ofType:"nib"] != nil) {
//            viewController = [[classFromName alloc] init];
//        }
//    }

    
    NSArray *providers = [[ZAAppConnector sharedInstance].pluginsDelegate.generalPluginsManager getPluginsForFamilyType: ZPGeneralPluginsFamilyUi];
    for (id<ZPGeneralPluginUIProtocol> provider in providers) {
        NSMutableDictionary *optionsDict = [NSMutableDictionary dictionaryWithDictionary:@{@"xibKeyName": nibName,
                                                                                           @"type": type,
                                                                                           @"bundle": bundle}] ;
        if (viewController != nil) {
            [optionsDict setObject:viewController forKey:@"viewController"];
        }
        viewController = (UIViewController <ComponentProtocol> *)[provider viewControllerWithOptions: optionsDict];
        if (viewController) {
            break;
        }
    }
    return viewController;
}

+ (UIViewController <ComponentProtocol> *)viewControllerForComponentModel:(ComponentModel *)componentModel {
    UIViewController <ComponentProtocol> *viewController = nil;
    NSString *xibKeyName = componentModel.layoutStyle;
    
    if ([xibKeyName isNotEmptyOrWhiteSpaces]) {

        viewController = [self viewControllerFromXibName:xibKeyName
                                                 forType:componentModel.type];
        
        if ([viewController conformsToProtocol:@protocol(ComponentProtocol)]) {
            if ([(UIViewController <ComponentProtocol> *) viewController respondsToSelector:@selector(setComponentModel:)]) {
                [(UIViewController <ComponentProtocol> *) viewController setComponentModel:componentModel];
            }
            if ([(UIViewController <ComponentProtocol> *) viewController respondsToSelector:@selector(setupAppDefaultDefinitions)]) {
                [(UIViewController <ComponentProtocol> *) viewController setupAppDefaultDefinitions];
            }

            if ([(UIViewController <ComponentProtocol> *) viewController respondsToSelector:@selector(setupCustomizationDictionary)]) {
                [(UIViewController <ComponentProtocol> *) viewController setupCustomizationDictionary];
            }
            if ([(UIViewController <ComponentProtocol> *) viewController respondsToSelector:@selector(setupComponentDefinitions)]) {
                [(UIViewController <ComponentProtocol> *) viewController setupComponentDefinitions];
            }
        }
    }

    if (viewController == nil) {
        APLoggerError(@"Can't create component - %@", componentModel);
    }

    return viewController;
}

@end
