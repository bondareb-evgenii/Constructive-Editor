//
//  InstructionPreviewViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "InstructionPreviewViewController.h"

@interface InstructionPreviewViewController ()

@end

@interface InstructionPreviewViewController (DataSource) <UICollectionViewDataSource>

@end

@interface InstructionPreviewViewController (Delegate) <UICollectionViewDelegateFlowLayout>

@end

@implementation InstructionPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
  {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
    {
    // Custom initialization
    }
  return self;
  }

- (void)viewDidLoad
  {
  [super viewDidLoad];
	
  //delegate and data source are already set in a storyboard
  //self.collectionView.delegate = self;
  //self.collectionView.dataSource = self;
  
  UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
  flowLayout.itemSize = CGSizeMake(100, 100);
  flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
  flowLayout.minimumInteritemSpacing = 10;
  flowLayout.minimumLineSpacing = 10;
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
    return 10;
  return 0;
  }

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  return [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DetailCell" forIndexPath:indexPath];
  }

@end

@implementation InstructionPreviewViewController (Delegate)

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
  {
  return CGSizeMake(100, 100);
  }

@end
