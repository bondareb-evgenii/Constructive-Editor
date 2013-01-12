//
//  AssemblyValidator.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
  {
  kModelValidationErrorCodeOK = 0,
  kModelValidationErrorCodeAssemblyNotBrokenUp,//model can still be exported
  kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously,
  kModelValidationErrorCodeLessThenTwoDetailsInSplitAssembly,
  kModelValidationErrorCodeNoPartsDetachedFromAssembly,
  kModelValidationErrorCodeDetailHasNoConnectionPoint,
  kModelValidationErrorCodeSubassemblyHasNoConnectionPoint,
  } ModelValidationErrorCode;

@class Assembly;

@interface AssemblyValidator : NSObject

+ (Assembly*)rootAssemblyInContext:(NSManagedObjectContext*)context;
+ (BOOL)isAssemblyComplete:(Assembly*)assemblyToCheck withError:(NSError**)error;
+ (void)showExportMenuForRootAssembly:(Assembly*)rootAssembly currentAssembly:(Assembly*)currentAssembly inView:(UIView*)view;
+ (BOOL)exportToPDFAssembly:(Assembly*)assembly withError:(NSError**)error;

@end
