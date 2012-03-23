//
//  Assembly.h
//  Constructive
//
//  Created by Evgenii Bondarev on 3/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, Detail;

@interface Assembly : NSManagedObject

@property (nonatomic, retain) UIImage* picture;
@property (nonatomic, retain) NSValue* connectionPoint;
@property (nonatomic, retain) Assembly *parent;
@property (nonatomic, retain) NSSet *assemblies;
@property (nonatomic, retain) NSSet *details;
@property (nonatomic, retain) Assembly *mainChild;
@end

@interface Assembly (CoreDataGeneratedAccessors)

- (void)addAssembliesObject:(Assembly *)value;
- (void)removeAssembliesObject:(Assembly *)value;
- (void)addAssemblies:(NSSet *)values;
- (void)removeAssemblies:(NSSet *)values;

- (void)addDetailsObject:(Detail *)value;
- (void)removeDetailsObject:(Detail *)value;
- (void)addDetails:(NSSet *)values;
- (void)removeDetails:(NSSet *)values;

@end
