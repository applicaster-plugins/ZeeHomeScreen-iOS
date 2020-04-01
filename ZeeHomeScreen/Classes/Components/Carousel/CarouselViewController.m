//
//  CarouselViewController.m
//  ZeeHomeScreen
//
//  Created by Miri on 28/01/2020.
//

#import "CarouselViewController.h"
#import "UniversalCollectionViewCell.h"
#import <ZeeHomeScreen/ZeeHomeScreen-Swift.h>
#import <ZeeHomeScreen/ComponenttFactory.h>
@import ApplicasterUIKit;
@import ApplicasterSDK;

NSString * const kCarouselSwipedNotification = @"CarouselSwipedNotification";

@interface CarouselViewController ()

@property (nonatomic, assign) BOOL isRTL;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, assign) BOOL componentInitialized;
@property (nonatomic, strong) ComponentModel *fallbackComponent;

@end

@implementation CarouselViewController

@synthesize delegate = _delegate;
@synthesize componentModel = _componentModel;
@synthesize componentDataSourceModel = _componentDataSourceModel;
@synthesize selectedModel = _selectedModel;

- (void)prepareComponentForReuse {
    [self removeObservers];
    
    _componentModel = nil;
    _componentDataSourceModel = nil;
    _dataSource = nil;
    _selectedModel = nil;
    self.fallbackComponent = nil;
}

#pragma mark - CAComponentProtocol

- (ComponentModel *)componentModel {
    if (self.fallbackComponent) {
        return self.fallbackComponent;
    }
    return (ComponentModel *)_componentModel;
}

- (void)setComponentModel:(ComponentModel *)model {
    _componentModel = model;
    
    [self removeObservers];
    [self addObservers];
    
    [self reloadComponent];
}

- (void)didStartDisplaying {
    for (UICollectionViewCell *visibleCell in [self.carouselView visibleCells]) {
        if ([visibleCell isKindOfClass:[UniversalCollectionViewCell class]]) {
            UniversalCollectionViewCell *universalCollectionViewCell = (UniversalCollectionViewCell *)visibleCell;
            if ([universalCollectionViewCell.componentViewController respondsToSelector:@selector(didStartDisplaying)]) {
                [universalCollectionViewCell.componentViewController didStartDisplaying];
            }
        }
    }
}

- (void)didEndDisplayingWithReason:(ZeeComponentEndDisplayingReason)reason {
    for (UICollectionViewCell *visibleCell in [self.carouselView visibleCells]) {
        if ([visibleCell isKindOfClass:[UniversalCollectionViewCell class]]) {
            UniversalCollectionViewCell *universalCollectionViewCell = (UniversalCollectionViewCell *)visibleCell;
            if ([universalCollectionViewCell.componentViewController respondsToSelector:@selector(didEndDisplayingWithReason:)]) {
               
                [universalCollectionViewCell.componentViewController didEndDisplayingWith:reason];
            }
        }
    }
}

- (void)addObservers{
    if ([self.currentComponentModel.uiTag length] > 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveActionNotification:)
                                                     name:self.currentComponentModel.uiTag
                                                   object:nil];
    }
}

- (void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:self.currentComponentModel.uiTag
                                                  object:nil];
}

- (void)reloadComponent {
    
    if (self.componentInitialized) {
        if (self.fallbackComponent) {
            self.fallbackComponent = nil;
            _selectedModel = nil;
            _componentDataSourceModel = nil;
            _dataSource = nil;
        }
        
        
        // TODO: LOAD CHILDEREN CAROASEL DATA
        
        if ([self.componentModel.dsUrl isNotEmptyOrWhiteSpaces]) {
            __weak typeof(self) weakSelf = self;
            
            [[DatasourceManager sharedInstance] loadWithAtomFeedUrl:self.componentModel.dsUrl parentModel:self.currentComponentModel completion:^(ComponentModel *componentModel) {
                
                if (componentModel != nil && [componentModel.childerns isNotEmpty]) {
                    weakSelf.dataSource = componentModel.childerns;
                    [weakSelf registerCarouselItems: componentModel.childerns];
                    [weakSelf updateDataArrayAndReload: componentModel.childerns];
                }
            }];
        }
    }
}

- (void)updateDataArrayAndReload:(NSArray *)dataArray {
    self.dataSource = dataArray;
    if (dataArray.count > 0) {
        
        //select model
        NSInteger selectedModelIndex = self.carouselView.initiallySelectedIndex;
        if (dataArray.count <= selectedModelIndex) {
            selectedModelIndex = 0;
        }
        self.selectedModel = [dataArray objectAtIndex: selectedModelIndex];
        if (self.carouselView.currentPageIndex != selectedModelIndex) {
            [self.carouselView selectItemAtIndex:selectedModelIndex];
        }
    }
}

- (void)setComponentDataSourceModel:(APModel *)componentDataSourceModel {
    if (componentDataSourceModel != _componentDataSourceModel) {
        _componentDataSourceModel = componentDataSourceModel;
    }
}

