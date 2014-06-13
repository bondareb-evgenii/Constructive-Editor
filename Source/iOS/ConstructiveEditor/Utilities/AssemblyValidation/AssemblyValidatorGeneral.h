//
//  AssemblyValidatorGeneral.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@class AssemblyType;
@class InstructionStep;

@interface AssemblyValidatorGeneral : NSObject

  - (id)initWithAssemblyType:(AssemblyType*)assemblyType;
  + (id)validatorWitAssemblyType:(AssemblyType*)assemblyType;
  - (BOOL)canDisassembleWithError:(NSError**)error andSteps:(NSMutableArray*)steps;
    
@end
