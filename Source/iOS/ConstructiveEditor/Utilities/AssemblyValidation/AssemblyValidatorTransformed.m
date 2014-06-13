//
//  AssemblyValidatorTransformed.m
//  ConstructiveEditor

#import "AssemblyValidatorTransformed.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyValidator.h"
#import "AssemblyValidatorGeneral.h"
#import "AssemblyValidatorRotated.h"
#import "AssemblyValidatorSmallerPartsDetached.h"
#import "AssemblyValidatorSplitToDetails.h"
#import "InstructionStep.h"

@interface AssemblyValidatorTransformed ()
  {
  AssemblyType* _assemblyType;
  }
@end

@implementation AssemblyValidatorTransformed

- (id)initWithAssemblyType:(AssemblyType*)assemblyType
  {
  assert(assemblyType);
  assert(assemblyType.assemblyBeforeTransformation);
    
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

- (BOOL)canDisassembleWithError:(NSError**)error steps:(NSMutableArray*)steps andCurrentStep:(InstructionStep*)currentStep
  {
  BOOL isAssemblySplit = _assemblyType.detailsInstalled.count && !_assemblyType.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != _assemblyType.assemblyBase;
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  
  if (isAssemblyRotated || isAssemblySplit || arePartsDetachedFromAssembly)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
    return NO;
    }
  
  BOOL result = [[AssemblyValidatorGeneral validatorWitAssemblyType:_assemblyType.assemblyBeforeTransformation.type] canDisassembleWithError:error andSteps:steps];
  if (!result && (*error).code != kModelValidationErrorCodeAssemblyNotBrokenUp)
    return NO;

  currentStep.resultingAssemblyVolumeInCubicPins += [steps.lastObject resultingAssemblyVolumeInCubicPins];
  [steps addObject:currentStep];
  
  return result;
  }

@end
