//
//  AssemblyValidatorGeneral.m
//  ConstructiveEditor

#import "AssemblyValidatorGeneral.h"
#import "AssemblyType.h"
#import "AssemblyValidator.h"
#import "AssemblyValidatorRotated.h"
#import "AssemblyValidatorSmallerPartsDetached.h"
#import "AssemblyValidatorSplitToDetails.h"
#import "AssemblyValidatorTransformed.h"
#import "InstructionStep.h"

@interface AssemblyValidatorGeneral ()
  {
  AssemblyType* _assemblyType;
  }
@end

@implementation AssemblyValidatorGeneral

- (id)initWithAssemblyType:(AssemblyType*)assemblyType
  {
  assert(assemblyType);
    
  self = [super init];
  if (self)
    {
    _assemblyType = assemblyType;
    }
  return self;
  }

+ (id)validatorWitAssemblyType:(AssemblyType*)assemblyType
  {
  return [[self alloc] initWithAssemblyType:assemblyType];
  }

- (BOOL)canDisassembleWithError:(NSError**)error andSteps:(NSMutableArray*)steps
  {
  InstructionStep* step = [[InstructionStep alloc] initWithAssemblyType:_assemblyType];
  
  BOOL isAssemblySplit = _assemblyType.detailsInstalled.count && !_assemblyType.assemblyBase;
  if (isAssemblySplit)
    return [[AssemblyValidatorSplitToDetails validatorWitAssemblyType:_assemblyType] canDisassembleWithError:error steps:steps andCurrentStep:step];
  
  BOOL arePartsDetachedFromAssembly = nil != _assemblyType.assemblyBase;
  if (arePartsDetachedFromAssembly)
    return [[AssemblyValidatorSmallerPartsDetached validatorWitAssemblyType:_assemblyType] canDisassembleWithError:error steps:steps andCurrentStep:step];
    
  BOOL isAssemblyTransformed = nil != _assemblyType.assemblyBeforeTransformation;
  if (isAssemblyTransformed)
    return [[AssemblyValidatorTransformed validatorWitAssemblyType:_assemblyType] canDisassembleWithError:error steps:steps andCurrentStep:step];
    
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  if (isAssemblyRotated)
    return [[AssemblyValidatorRotated validatorWitAssemblyType:_assemblyType] canDisassembleWithError:error steps:steps andCurrentStep:step];
    
   //Special case: one (or more) of assemblies is not split at all while we should preserve steps hierarchy and add a dummy step which means that the instruction is build on base of some other instruction (out of scope)
  [steps addObject:step];
  *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeAssemblyNotBrokenUp userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Some assembly hasn't been broken up yet", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
  return NO;
  }

@end
