//
//  InstructionStep.m
//  ConstructiveEditor

#import "InstructionStep.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "DetailsListView.h"
#import "PreferencesKeys.h"

@interface InstructionStep ()
  {
  NSMutableArray* _substeps;
  }
@end

@implementation InstructionStep

- (id)initWithAssemblyType:(AssemblyType*)assemblyType
  {
  self = [super init];
  if (self)
    {
    _assemblyType = assemblyType;
    _substeps = [[NSMutableArray alloc] initWithCapacity:10];
    _resultingAssemblyVolumeInCubicPins = 0;
    }
  return self;
  }

+ (id)stepWithAssemblyType:(AssemblyType*)assemblyType
  {
  return [[self alloc] initWithAssemblyType:assemblyType];
  }

@end
