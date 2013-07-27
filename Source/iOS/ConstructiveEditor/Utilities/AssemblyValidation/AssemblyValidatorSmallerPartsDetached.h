//
//  AssemblyValidatorSmallerPartsDetached.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@class AssemblyType;

@interface AssemblyValidatorSmallerPartsDetached : NSObject

  - (id)initWithAssemblyType:(AssemblyType*)assemblyType;
  + (id)validatorWitAssemblyType:(AssemblyType*)assemblyType;
  - (BOOL)isCompleteWithError:(NSError**)error;
    
@end
