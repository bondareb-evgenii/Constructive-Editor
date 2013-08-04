//
//  InstructionPreviewViewController.m
//  ConstructiveEditor


#import "InstructionPreviewViewController.h"
#import "InstructionBuilder.h"
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
  CGSize viewSize = self.collectionView.bounds.size;
  CGFloat pageSide = MIN(viewSize.width, viewSize.height);
  UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  flowLayout.itemSize = CGSizeMake(pageSide, pageSide);
  flowLayout.minimumInteritemSpacing = _itemSpacing;
  flowLayout.minimumLineSpacing = _itemSpacing;
  flowLayout.scrollDirection = viewSize.width < viewSize.height ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
  }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  CGSize viewSize = self.collectionView.bounds.size;
  CGPoint contentOffset = self.collectionView.contentOffset;
  NSIndexPath* centerItemIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(contentOffset.x + viewSize.width/2, contentOffset.y + viewSize.height/2)];
  if (!centerItemIndexPath)
    centerItemIndexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(contentOffset.x + viewSize.width/2 - _itemSpacing, contentOffset.y + viewSize.height/2 - _itemSpacing)];
  CGFloat pageSide = MIN(viewSize.width, viewSize.height);
  UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  flowLayout.itemSize = CGSizeMake(pageSide, pageSide);
  flowLayout.scrollDirection = viewSize.width < viewSize.height ? UICollectionViewScrollDirectionVertical : UICollectionViewScrollDirectionHorizontal;
  [self.collectionView reloadData];//Hack to make collection view actually scroll (commented code below doesn't make it to scroll in most cases...) is this a bug???
  [self.collectionView scrollToItemAtIndexPath:centerItemIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredHorizontally animated:NO];
  //[self.collectionView layoutIfNeeded];
  //[self performSelector:@selector(scrollToItemAtIndexPath:) withObject:centerItemIndexPath afterDelay:0];
  }

//- (void)scrollToItemAtIndexPath:(NSIndexPath*)indexPath
//  {
//  [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically|UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//  }

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
    return [_instructionBuilder pagesCount];
  return 0;
  }

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  UICollectionViewCell* cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DetailCell" forIndexPath:indexPath];
  [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [_instructionBuilder prepareCell:cell forItemAtPage:indexPath.item];
  return cell;
  }

@end

/*@implementation InstructionPreviewViewController (Delegate)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  CGSize viewSize = self.collectionView.bounds.size;
  CGFloat pageSide = MIN(viewSize.width, viewSize.height);
  return CGSizeMake(pageSide, pageSide);
  }

@end*/
