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

- (BOOL)isCompleteWithError:(NSError**)error
  {
  BOOL isAssemblySplit = _assemblyType.detailsInstalled.count && !_assemblyType.assemblyBase;
  if (isAssemblySplit)
    return [[AssemblyValidatorSplitToDetails validatorWitAssemblyType:_assemblyType] isCompleteWithError:error];
  
  BOOL arePartsDetachedFromAssembly = nil != _assemblyType.assemblyBase;
  if (arePartsDetachedFromAssembly)
    return [[AssemblyValidatorSmallerPartsDetached validatorWitAssemblyType:_assemblyType] isCompleteWithError:error];
    
  BOOL isAssemblyTransformed = nil != _assemblyType.assemblyBeforeTransformation;
  if (isAssemblyTransformed)
    return [[AssemblyValidatorTransformed validatorWitAssemblyType:_assemblyType] isCompleteWithError:error];
    
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  if (isAssemblyRotated)
    return [[AssemblyValidatorRotated validatorWitAssemblyType:_assemblyType] isCompleteWithError:error];
    
  *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeAssemblyNotBrokenUp userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Some assembly hasn't been broken up yet", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
  return NO;
  }

@end