- (void)setDataSource:(id)dataSource {
    _dataSource = dataSource;
    //TO DO: GET THE DATA SOURCE LIMIT FROM PLUGIN CONFIGURATION
    NSInteger dataSourceLimit = 10;
    
    if (_dataSource.count > dataSourceLimit) {
        NSMutableArray *newDataSource = [[NSMutableArray alloc] initWithCapacity:dataSourceLimit];
        for (int index = 0; index < dataSourceLimit; index++) {
            [newDataSource addObject:dataSource[index]];
        }
        _dataSource = newDataSource;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.dataSource.count > 0) {
            self.borderView.hidden = NO;
        } else {
            self.borderView.hidden = YES;
        }
    });
    
    self.carouselView.isRTL = self.isRTL;
    self.carouselView.pageControl.numberOfPages = self.dataSource.count;
    [self registerCarouselItems: self.dataSource];
    [self.carouselView reloadData];
}

- (NSObject *)topParentForComponentModel:(ComponentModel *)componentModel withDataSourceModel:(NSObject *)model {
    NSObject *retVal = nil;
    if ([self.delegate respondsToSelector:@selector(topParentForComponentModel:withDataSourceModel:)]) {
        retVal = [self.delegate topParentForComponentModel:self.currentComponentModel
                                       withDataSourceModel:self.componentDataSourceModel];
    } else {
        retVal = self.componentDataSourceModel;
    }
    return retVal;
}

- (void)setupAppDefaultDefinitions {
    self.isRTL = [[ZAAppConnector sharedInstance].genericDelegate isRTL];
}

- (void)addRefreshTaskAfterDelay:(NSTimeInterval)delay{
    
}

- (ComponentModel *)currentComponentModel {
    return (ComponentModel *)self.componentModel;
}

#pragma mark - Public methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.borderView.hidden = YES;
    [self registerCarouselItems: self.dataSource];
    [self loadComponent];
    [self updateBorderColor];
    [self customizePromotionView];
}

- (void)dealloc{
    [self removeObservers];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self customizeBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.componentInitialized) {
        self.componentInitialized = YES;
        [self.view layoutIfNeeded];
        
        [self loadComponent];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)loadComponent {
    [self reloadComponent];
}


#pragma mark - Private Methods

- (ZeeComponentState)componentState {
    ZeeComponentState retVal = ZeeComponentStateNormal;
    if ([self.componentDataSourceModel isKindOfClass:[APModel class]] &&
        [(APModel *)self.componentDataSourceModel isEqualToModel:self.selectedModel]) {
        retVal = ZeeComponentStateSelected;
    }
    return retVal;
}

- (void)didReceiveActionNotification:(NSNotification *)notification {
    NSDictionary *notificationDict = (NSDictionary *) notification.object;
}

- (NSInteger)indexForModel:(APModel *)model{
    __block NSInteger index = NSNotFound;
    [self.dataSource enumerateObjectsUsingBlock:^(APModel *currentModel, NSUInteger idx, BOOL *stop) {
        if([currentModel isEqualToModel:model]){
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

#pragma mark - APPromotionViewDataSource

- (NSInteger)numberOfItemsInPromotionView:(APPromotionView *)promotionView {
    NSInteger retVal = [self.dataSource count];
    return retVal;
}

- (UICollectionViewCell *)promotionView:(APPromotionView *)promotionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CellModel *cellModel = self.dataSource[indexPath.row];
    
    NSString *reuseIdentifier = [cellModel.identifier stringByAppendingFormat:@"_%@", cellModel.layoutStyle];
    
    UniversalCollectionViewCell *cell = [promotionView dequeueReusableCellWithReuseIdentifier:cellModel.layoutStyle
                                                                                 forIndexPath:indexPath];
    
    if (cell.componentViewController == nil) {
        cell.componentViewController = [ComponenttFactory componentViewControllerWithComponentModel:cellModel
                                                                                           andModel:cellModel.entry
                                                                                            forView:cell.contentView
                                                                                           delegate:self.delegate
                                                                               parentViewController:self];
    }
    
    if ([cell.componentViewController respondsToSelector:@selector(delegate)]) {
        cell.componentViewController.delegate = self;
    }
    if ([cell.componentViewController respondsToSelector:@selector(setComponentModel:)]) {
        [cell.componentViewController setComponentModel:cellModel];
    }
    if ([cell.componentViewController respondsToSelector:@selector(setComponentDataSourceModel:)]) {
        [cell.componentViewController setComponentDataSourceModel:cellModel]; 
    }
   
    return cell;
}

#pragma mark - APPromotionViewDelegate

- (void)promotionView:(APPromotionView *)promotionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    APModel *currentModel = self.dataSource[indexPath.row];

     UniversalCollectionViewCell *cell = (UniversalCollectionViewCell *)[self promotionView:promotionView
                                                                                  cellForItemAtIndexPath:indexPath];
              
              if ([self.delegate respondsToSelector:@selector(componentViewController:didSelectModel:componentModel:atIndexPath:completion:)]) {
                  [self.delegate componentViewController:self
                                          didSelectModel:currentModel
                                          componentModel:cell.componentViewController.componentModel
                                             atIndexPath:indexPath
                                              completion:nil];
              }
              
       
}

- (void)promotionViewDidEndScrollingAnimation:(APPromotionView *)promotionView{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCarouselSwipedNotification object:self.selectedModel];
    
    [self notifyComponentModelSelection:promotionView];
}

- (void)promotionViewDidEndDecelerating:(APPromotionView *)promotionView{
//    NSInteger indexOfModel = promotionView.currentPageIndex;
//    if (indexOfModel != NSNotFound) {
//        [self selectCellWithModel:self.dataSource[indexOfModel] indexPath:[NSIndexPath indexPathForRow:indexOfModel inSection:0]];
//    }

    [self notifyComponentModelSelection:promotionView];
}

- (void)promotionView:(APPromotionView *)promotionView didEndDisplayingCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:UniversalCollectionViewCell.class]) {
        UniversalCollectionViewCell *universalCollectionViewCell = (UniversalCollectionViewCell *)cell;
        if ([universalCollectionViewCell.componentViewController respondsToSelector:@selector(didEndDisplayingWithReason:)]) {
            [universalCollectionViewCell.componentViewController didEndDisplayingWith:ZeeComponentEndDisplayingReasonCellQueued];
        }
    }
}

