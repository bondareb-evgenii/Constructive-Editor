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
  float                 _itemSpacing;
  NSSet*                _details;
  NSMutableArray*       _detailsGroups;
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

- (void)setDetails:(NSSet*)details
  {
  if (_details == details)
    return;
  _details = details;
  [self updateData];
  }

- (void)updateData
  {
  _detailsGroups = [[NSMutableArray alloc] initWithCapacity:_details.count];
  NSMutableDictionary* detailsGroupsDictionary = [[NSMutableDictionary alloc] initWithCapacity:_details.count];
  for (Detail* detail in _details)
    {
    NSValue* key = [NSValue valueWithNonretainedObject:detail.type];
    NSMutableArray* details = [detailsGroupsDictionary objectForKey:key];
    if (details.count)
      [details addObject:detail];
    else
      {
      details = [[NSMutableArray alloc] initWithCapacity:1];
      [details addObject:detail];
      [_detailsGroups addObject:key];
      [detailsGroupsDictionary setObject:details forKey:key];
      }
    }
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
    return _detailsGroups.count;
  return 0;
  }

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:DetailCellID forIndexPath:indexPath];
  [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
  UIImageView* detailTypeImageView = [[UIImageView alloc] initWithFrame:cell.contentView.bounds];
  detailTypeImageView.image = [((DetailType*)[[_detailsGroups objectAtIndex:indexPath.item] nonretainedObjectValue]) pictureBestForSize:[PointsToPixelsTransformer sizeInPixelsOnMainScreenForSize:cell.contentView.bounds.size]];
  [cell.contentView addSubview:detailTypeImageView];
  return cell;
  }

@end
