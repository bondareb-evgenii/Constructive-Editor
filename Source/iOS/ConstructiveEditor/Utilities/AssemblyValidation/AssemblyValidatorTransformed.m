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

- (BOOL)isCompleteWithError:(NSError**)error
  {
  BOOL isAssemblySplit = _assemblyType.detailsInstalled.count && !_assemblyType.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != _assemblyType.assemblyBase;
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  
  if (isAssemblyRotated || isAssemblySplit || arePartsDetachedFromAssembly)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
    return NO;
    }
  
  return [[AssemblyValidatorGeneral validatorWitAssemblyType:_assemblyType.assemblyBeforeTransformation.type] isCompleteWithError:error];
  }

@end