- (void) notifyComponentModelSelection:(APPromotionView *)promotionView {
    NSInteger currentPageIndex = [promotionView currentPageIndex];
    APModel *currentModel = currentPageIndex < self.dataSource.count ? [self.dataSource objectAtIndex:currentPageIndex] : nil;
    if(currentModel) {
        
    }
}

- (void) notifyDidStartDisplaying:(APModel *)currentModel promotionView:(APPromotionView *)promotionView forceCreatingCell:(BOOL)forceCreatingCell {
    UniversalCollectionViewCell *currentCell = nil;
    for (UniversalCollectionViewCell *cell in promotionView.visibleCells) {
        NSObject *componentDataSourceModel = cell.componentViewController.componentDataSourceModel;
        if ([componentDataSourceModel isKindOfClass:[APModel class]] &&
            [(APModel *)componentDataSourceModel isEqualToModel:currentModel]) {
            currentCell = cell;
            break;
        }
    }
    
    if (!currentCell && forceCreatingCell) {
        NSInteger indexOfModel = [self indexForModel:currentModel];
        NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:indexOfModel inSection:0];
        currentCell = (UniversalCollectionViewCell *)[self promotionView:promotionView cellForItemAtIndexPath:currentIndexPath];
    }
    
    if (currentCell && [currentCell isKindOfClass:UniversalCollectionViewCell.class]) {
        if ([currentCell.componentViewController respondsToSelector:@selector(didStartDisplaying)]) {
            [currentCell.componentViewController didStartDisplaying];
        }
    }
    
}

#pragma mark - Customizations

- (void)customizePromotionView {
    
}

- (void)updateBorderColor {
    
}

- (void)customizeBackground {
    
}

- (void)registerCarouselItems:(NSArray *)items {
    for (CellModel *localComponentModel in items) {
        NSString *layoutName = localComponentModel.layoutStyle;
        if ([layoutName isNotEmptyOrWhiteSpaces]) {
            
            [self.carouselView registerClass:[UniversalCollectionViewCell class] forCellWithReuseIdentifier:layoutName];
        }
    }
}

#pragma mark - ComponentDelegate

- (void)componentViewController:(UIViewController <ComponentProtocol>*)componentViewController
                 didSelectModel:(NSObject *)model
                 componentModel:(ComponentModel *)componentModel
                    atIndexPath:(NSIndexPath *)indexPath
                     completion:(void (^)(UIViewController *targetViewController))completion
{
    if ([self.delegate respondsToSelector:@selector(componentViewController:didSelectModel:componentModel:atIndexPath:completion:)]) {
        [self.delegate componentViewController:componentViewController
                                didSelectModel:model
                                componentModel:componentModel
                                   atIndexPath:indexPath
                                    completion:completion];
    }
}


/**
 Gets currently selected model
 */
- (APModel *)currenlySelectedModel {
    return self.selectedModel;
}

#pragma mark - Private

- (void)cancelRefreshTask{
    
}

/**
 Reloads the current component datasource and refresh the component's UI.
 */
- (void)refreshComponent:(NSNotification *)notification{
    [self cancelRefreshTask];
    
    [self reloadComponent];
}

- (void)selectCellWithModel:(APModel *)selectedModel
                  indexPath:(NSIndexPath *)indexPath{
    self.selectedModel = selectedModel;
    
    UniversalCollectionViewCell *cell = (UniversalCollectionViewCell *)[self promotionView:self.carouselView
                                                                    cellForItemAtIndexPath:indexPath];
    cell.componentViewController.selectedModel = self.selectedModel;
}

@end
