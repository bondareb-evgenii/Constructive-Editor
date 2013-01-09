//
//  AssemblyValidator.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Assembly;

@interface AssemblyValidator : NSObject

+ (Assembly*)rootAssemblyInContext:(NSManagedObjectContext*)context;
+ (BOOL)isAssemblyComplete:(Assembly*)assemblyToCheck withError:(NSError*)error;

@end
