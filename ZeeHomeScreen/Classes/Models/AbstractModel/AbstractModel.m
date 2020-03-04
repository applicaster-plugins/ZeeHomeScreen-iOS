//
//  AbstractModel.m
//  ZeeHomeScreen
//
//  Created by Miri on 11.12.19.
//

#import "AbstractModel.h"

#define ZEE_SYNTHESIZE_ATTRIBUTE(method_name, attribute_string_key, expacted_attribute_class_type) \
- (expacted_attribute_class_type *)method_name { \
    expacted_attribute_class_type *retVal = nil; \
    id newObject = [self.object objectForKey:attribute_string_key]; \
    if ([newObject isKindOfClass:[expacted_attribute_class_type class]]) { \
        retVal = newObject; \
    } \
    return retVal; \
}

@interface AbstractModel ()

@property (nonatomic, strong) NSURL *url;

@end

@implementation AbstractModel

#pragma mark - Private ZEE_SYNTHESIZE_ATTRIBUTE

ZEE_SYNTHESIZE_ATTRIBUTE(imagesDictionary, @"images_json", NSDictionary)
ZEE_SYNTHESIZE_ATTRIBUTE(title, @"title", NSString)
ZEE_SYNTHESIZE_ATTRIBUTE(descriptionText, @"description", NSString)

#pragma mark - Initialization

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [self init];
    if(self){
        _object = otherDictionary;
    }
    
    return self;
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    self = [self init];
    if(self){
        _object = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
    }
    
    return self;
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if(self){
        _object = nil;
        _url = url;
    }
    
    return self;
}

#pragma mark -

- (NSUInteger)count {
    return [self.object count];
}

- (id)objectForKey:(id)aKey {
    return [self.object objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    return [self.object keyEnumerator];
}

- (BOOL)isEqualToModel:(AbstractModel *)model {
    BOOL retVal = NO;
    if (model == self || ([model isKindOfClass:[self class]] && [model.object isEqualToDictionary:self.object])) {
            retVal = YES;
    }
    
    return retVal;
}

- (void)setObject:(NSDictionary *)object {
    if ([object isKindOfClass:[NSDictionary class]]) {
        _object = object;
    }
}

#pragma mark - Public

- (void)loadWithCompletion:(void (^)(AbstractModel *abstractModel, NSError *error))completion {
    if (self.url) {
        if ([self.url.absoluteString hasPrefix:@"file://"]) {
            
            NSString *fileName = [[NSMutableString stringWithString:self.url.absoluteString] substringFromIndex:7];
            NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
            NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
            _object = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingMutableContainers
                                                      error:nil];
            completion(self, nil);
        }
        else {
            NSURLSession *session = [NSURLSession sharedSession];
            NSURLSessionDataTask *sessionTask = [session dataTaskWithURL:self.url
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           completion(self, error);
                                                       }];
            [sessionTask resume];
        }
    }
}

- (id)objectForKey:(NSString *)key
     expactedClass:(Class)expactedClass {
    return [self objectFromDictionary:self.object
                               forKey:key
                        expactedClass:expactedClass];
    
}

- (NSString *)imageNamed:(NSString *)name {
    NSString *retVal = [self objectFromDictionary:[self imagesDictionary]
                                           forKey:name
                                    expactedClass:[NSString class]];
    return retVal;
}

#pragma mark - Private

- (id)objectFromDictionary:(NSDictionary *)dictionary
                    forKey:(NSString *)key
             expactedClass:(Class)expactedClass {
    id retVal = nil;
    if ([dictionary isKindOfClass:[NSDictionary class]] && [key isKindOfClass:[NSString class]]) {
        id newValue = dictionary[key];
        if ([newValue isKindOfClass:expactedClass]) {
            retVal = newValue;
        }
    }
    
    return retVal;
}


@end
