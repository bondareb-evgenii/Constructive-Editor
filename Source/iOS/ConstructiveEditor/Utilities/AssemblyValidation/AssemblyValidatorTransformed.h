//
//  AssemblyValidatorTransformed.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@class AssemblyType;

@interface AssemblyValidatorTransformed : NSObject

  - (id)initWithAssemblyType:(AssemblyType*)assemblyType;
  + (id)validatorWitAssemblyType:(AssemblyType*)assemblyType;
  - (BOOL)isCompleteWithError:(NSError**)error;
    
@end
