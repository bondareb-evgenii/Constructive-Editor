//
//  AssemblyValidatorRotated.m
//  ConstructiveEditor

#import "AssemblyValidatorRotated.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyValidator.h"
#import "AssemblyValidatorGeneral.h"
#import "AssemblyValidatorSmallerPartsDetached.h"
#import "AssemblyValidatorSplitToDetails.h"
#import "AssemblyValidatorTransformed.h"

@interface AssemblyValidatorRotated ()
  {
  AssemblyType* _assemblyType;
  }
@end

@implementation AssemblyValidatorRotated

- (id)initWithAssemblyType:(AssemblyType*)assemblyType
  {
  assert(assemblyType);
  assert(assemblyType.assemblyBeforeRotation);
    
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
  BOOL isAssemblyTransformed = nil != _assemblyType.assemblyBeforeTransformation;
  
  if (isAssemblyTransformed || isAssemblySplit || arePartsDetachedFromAssembly)
    {
    *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, _assemblyType, @"assemblyType", nil]];
    return NO;
    }
    
  return [[AssemblyValidatorGeneral validatorWitAssemblyType:_assemblyType.assemblyBeforeRotation.type] isCompleteWithError:error];
  }

@end