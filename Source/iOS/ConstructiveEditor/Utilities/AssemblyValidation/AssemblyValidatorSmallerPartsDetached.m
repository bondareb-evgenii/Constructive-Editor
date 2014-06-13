//
//  AssemblyValidatorSmallerPartsDetached.m
//  ConstructiveEditor

#import "AssemblyValidatorSmallerPartsDetached.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyValidator.h"
#import "AssemblyValidatorGeneral.h"
#import "AssemblyValidatorRotated.h"
#import "AssemblyValidatorSplitToDetails.h"
#import "AssemblyValidatorTransformed.h"
#import "Detail.h"
#import "DetailType.h"
#import "InstructionStep.h"

@interface AssemblyValidatorSmallerPartsDetached ()
  {
  AssemblyType* _assemblyType;
  }
@end

@implementation AssemblyValidatorSmallerPartsDetached

- (id)initWithAssemblyType:(AssemblyType*)assemblyType
  {
  assert(assemblyType);
  assert(assemblyType.assemblyBase);
    
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
  BOOL isAssemblyTransformed = nil != _assemblyType.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  
  if (isAssemblyTransformed || isAssemblySplit || isAssemblyRotated)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
    return NO;
    }
    
  if (!_assemblyType.detailsInstalled.count && !_assemblyType.assembliesInstalled.count)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeNoPartsDetachedFromAssembly userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"There are no parts detached from some assembly", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
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
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Connection point is not specified at least for one subdetail of some assembly", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
    return NO;
    }
  
  if (!allDetailsHaveCompleteType)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"At least one subdetail of some assembly has no type selected", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
    return NO;
    }
    
  BOOL allSubassembliesHaveConnectionPoint = YES;
  Assembly* problematicSubassembly = nil;
  for (Assembly* subassembly in _assemblyType.assembliesInstalled)
    if (!subassembly.connectionPoint)
      {
      allSubassembliesHaveConnectionPoint = NO;
      problematicSubassembly = subassembly;
      break;
      }
  if (!allSubassembliesHaveConnectionPoint)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeSubassemblyHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Connection point is not specified at least for one subassembly of some assembly", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", problematicSubassembly, @"problematicSubassembly", nil]];
    return NO;
    }
  
  //Assembly and it's details are OK, let's check subassemblies
  //Base assembly:
  BOOL canSplitBaseAssembly = [[AssemblyValidatorGeneral validatorWitAssemblyType:_assemblyType.assemblyBase.type] canDisassembleWithError:error andSteps:steps];
  
  if (!canSplitBaseAssembly && (*error).code != kModelValidationErrorCodeAssemblyNotBrokenUp)
    return NO;
    
  currentStep.resultingAssemblyVolumeInCubicPins += [steps.lastObject resultingAssemblyVolumeInCubicPins];
  [steps addObject:currentStep];
  
  //Smaller assemblies
  NSMutableArray* assembliesGroups = nil;
  NSMutableDictionary* assembliesGroupsDictionary = nil;
  [AssemblyValidator calculateInstalledAssembliesGroupsForAssemblyType:_assemblyType intoArray:&assembliesGroups andDictionary:&assembliesGroupsDictionary];
  
  for (NSValue* assemblyTypeVallue in assembliesGroups)
    {
    AssemblyType* assemblyType = assemblyTypeVallue.nonretainedObjectValue;
    //InstructionStep* substep = [[InstructionStep alloc] initWithAssemblyType:_assemblyType];
    BOOL canSplitSubassembly = [[AssemblyValidatorGeneral validatorWitAssemblyType:assemblyType] canDisassembleWithError:error andSteps:currentStep.substeps];
    if(!canSplitSubassembly && (*error).code != kModelValidationErrorCodeAssemblyNotBrokenUp)
      return NO;
    currentStep.resultingAssemblyVolumeInCubicPins += [currentStep.substeps.lastObject resultingAssemblyVolumeInCubicPins]*[[assembliesGroupsDictionary objectForKey:assemblyTypeVallue] count];
    }
  
  return nil == *error;
  }

@end
