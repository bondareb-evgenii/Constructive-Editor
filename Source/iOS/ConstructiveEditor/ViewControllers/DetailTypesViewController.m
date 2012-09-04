//
//  DetailTypesViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "DetailTypesViewController.h"

#import "Detail.h"
#import "DetailType.h"
#import "EditDetailTypeViewController.h"
#import "DetailTypeCellView.h"
#import "NSManagedObjectContextExtension.h"
#import "CoreData/CoreData.h"

@interface DetailTypesViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface DetailTypesViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@interface DetailTypesViewController ()
  {
  NSUInteger                        _addDetailTypeIndex;
  __weak IBOutlet UITableView*      _detailTypesTable;
  NSMutableArray*                   _detailTypes;
  }
@end

@implementation DetailTypesViewController

@synthesize detail = _detail;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  NSFetchRequest *detailTypesRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *detailTypeEntity = [NSEntityDescription entityForName:@"DetailType" inManagedObjectContext:self.detail.managedObjectContext];
	[detailTypesRequest setEntity:detailTypeEntity];
  //[detailTypesRequest setPredicate:[NSPredicate predicateWithFormat:@"(picture != nil)"]];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *detailTypesError = nil;
	NSArray* detailTypes = [[self.detail.managedObjectContext executeFetchRequest:detailTypesRequest error:&detailTypesError] mutableCopy];
  if (detailTypes == nil)
    {
		NSLog(@"Error: %@", detailTypesError.debugDescription);
    return;
    }

  _detailTypes = [detailTypes mutableCopy];
  
  _detailTypesTable.delegate = self;
  _detailTypesTable.dataSource = self;
  _detailTypesTable.editing = YES;//this is ConstructiveEditor :)
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
	[_detailTypesTable reloadData];
  
  DetailType* selectedDetailType = self.detail.type;
  if (nil != selectedDetailType)
    {
    NSUInteger detailTypeIndex = [_detailTypes indexOfObject:selectedDetailType];
    if (detailTypeIndex >= _addDetailTypeIndex)
      ++detailTypeIndex;
    [_detailTypesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:detailTypeIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditDetailTypeByAccessoryPressed"     isEqualToString:segue.identifier] ||
      [@"EditDetailTypeByPicturePressed"  isEqualToString:segue.identifier])
    {
    NSUInteger detailTypeIndex = [_detailTypesTable indexPathForCell:(UITableViewCell*)((UIView*)sender).superview.superview].row;
    if (_detailTypesTable.editing &&  detailTypeIndex > _addDetailTypeIndex)
      --detailTypeIndex;
    ((EditDetailTypeViewController*)segue.destinationViewController).detailType = [_detailTypes objectAtIndex:detailTypeIndex];
    }
  }
  
@end

@implementation DetailTypesViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _detailTypesTable)
    return 0;
  return 1;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _detailTypesTable)
    return 0;
  return _detailTypesTable.editing ? _detailTypes.count + 1 : _detailTypes.count;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _detailTypesTable)
    return 0;
  return NSLocalizedString(@"Detail types", @"Table view section header");
  }
  
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _detailTypesTable)
    return nil;
  
  if (_detailTypesTable.editing &&  indexPath.row == _addDetailTypeIndex)
    {
    UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
    addItemCell.textLabel.text = NSLocalizedString(@"Add detail type", @"Assemblies and details: cell label");
    return addItemCell;
    }
  else
    {
    NSUInteger detailTypeIndex = indexPath.row;
    if (_detailTypesTable.editing &&  detailTypeIndex > _addDetailTypeIndex)
      --detailTypeIndex;
    DetailType* detailType = [_detailTypes objectAtIndex:detailTypeIndex];
    DetailTypeCellView* cell = (DetailTypeCellView*)[tableView dequeueReusableCellWithIdentifier:@"DetailTypeCell"];
    cell.picture.image = [detailType pictureToShow]
                       ? [detailType pictureToShow]
                       : [UIImage imageNamed:@"camera.png"];
    return cell;
    }
  return nil;
  }
  
@end

@implementation DetailTypesViewController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _detailTypesTable)
    return;
    
  if (_detailTypesTable.editing &&  _addDetailTypeIndex == indexPath.row)
    return;
  
  NSUInteger detailTypeIndex = indexPath.row;
  if (_detailTypesTable.editing &&  detailTypeIndex > _addDetailTypeIndex)
    --detailTypeIndex;
  self.detail.type = [_detailTypes objectAtIndex:detailTypeIndex];
  [self.detail.managedObjectContext saveAndHandleError];
  }
  
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _detailTypesTable)
    return UITableViewCellEditingStyleNone;
    
  if (_detailTypesTable.editing &&  _addDetailTypeIndex == indexPath.row)
    return UITableViewCellEditingStyleInsert;
  return UITableViewCellEditingStyleDelete;
  }
  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _detailTypesTable)
    return;
  
  if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
    BOOL afterAddItem = indexPath.row > _addDetailTypeIndex;
      NSUInteger detailTypeIndex = afterAddItem ? indexPath.row-1 : indexPath.row;
      if (!afterAddItem)
        --_addDetailTypeIndex;
        
      [_detail.managedObjectContext deleteObject:[_detailTypes objectAtIndex:detailTypeIndex]];
      // Commit the change.
      [_detail.managedObjectContext saveAndHandleError];

      //update cache and UI
      [_detailTypes removeObjectAtIndex:detailTypeIndex];
      [_detailTypesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
  else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    DetailType* detailType = (DetailType*)[NSEntityDescription insertNewObjectForEntityForName:@"DetailType" inManagedObjectContext:self.detail.managedObjectContext];
    // Commit the change.
    [_detail.managedObjectContext saveAndHandleError];
    
    //update cache and UI
    [_detailTypes insertObject:detailType atIndex:_addDetailTypeIndex];
    [_detailTypesTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addDetailTypeIndex+1 inSection:indexPath.section], nil] withRowAnimation:UITableViewRowAnimationFade];
    }
  }
  
@end
