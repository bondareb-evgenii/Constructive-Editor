//
//  InstructionBuilder.m
//  ConstructiveEditor

#import "InstructionBuilder.h"
#import "InstructionStep.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "InstructionLayoutManager.h"
#import "DetailsListView.h"
#import "PreferencesKeys.h"

@interface InstructionBuilder ()
  {
  Assembly* _assembly;
  NSMutableArray* _steps;
  InstructionLayoutManager* _layoutManager;
  }
@end

@implementation InstructionBuilder

- (id)initWithAssembly:(Assembly *)assembly
  {
  assert(assembly);
  self = [super init];
  if (self)
    {
    _assembly = assembly;
    _steps = [[NSMutableArray alloc] initWithCapacity:10];
    _layoutManager = [InstructionLayoutManager new];
    //[self fillStepsForAssembly:assembly];
    }
  return self;
  }

+ (id)builderWithAssembly:(Assembly *)assembly
  {
  return [[self alloc] initWithAssembly:assembly];
  }

- (NSUInteger)stepsCount
  {
  return _steps.count;//this is actually a major steps count only (each of them may contain several substeps and so on (any level deep))
  }

- (void)prepareCell:(UICollectionViewCell*)cell forItemAtStep:(NSUInteger)step
  {
  NSSet* detailsToInstallOnStep = [self detailsToInstallOnStep:step];
  if (detailsToInstallOnStep.count)
    {
    DetailsListView* detailsListView = [[DetailsListView alloc] initWithFrame:CGRectMake(_layoutManager.detailsListRect.origin.x, _layoutManager.detailsListRect.origin.y, _layoutManager.detailsListRect.size.width, _layoutManager.detailsListRect.size.height) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    detailsListView.details = detailsToInstallOnStep;
    detailsListView.backgroundColor = [UIColor blueColor];
    [cell.contentView addSubview:detailsListView];
    }
  }

- (NSSet*)detailsToInstallOnStep:(NSUInteger)step
  {
  return [self resultingAssemblyTypeForStep:step].detailsInstalled;
  }

- (AssemblyType*)resultingAssemblyTypeForStep:(NSUInteger)step
  {
  return [[_steps objectAtIndex:step] assemblyType];
  }

@end
