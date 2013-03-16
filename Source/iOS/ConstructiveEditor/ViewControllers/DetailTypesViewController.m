//
//  DetailTypesViewController.m
//  ConstructiveEditor


#import "DetailTypesViewController.h"

#import "Detail.h"
#import "DetailType.h"
#import "AssemblyType.h"
#import "EditDetailViewController.h"
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
  __weak IBOutlet UIBarButtonItem*  _connectionPointButton;
  }
@end

@implementation DetailTypesViewController

@synthesize details = _details;

- (Detail*)detail
  {
  return [_details lastObject];
  }
  
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
  
  //detail type should have a picture to be selected
  DetailType* selectedDetailType = self.detail.type;
  if (selectedDetailType && !selectedDetailType.pictureToShowThumbnail60x60AspectFit)
    {
    self.detail.type = nil;
    [_detailTypes removeObject:selectedDetailType];
    [self.detail.managedObjectContext deleteObject:selectedDetailType];
    }
    
	[_detailTypesTable reloadData];
    
  //select current detail type in the table view
  selectedDetailType = self.detail.type;
  if (selectedDetailType)
    {
    NSUInteger detailTypeIndex = [_detailTypes indexOfObject:selectedDetailType];
    if (detailTypeIndex >= _addDetailTypeIndex)
      ++detailTypeIndex;
    [_detailTypesTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:detailTypeIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }

  _connectionPointButton.enabled = nil!=self.detail.type;
  }

- (IBAction)onSetConnectionPoint:(id)sender
  {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count >= 2 && [[viewControllers objectAtIndex:viewControllers.count-2] isKindOfClass:[EditDetailViewController class]])
    [self.navigationController popViewControllerAnimated:YES];
  else
    [self performSegueWithIdentifier:@"SelectDetailConnectionPointAfterTypeSelected" sender:nil];
  }

- (DetailType*)detailTypeForIndexPath:(NSIndexPath*)indexPath
  {
  NSUInteger detailTypeIndex = indexPath.row;
  if (_detailTypesTable.editing &&  detailTypeIndex == _addDetailTypeIndex)
    return nil;//add type cell
    
  if (_detailTypesTable.editing &&  detailTypeIndex > _addDetailTypeIndex)
    --detailTypeIndex;
  return [_detailTypes objectAtIndex:detailTypeIndex];
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditDetailType" isEqualToString:segue.identifier])
    {
    NSUInteger detailTypeIndex = [_detailTypesTable indexPathForCell:(UITableViewCell*)sender].row;
    if (_detailTypesTable.editing &&  detailTypeIndex > _addDetailTypeIndex)
      --detailTypeIndex;
    DetailType* detailType = [_detailTypes objectAtIndex:detailTypeIndex];
    self.detail.type = detailType;
    ((EditDetailTypeViewController*)segue.destinationViewController).detailType = detailType;
    }
  else if ([@"EditNewDetailType" isEqualToString:segue.identifier])
    {
    DetailType* detailType = (DetailType*)[NSEntityDescription insertNewObjectForEntityForName:@"DetailType" inManagedObjectContext:self.detail.managedObjectContext];
    self.detail.type = detailType;
    ((EditDetailTypeViewController*)segue.destinationViewController).detailType = detailType;
    // Commit the change.
    [self.detail.managedObjectContext saveAsyncAndHandleError];
    
    //update cache
    [_detailTypes insertObject:detailType atIndex:_addDetailTypeIndex];
    //No need to update UI as we are going to another screen immediately
//    [_detailTypesTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addDetailTypeIndex+1 inSection:indexPath.section], nil] withRowAnimation:UITableViewRowAnimationFade];
    }
  else if ([@"SelectDetailConnectionPointAfterTypeSelected" isEqualToString:segue.identifier])
    {
    AssemblyType* assemblyToInstallTo = [[_details lastObject] assemblyToInstallTo];
    NSArray* detailsInstalled = [assemblyToInstallTo.detailsInstalled allObjects];
    NSMutableArray* detailsOfSelectedType = [[NSMutableArray alloc] initWithCapacity:self.details.count];
    for (Detail* detail in detailsInstalled)
      if (detail.type == [self detailTypeForIndexPath:[_detailTypesTable indexPathForSelectedRow]])
        [detailsOfSelectedType addObject:detail];
    ((EditDetailViewController*)segue.destinationViewController).details = detailsOfSelectedType;
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
    cell.picture.image = [detailType pictureToShowThumbnail60x60AspectFit]
                       ? [detailType pictureToShowThumbnail60x60AspectFit]
                       : [UIImage imageNamed:@"camera.png"];
    NSString* formatString = NSLocalizedString(@"Used %d times", @"Usage count label text");
    cell.usageCountLabel.text = [NSString stringWithFormat:formatString, detailType.details.count];
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
  
  DetailType* type = [self detailTypeForIndexPath:indexPath];
  for (Detail* detail in self.details)
    detail.type = type;
  [self.detail.managedObjectContext saveAsyncAndHandleError];
  _connectionPointButton.enabled = YES;
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
        
      [self.detail.managedObjectContext deleteObject:[_detailTypes objectAtIndex:detailTypeIndex]];
      // Commit the change.
      [self.detail.managedObjectContext saveAsyncAndHandleError];

      //update cache and UI
      [_detailTypes removeObjectAtIndex:detailTypeIndex];
      [_detailTypesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
  else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"EditNewDetailType" sender:nil];
    }
  }
  
@end
