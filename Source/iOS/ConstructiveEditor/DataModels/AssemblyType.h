//
//  AssemblyType.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, Detail, AssemblyTypesShelf, Picture;

@interface AssemblyType : NSManagedObject

//coordinates of (0,0) and (1,1) points of the modified picture in the original picture's coordinate system
@property (nonatomic, retain) NSNumber*           preparedPicturePoint0_0X;
@property (nonatomic, retain) NSNumber*           preparedPicturePoint0_0Y;
@property (nonatomic, retain) NSNumber*           preparedPicturePoint1_1X;
@property (nonatomic, retain) NSNumber*           preparedPicturePoint1_1Y;

//relations
@property (nonatomic, retain) Picture*            picture;
@property (nonatomic, retain) Picture*            pictureThumbnail60x60AspectFit;
@property (nonatomic, retain) Picture*            picturePrepared;
@property (nonatomic, retain) Picture*            picturePreparedThumbnail60x60AspectFit;
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
- (UIImage*)pictureToShowThumbnail60x60AspectFit;

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
