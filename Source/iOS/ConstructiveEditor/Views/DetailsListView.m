//
//  DetailsListView.m
//  ConstructiveEditor

#import "DetailsListView.h"
#import "DetailsListViewCell.h"
#import "Detail.h"
#import "DetailType.h"
#import "Picture.h"
#import "PointsToPixelsTransformer.h"

NSString* const DetailCellID = @"DetailCellID";

@interface DetailsListView ()
  {
  float _itemSpacing;
  }
@end

@interface DetailsListView (DataSource) <UICollectionViewDataSource>
@end

@interface DetailsListView (Delegate) <UICollectionViewDelegate>
@end

@implementation DetailsListView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
  {
  self = [super initWithFrame:frame collectionViewLayout:layout];
  if (self)
    {
    _itemSpacing = 3;
    self.dataSource = self;
    self.delegate = self;
    CGFloat detailImageSide = 20;
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(detailImageSide, detailImageSide);
    flowLayout.minimumInteritemSpacing = _itemSpacing;
    flowLayout.minimumLineSpacing = _itemSpacing;
    self.collectionViewLayout = flowLayout;
    
    [self registerClass:DetailsListViewCell.class forCellWithReuseIdentifier:DetailCellID];
    }
  return self;
  }

@end

@implementation DetailsListView (DataSource)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
  {
  return 1;
  }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
  {
  if (0 == section)
    return _details.count;
  return 0;
  }

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DetailCellID forIndexPath:indexPath];
  [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  UIImageView* detailTypeImageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
  detailTypeImageView.image = [((Detail*)[_details anyObject]).type pictureBestForSize:[PointsToPixelsTransformer sizeInPixelsOnMainScreenForSize:cell.contentView.bounds.size]];
  [cell.contentView addSubview:detailTypeImageView];
  return cell;
  }

@end
