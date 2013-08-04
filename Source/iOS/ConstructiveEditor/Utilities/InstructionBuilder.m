//
//  InstructionBuilder.m
//  ConstructiveEditor

#import "InstructionBuilder.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "DetailsListView.h"

@interface Page : NSObject

  + (id)page;

  @property (nonatomic, strong) AssemblyType* assemblyType;

@end

@implementation Page

+ (id)page
  {
  return [[self alloc] init];
  }

@end

@interface InstructionBuilder ()
  {
  Assembly* _assembly;
  NSMutableArray* _pages;
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
    _pages = [[NSMutableArray alloc] initWithCapacity:10];
    [self fillPagesForAssembly:assembly];
    }
  return self;
  }

+ (id)builderWithAssembly:(Assembly *)assembly
  {
  return [[self alloc] initWithAssembly:assembly];
  }

- (void)fillPagesForAssembly:(Assembly*)assembly
  {
  AssemblyType* assemblyType = assembly.type;
  BOOL isAssemblySplit = assemblyType.detailsInstalled.count && !assemblyType.assemblyBase;
  if (isAssemblySplit)
    {
    Page* pageForSplit = [Page page];
    pageForSplit.assemblyType = assemblyType;
    [_pages addObject:pageForSplit];
    return;
    }
  
  BOOL arePartsDetachedFromAssembly = nil != assemblyType.assemblyBase;
  if (arePartsDetachedFromAssembly)
    {
    [self fillPagesForAssembly:assemblyType.assemblyBase];
    Page* pageForBaseAssembly = [Page page];
    pageForBaseAssembly.assemblyType = assemblyType;
    [_pages addObject:pageForBaseAssembly];
    for (Assembly* subassembly in assemblyType.assembliesInstalled)
      {
      [self fillPagesForAssembly:subassembly];
      Page* pageForSmallerAssembly = [Page page];
      pageForSmallerAssembly.assemblyType = assemblyType;
      [_pages addObject:pageForSmallerAssembly];
      }
    return;
    }
    
  BOOL isAssemblyTransformed = nil != assemblyType.assemblyBeforeTransformation;
  if (isAssemblyTransformed)
    {
    [self fillPagesForAssembly:assemblyType.assemblyBeforeTransformation];
    Page* pageForTransformation = [Page page];
    pageForTransformation.assemblyType = assemblyType;
    [_pages addObject:pageForTransformation];
    return;
    }
    
  BOOL isAssemblyRotated = nil != assemblyType.assemblyBeforeRotation;
  if (isAssemblyRotated)
    {
    [self fillPagesForAssembly:assemblyType.assemblyBeforeRotation];
    Page* pageForRotation = [Page page];
    pageForRotation.assemblyType = assemblyType;
    [_pages addObject:pageForRotation];
    return;
    }
  }

- (NSUInteger)pagesCount
  {
  return _pages.count;
  }

- (void)prepareCell:(UICollectionViewCell*)cell forItemAtPage:(NSUInteger)page
  {
  CGSize cellSize = cell.bounds.size;
  NSSet* detailsToInstallOnPage = [self detailsToInstallOnPage:page];
  if (detailsToInstallOnPage.count)
    {
    DetailsListView* detailsListView = [[DetailsListView alloc] initWithFrame:CGRectMake(10, 10, cellSize.width/4, cellSize.height/4) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    detailsListView.details = detailsToInstallOnPage;
    detailsListView.backgroundColor = [UIColor blueColor];
    [cell.contentView addSubview:detailsListView];
    }
  }

- (NSSet*)detailsToInstallOnPage:(NSUInteger)page
  {
  return [self resultingAssemblyTypeForPage:page].detailsInstalled;
  }

- (AssemblyType*)resultingAssemblyTypeForPage:(NSUInteger)page
  {
  return [[_pages objectAtIndex:page] assemblyType];
  }

@end
