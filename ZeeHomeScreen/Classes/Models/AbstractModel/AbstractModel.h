//
//  AbstractModel.h
//  ZeeHomeScreen
//
//  Created by Miri on 11.12.19.
//

#import <Foundation/Foundation.h>

@interface AbstractModel : NSObject

//- (instancetype)initWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

#pragma mark - Properties
/**
 Model title, value for "title" key
 */
@property (weak, readonly, nonatomic) NSString *title;

/**
 Model description text, value for "description
 " key
 */
@property (weak, readonly, nonatomic) NSString *descriptionText;

@property (nonatomic, copy) void (^selectionBlock)(id Object);

@property (nonatomic, readonly) NSDictionary *object;

@property (weak, nonatomic) id originModel;

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary;

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

- (instancetype)initWithURL:(NSURL *)url;

- (void)loadWithCompletion:(void (^)(AbstractModel *abstractModel, NSError *error))completion;

- (BOOL)isEqualToModel:(AbstractModel *)otherModel;


- (NSString *)imageNamed:(NSString *)name;

- (id)objectForKey:(NSString *)key
     expactedClass:(Class)expactedClass;

@end
