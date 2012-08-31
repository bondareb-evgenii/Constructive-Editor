//
//  Assembly.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, Detail;

@interface Assembly : NSManagedObject

@property (nonatomic, retain) NSValue* connectionPoint;
@property (nonatomic, retain) UIImage* picture;
@property (nonatomic, retain) UIImage* picturePrepared;
@property (nonatomic, retain) NSSet *assembliesInstalled;
@property (nonatomic, retain) NSSet *detailsInstalled;
@property (nonatomic, retain) Assembly *assemblyBase;
@property (nonatomic, retain) Assembly *assemblyExtended;
@property (nonatomic, retain) Assembly *assemblyToInstallTo;
@property (nonatomic, retain) Assembly *assemblyTransformed;
@property (nonatomic, retain) Assembly *assemblyBeforeTransformation;
@property (nonatomic, retain) Assembly *assemblyRotated;
@property (nonatomic, retain) Assembly *assemblyBeforeRotation;
@end

@interface Assembly (CoreDataGeneratedAccessors)

- (UIImage*)pictureToShow;
- (void)addAssembliesInstalledObject:(Assembly *)value;
- (void)removeAssembliesInstalledObject:(Assembly *)value;
- (void)addAssembliesInstalled:(NSSet *)values;
- (void)removeAssembliesInstalled:(NSSet *)values;

- (void)addDetailsInstalledObject:(Detail *)value;
- (void)removeDetailsInstalledObject:(Detail *)value;
- (void)addDetailsInstalled:(NSSet *)values;
- (void)removeDetailsInstalled:(NSSet *)values;

@end
