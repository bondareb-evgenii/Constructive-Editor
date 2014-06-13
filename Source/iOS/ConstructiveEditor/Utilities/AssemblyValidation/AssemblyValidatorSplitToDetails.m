//
//  AssemblyValidatorSplitToDetails.m
//  ConstructiveEditor

#import "AssemblyValidatorSplitToDetails.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyValidator.h"
#import "AssemblyValidatorRotated.h"
#import "AssemblyValidatorSmallerPartsDetached.h"
#import "AssemblyValidatorTransformed.h"
#import "Detail.h"
#import "DetailType.h"
#import "InstructionStep.h"

@interface AssemblyValidatorSplitToDetails ()
  {
  AssemblyType* _assemblyType;
  }
@end

@implementation AssemblyValidatorSplitToDetails

- (id)initWithAssemblyType:(AssemblyType*)assemblyType
  {
  assert(assemblyType);
  assert(assemblyType.detailsInstalled.count && !assemblyType.assemblyBase);
    
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
  BOOL arePartsDetachedFromAssembly = nil != _assemblyType.assemblyBase;
  BOOL isAssemblyTransformed = nil != _assemblyType.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  
  if (isAssemblyTransformed || isAssemblyRotated || arePartsDetachedFromAssembly)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
    return NO;
    }
  
  if (_assemblyType.detailsInstalled.count < 2)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeLessThenTwoDetailsInSplitAssembly userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"There are less then two details in a split assembly", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
    return NO;
    }
    
  BOOL allDetailsHaveConnectionPoint = YES;
  BOOL allDetailsHaveCompleteType = YES;
  Detail* problematicDetail = nil;
  for (Detail* detail in _assemblyType.detailsInstalled)
    {
    if (!detail.connectionPoint)
      {
      allDetailsHaveConnectionPoint = NO;
      problematicDetail = detail;
      break;
      }
    if (!detail.type)
      {
      allDetailsHaveCompleteType = NO;
      problematicDetail = detail;
      break;
      }
    currentStep.resultingAssemblyVolumeInCubicPins += detail.type.addedVolumeInCubicPins.floatValue;
    }
  if (!allDetailsHaveConnectionPoint)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Connection point is not specified at least for one detail some assembly is split to", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
    return NO;
    }
  else if (!allDetailsHaveCompleteType)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"At least one detail some assembly is split to has no type selected", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
    return NO;
    }
  
  [steps addObject:currentStep];
  
  return YES;
  }

@end
