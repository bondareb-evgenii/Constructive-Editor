//
//  AssemblyType.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, Detail, AssemblyTypesShelf;

@interface AssemblyType : NSManagedObject

@property (nonatomic, retain) UIImage*            picture;
@property (nonatomic, retain) UIImage*            picturePrepared;
@property (nonatomic, retain) NSSet*              assemblies;
@property (nonatomic, retain) NSSet*              assembliesInstalled;
@property (nonatomic, retain) NSSet*              detailsInstalled;
@property (nonatomic, retain) Assembly*           assemblyBase;
@property (nonatomic, retain) Assembly*           assemblyBeforeTransformation;
@property (nonatomic, retain) Assembly*           assemblyBeforeRotation;
@property (nonatomic, retain) AssemblyTypesShelf* shelf;
@end

@interface AssemblyType (CoreDataGeneratedAccessors)

- (UIImage*)pictureToShow;

- (void)addAssembliesObject:(Assembly *)value;
- (void)removeAssembliesObject:(Assembly *)value;
- (void)addAssemblies:(NSSet *)values;
- (void)removeAssemblies:(NSSet *)values;

- (void)addAssembliesInstalledObject:(Assembly *)value;
- (void)removeAssembliesInstalledObject:(Assembly *)value;
- (void)addAssembliesInstalled:(NSSet *)values;
- (void)removeAssembliesInstalled:(NSSet *)values;

- (void)addDetailsInstalledObject:(Detail *)value;
- (void)removeDetailsInstalledObject:(Detail *)value;
- (void)addDetailsInstalled:(NSSet *)values;
- (void)removeDetailsInstalled:(NSSet *)values;

@end
