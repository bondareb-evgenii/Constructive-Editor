//
//  InstructionPreviewViewController.m
//  ConstructiveEditor


#import "InstructionPreviewViewController.h"
#import "InstructionBuilder.h"
#import "PrintPaperManager.h"

@interface InstructionPreviewViewController ()
  {
  float _itemSpacing;
  InstructionBuilder* _instructionBuilder;
  }
@end

@interface InstructionPreviewViewController (DataSource) <UICollectionViewDataSource>

@end

@interface InstructionPreviewViewController (Delegate) <UICollectionViewDelegateFlowLayout>

@end

@implementation InstructionPreviewViewController

- (id)initWithCoder:(NSCoder *)aDecoder
  {
  self = [super initWithCoder:aDecoder];
  if (self)
    {
    _itemSpacing = 10;
    }
  return self;
  }

- (void)viewDidLoad
  {
  [super viewDidLoad];
	
  //delegate and data source are already set in a storyboard
  //self.collectionView.delegate = self;
  //self.collectionView.dataSource = self;
  }

- (void)viewWillAppear:(BOOL)animated
  {
  [self updateLayout];
  }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  CGSize viewSize = self.collectionView.bounds.size;
  CGPoint contentOffset = self.collectionView.contentOffset;
  NSIndexPath* centerItemIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(contentOffset.x + viewSize.width/2, contentOffset.y + viewSize.height/2)];
  if (!centerItemIndexPath)
    centerItemIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(contentOffset.x + viewSize.width/2 - _itemSpacing, contentOffset.y + viewSize.height/2 - _itemSpacing)];
  
  [self updateLayout];
  
  [self.collectionView reloadData];//Hack to make collection view actually scroll (commented code below doesn't make it to scroll in most cases...) is this a bug???
  [self.collectionView scrollToItemAtIndexPath:centerItemIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredHorizontally animated:NO];
  //[self.collectionView layoutIfNeeded];
  //[self performSelector:@selector(scrollToItemAtIndexPath:) withObject:centerItemIndexPath afterDelay:0];
  }

//- (void)scrollToItemAtIndexPath:(NSIndexPath*)indexPath
//  {
//  [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//  }

- (void)updateLayout
  {
  CGSize viewSize = self.collectionView.bounds.size;
  BOOL portrait = viewSize.width < viewSize.height;
  
  CGSize stepSize = [PrintPaperManager preferedPaper].printableRect.size;
  if (portrait)
    stepSize = CGSizeMake(viewSize.width, stepSize.height*(viewSize.width - _itemSpacing*2)/stepSize.width);
  else
    stepSize = CGSizeMake(stepSize.width*(viewSize.height - _itemSpacing*2)/stepSize.height, viewSize.height);
  
  UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  flowLayout.minimumInteritemSpacing = 0;
  flowLayout.minimumLineSpacing = _itemSpacing;
  flowLayout.itemSize = stepSize;
  flowLayout.scrollDirection = portrait ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
  }

- (void)setAssembly:(Assembly *)assembly
  {
  _assembly = assembly;
  _instructionBuilder = [[InstructionBuilder alloc] initWithAssembly:assembly];
  }

- (void)didReceiveMemoryWarning
  {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  }

@end

@implementation InstructionPreviewViewController (DataSource)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
  {
  return 1;
  }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
  {
  if (0 == section)
    return [_instructionBuilder stepsCount];
  return 0;
  }

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DetailCell" forIndexPath:indexPath];
  [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [_instructionBuilder prepareCell:cell forItemAtStep:indexPath.item];
  return cell;
  }

@end

/*@implementation InstructionPreviewViewController (Delegate)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  CGSize viewSize = self.collectionView.bounds.size;
  CGFloat stepSide = MIN(viewSize.width, viewSize.height);
  return CGSizeMake(stepSide, stepSide);
  }

@end*/
