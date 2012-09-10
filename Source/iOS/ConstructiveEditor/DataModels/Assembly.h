//
//  Assembly.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssemblyType;

@interface Assembly : NSManagedObject

@property (nonatomic, retain) NSValue*      connectionPoint;
@property (nonatomic, retain) AssemblyType* type;
@property (nonatomic, retain) AssemblyType* assemblyExtended;
@property (nonatomic, retain) AssemblyType* assemblyToInstallTo;
@property (nonatomic, retain) AssemblyType* assemblyTransformed;
@property (nonatomic, retain) AssemblyType* assemblyRotated;
@end

