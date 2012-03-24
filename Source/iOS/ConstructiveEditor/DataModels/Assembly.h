//
//  Assembly.h
//  Constructive
//
//  Created by Evgenii Bondarev on 3/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Assembly, Detail;

@interface Assembly : NSManagedObject

@property (nonatomic, retain) NSValue* connectionPoint;
@property (nonatomic, retain) UIImage* picture;
@property (nonatomic, retain) NSSet *assembliesInstalled;
@property (nonatomic, retain) NSSet *detailsInstalled;
@property (nonatomic, retain) Assembly *baseAssembly;
@property (nonatomic, retain) Assembly *extendedAssembly;
@property (nonatomic, retain) Assembly *assemblyToInstallTo;
@end

@interface Assembly (CoreDataGeneratedAccessors)

- (void)addAssembliesInstalledObject:(Assembly *)value;
- (void)removeAssembliesInstalledObject:(Assembly *)value;
- (void)addAssembliesInstalled:(NSSet *)values;
- (void)removeAssembliesInstalled:(NSSet *)values;

- (void)addDetailsInstalledObject:(Detail *)value;
- (void)removeDetailsInstalledObject:(Detail *)value;
- (void)addDetailsInstalled:(NSSet *)values;
- (void)removeDetailsInstalled:(NSSet *)values;

@end
