//
//  AssemblyValidatorSmallerPartsDetached.h
//  ConstructiveEditor

#import <Foundation/Foundation.h>

@class AssemblyType;
@class InstructionStep;

@interface AssemblyValidatorSmallerPartsDetached : NSObject

  - (id)initWithAssemblyType:(AssemblyType*)assemblyType;
  + (id)validatorWitAssemblyType:(AssemblyType*)assemblyType;
  - (BOOL)canDisassembleWithError:(NSError**)error steps:(NSMutableArray*)steps andCurrentStep:(InstructionStep*)currentStep;
    
@end
