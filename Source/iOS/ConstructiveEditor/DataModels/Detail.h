//
//  Detail.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssemblyType, DetailType;

@interface Detail : NSManagedObject

@property (nonatomic, retain) NSValue*      connectionPoint;
@property (nonatomic, retain) AssemblyType* assemblyToInstallTo;
@property (nonatomic, retain) DetailType*   type;

@end
