//
//  AssemblesAndDetailsViewController.m
//  ConstructiveEditor
//
//  Created by Evgenii Bondarev on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AssemblesAndDetailsViewController.h"

#import "Assembly.h"
#import "AssemblyCellView.h"
#import "Detail.h"
#import "DetailType.h"
#import "EditAssemblyViewController.h"
//#import "EditDetailTypeViewController.h"
//#import "SelectDetailTypeViewController.h"
#import "CoreData/CoreData.h"

@interface AssemblesAndDetailsViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface AssemblesAndDetailsViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation AssemblesAndDetailsViewController

//@synthesize detailToAdd = _detailToAdd;
//@synthesize assemblyToAdd = _assemblyToAdd;

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return _managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Document.sqlite"]];
	
	NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];

	// Allow inferred migration from the original version of the application.
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
    {
    NSLog(@"Error: %@", error.debugDescription);
    }    
	
    return _persistentStoreCoordinator;
}


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (void)saveContext {
    
    NSError *error = nil;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}  

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  _rootAssembliesTable.delegate = self;
  _rootAssembliesTable.dataSource = self;
  
  _managedObjectContext = [self managedObjectContext];
  _rootAssembliesArray = nil;
  _rootAssembliesArray = [[NSMutableArray alloc] initWithCapacity:10];
  /*
	 Fetch existing assemblies.
	 Create a fetch request, add a sort descriptor, then execute the fetch.
	 */
	NSFetchRequest *assembliesRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *assemblyEntity = [NSEntityDescription entityForName:@"Assembly" inManagedObjectContext:_managedObjectContext];
	[assembliesRequest setEntity:assemblyEntity];
  [assembliesRequest setPredicate:[NSPredicate predicateWithFormat:@"connectionPoint = nil"]];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *assembliesError = nil;
	NSArray* assembliesWithNoConnectionPoint = [[_managedObjectContext executeFetchRequest:assembliesRequest error:&assembliesError] mutableCopy];
  if (assembliesWithNoConnectionPoint == nil)
    {
		NSLog(@"Error: %@", assembliesError.debugDescription);
    return;
    }

  NSArray* assembliesWithNoextendedAssembly = [assembliesWithNoConnectionPoint filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
    {
    return nil == [evaluatedObject extendedAssembly];
    }]];
  if (0 == assembliesWithNoextendedAssembly.count)
    return;
  if (1 < assembliesWithNoextendedAssembly.count)
    {
    NSLog(@"There is more then one assembly with no extendedAssembly in array: %@", assembliesWithNoextendedAssembly);
    return;
    }
  Assembly* rootLevelAssembly = [assembliesWithNoextendedAssembly objectAtIndex:0];
  [_rootAssembliesArray addObject:rootLevelAssembly];
  for (NSUInteger i = 0; i < assembliesWithNoConnectionPoint.count; ++i)
    {
    rootLevelAssembly = rootLevelAssembly.baseAssembly;
    if (nil == rootLevelAssembly)
      break;
    [_rootAssembliesArray insertObject:rootLevelAssembly atIndex:0];
    }
  }

- (void)viewDidUnload
  {
  _rootAssembliesTable = nil;
    _editOrDoneButton = nil;
    [super viewDidUnload];
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
  
  /*if (nil != self.assemblyToAdd)
    [_rootAssembliesArray insertObject:self.assemblyToAdd atIndex:0];
  else if (nil != self.detailToAdd)
    [_detailsArray insertObject:self.detailToAdd atIndex:0];*/
  
	[_rootAssembliesTable reloadData];
  
  /*if (nil != self.assemblyToAdd)
    {
    [_rootAssembliesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.assemblyToAdd = nil;
    }
  else if (nil != self.detailToAdd)
    {
    [_rootAssembliesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.detailToAdd = nil;
    }*/
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}
  
- (IBAction)EditRootLevel:(id)sender
  {
  if(_rootAssembliesTable.editing)
    {
		[super setEditing:NO animated:NO]; 
		[_rootAssembliesTable setEditing:NO animated:NO];
		[_rootAssembliesTable reloadData];
		[_editOrDoneButton setTitle:@"Edit"];
		[_editOrDoneButton setStyle:UIBarButtonItemStyleBordered];
    }
	else
    {
		[super setEditing:YES animated:YES]; 
		[_rootAssembliesTable setEditing:YES animated:YES];
		[_rootAssembliesTable reloadData];
		[_editOrDoneButton setTitle:@"Done"];
		[_editOrDoneButton setStyle:UIBarButtonItemStyleDone];
    }
  }
  
- (IBAction)editAssembly:(id)sender
  {
  NSUInteger row = [[_rootAssembliesTable indexPathForCell:(UITableViewCell*)[[sender superview] superview]] row];
  NSUInteger assemblyIndex;
  if (_rootAssembliesTable.editing && row > _addItemIndex)
    assemblyIndex = row - 1;
  else
    assemblyIndex = row;
    
  _selectedIndexPath = [NSIndexPath indexPathForRow:assemblyIndex inSection:0];
  [self performSegueWithIdentifier:@"RootAssembliesToEditAssembly" sender:self];
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"RootAssembliesToEditAssembly" isEqualToString:segue.identifier])
    {
    EditAssemblyViewController* editAssemblyVC = ((EditAssemblyViewController*)segue.destinationViewController);
    editAssemblyVC.assembly = [_rootAssembliesArray objectAtIndex:_selectedIndexPath.row];
    }
  /*else if ([@"EntitiesToSelectDetailType" isEqualToString:segue.identifier])
    {
    SelectDetailTypeViewController* selectDetailVC = ((SelectDetailTypeViewController*)segue.destinationViewController);
    selectDetailVC.delegate = self;
    selectDetailVC.managedObjectContext = _managedObjectContext;
    if (nil == _selectedIndexPath)
      return;
    selectDetailVC.detail = [_detailsArray objectAtIndex:_selectedIndexPath.row];
    }*/
  _selectedIndexPath = nil;
  }
  
@end

@implementation AssemblesAndDetailsViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _rootAssembliesTable)
    return 0;
  return 1;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _rootAssembliesTable)
    return 0;
    
  NSUInteger count = _rootAssembliesArray.count;
  if(_rootAssembliesTable.editing)
    count++;
  return count;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _rootAssembliesTable)
    return nil;
  return @"Root Assemblies";
  }
  
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _rootAssembliesTable)
    return nil;
    
  UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
  if (_rootAssembliesTable.editing && indexPath.row == _addItemIndex)
    {
    addItemCell.textLabel.text = NSLocalizedString(@"Add assembly", @"root assemblies table view");
    return addItemCell;
    }
    
  AssemblyCellView* cell = (AssemblyCellView*)[tableView dequeueReusableCellWithIdentifier:@"AssemblyCell"];
    
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  if (_rootAssembliesTable.editing)
    {
    NSUInteger assemblyIndex;
    if (indexPath.row > _addItemIndex)
      assemblyIndex = indexPath.row - 1;
    else
      assemblyIndex = indexPath.row;
    Assembly *assembly = (Assembly*)[_rootAssembliesArray objectAtIndex:assemblyIndex];
    cell.stepNumberLabel.text = [NSString stringWithFormat:@"%d", assemblyIndex+1];
    cell.picture.autoresizingMask = UIViewAutoresizingNone;
    cell.picture.image = assembly.picture
                       ? assembly.picture
                       : [UIImage imageNamed:@"camera.png"];
    }
  else
    {
    Assembly *assembly = (Assembly*)[_rootAssembliesArray objectAtIndex:indexPath.row];
    cell.stepNumberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row+1];
    cell.picture.autoresizingMask = UIViewAutoresizingNone;
    cell.picture.image = assembly.picture
                       ? assembly.picture
                       : [UIImage imageNamed:@"camera.png"];
    }

  return cell;
  }
  
@end

@implementation AssemblesAndDetailsViewController (UITableViewDelegate)

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _rootAssembliesTable)
    return;
  _selectedIndexPath = indexPath;
  if (0 == indexPath.section)
    [self performSegueWithIdentifier:@"EntitiesToEditAssembly" sender:self];
  else if (1 == indexPath.section)
    [self performSegueWithIdentifier:@"EntitiesToSelectDetailType" sender:self];
  }*/
  
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
    // No editing style if not editing or the index path is nil.
  if (_rootAssembliesTable.editing == NO || !indexPath)
    return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already 
    // existing content. Existing content can be deleted.    
  if (_rootAssembliesTable.editing && indexPath.row == _addItemIndex)
		return UITableViewCellEditingStyleInsert;
  else 
		return UITableViewCellEditingStyleDelete;
  return UITableViewCellEditingStyleNone;
  }
  
- (void)reloadVisibleAssembliesCells
  {
  [_rootAssembliesTable reloadRowsAtIndexPaths:[_rootAssembliesTable indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
  //next code may be useful if we use another animation where the user can see what cells are updating (of course we should not update all the visible cells every time though)
  /*NSArray* indexPathsForVisibleRows = [_rootAssembliesTable indexPathsForVisibleRows];
  NSUInteger visibleCellsCount = indexPathsForVisibleRows.count;
  NSMutableArray* visibleAssembliesCellsIndexPaths = [NSMutableArray arrayWithCapacity:visibleCellsCount];
  [visibleAssembliesCellsIndexPaths addObjectsFromArray:indexPathsForVisibleRows];
  for (NSUInteger i = 0; i < visibleCellsCount; ++i)
    {
    NSIndexPath* indexPath = [visibleAssembliesCellsIndexPaths objectAtIndex:i];
    if (![[_rootAssembliesTable cellForRowAtIndexPath:indexPath] isKindOfClass:[AssemblyCellView class]])
      {
      [visibleAssembliesCellsIndexPaths removeObjectAtIndex:i];
      break;
      }
    }
  [_rootAssembliesTable reloadRowsAtIndexPaths:visibleAssembliesCellsIndexPaths withRowAnimation:UITableViewRowAnimationNone];*/
  }
  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _rootAssembliesTable)
    return;
    
  if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
    BOOL afterAddItem = indexPath.row > _addItemIndex;
    NSUInteger assemblyIndex = afterAddItem ? indexPath.row-1 : indexPath.row;
    if (!afterAddItem)
      --_addItemIndex;
    
    Assembly* assemblyToDelete = [_rootAssembliesArray objectAtIndex:assemblyIndex];
    if (nil != assemblyToDelete.extendedAssembly)
      assemblyToDelete.extendedAssembly.baseAssembly = assemblyToDelete.baseAssembly;
    else
      assemblyToDelete.baseAssembly.extendedAssembly = assemblyToDelete.extendedAssembly;
    [_managedObjectContext deleteObject:assemblyToDelete];
    
    // Update the array and table view.
    [_rootAssembliesArray removeObjectAtIndex:assemblyIndex];
    
    
    
    //dependencies checking code
    for (NSUInteger i = 0; i < _rootAssembliesArray.count; ++i)
        {
        Assembly* currentAssembly = [_rootAssembliesArray objectAtIndex:i];
        BOOL baseAssemblyOK = _rootAssembliesArray.count < 2 ||
                           (i == 0 && nil == currentAssembly.baseAssembly) ||
                           (i != 0 && [_rootAssembliesArray objectAtIndex:i-1] == currentAssembly.baseAssembly);
        BOOL extendedAssemblyOK = _rootAssembliesArray.count < 2 ||
                        (i+1 == _rootAssembliesArray.count && nil == currentAssembly.extendedAssembly) ||
                        (i+1 != _rootAssembliesArray.count && [_rootAssembliesArray objectAtIndex:i+1] == currentAssembly.extendedAssembly);
        if(!baseAssemblyOK || !extendedAssemblyOK)
          {
          NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          NSLog(@"_rootAssembliesArray = %@", _rootAssembliesArray);
          break;
          }
        }
        
        
    
    [_rootAssembliesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self performSelector:@selector(reloadVisibleAssembliesCells) withObject:nil afterDelay:0.3];
    
    // Commit the change.
    NSError *error = nil;
    if (![_managedObjectContext save:&error])
      NSLog(@"Error: %@", error.debugDescription);
    }
  else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.managedObjectContext];
    assembly.extendedAssembly = nil;
    assembly.baseAssembly = nil;
    if (_addItemIndex < _rootAssembliesArray.count)
      {
      Assembly* extendedAssembly = [_rootAssembliesArray objectAtIndex:_addItemIndex];
      Assembly* extendedAssemblyPreviousbaseAssembly = extendedAssembly.baseAssembly;
      assembly.extendedAssembly = extendedAssembly;
      assembly.baseAssembly = extendedAssemblyPreviousbaseAssembly;
      }
    else if (_addItemIndex > 0)
      assembly.baseAssembly = [_rootAssembliesArray objectAtIndex:_addItemIndex-1];
    
    [_rootAssembliesArray insertObject:assembly atIndex:_addItemIndex];
    
    
    
    //dependencies checking code
    for (NSUInteger i = 0; i < _rootAssembliesArray.count; ++i)
        {
        Assembly* currentAssembly = [_rootAssembliesArray objectAtIndex:i];
        BOOL baseAssemblyOK = _rootAssembliesArray.count < 2 ||
                           (i == 0 && nil == currentAssembly.baseAssembly) ||
                           (i != 0 && [_rootAssembliesArray objectAtIndex:i-1] == currentAssembly.baseAssembly);
        BOOL extendedAssemblyOK = _rootAssembliesArray.count < 2 ||
                        (i+1 == _rootAssembliesArray.count && nil == currentAssembly.extendedAssembly) ||
                        (i+1 != _rootAssembliesArray.count && [_rootAssembliesArray objectAtIndex:i+1] == currentAssembly.extendedAssembly);
        if(!baseAssemblyOK || !extendedAssemblyOK)
          {
          NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          NSLog(@"_rootAssembliesArray = %@", _rootAssembliesArray);
          break;
          }
        }	
        
        
    
    [_rootAssembliesTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addItemIndex+1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
    [self performSelector:@selector(reloadVisibleAssembliesCells) withObject:nil afterDelay:0.3];
    
    // Commit the change.
    NSError *error = nil;
    if (![_managedObjectContext save:&error])
      NSLog(@"Error: %@", error.debugDescription);
    }
  }
  
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
  {
  return YES;
  }
  
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	  toIndexPath:(NSIndexPath *)toIndexPath 
  {
  if (tableView != _rootAssembliesTable)
    return;
    
  if (fromIndexPath.row == _addItemIndex)
    _addItemIndex = toIndexPath.row;
  else
    {
    BOOL initialPosIsAfterAddItem = fromIndexPath.row > _addItemIndex;
    BOOL resutingPosIsAfterAddItem = (toIndexPath.row > _addItemIndex) ||
                                     (toIndexPath.row == _addItemIndex && toIndexPath.row > fromIndexPath.row);
    NSUInteger indexToDeleteFrom = initialPosIsAfterAddItem ? fromIndexPath.row-1 : fromIndexPath.row;
    NSUInteger indexToAddTo = resutingPosIsAfterAddItem ? toIndexPath.row-1 : toIndexPath.row;
    
    if (initialPosIsAfterAddItem && !resutingPosIsAfterAddItem)
      ++_addItemIndex;
    else if (!initialPosIsAfterAddItem && resutingPosIsAfterAddItem)
      --_addItemIndex;
    
    if (indexToDeleteFrom == indexToAddTo)
      return;
    else
      {
      Assembly* assemblyToMove = [_rootAssembliesArray objectAtIndex:indexToDeleteFrom];
      Assembly* previousChild = assemblyToMove.baseAssembly;
      Assembly* previousextendedAssembly = assemblyToMove.extendedAssembly;
      
      [_rootAssembliesArray removeObjectAtIndex:indexToDeleteFrom];
      
      Assembly* newChild = 0 == indexToAddTo
                         ? nil
                         : [_rootAssembliesArray objectAtIndex:indexToAddTo-1];
                         
      Assembly* newextendedAssembly = _rootAssembliesArray.count == indexToAddTo
                          ? nil
                          : [_rootAssembliesArray objectAtIndex:indexToAddTo];
                          
      assemblyToMove.extendedAssembly = newextendedAssembly;
      assemblyToMove.baseAssembly = newChild;
      previousChild.extendedAssembly = previousextendedAssembly;
      
      [_rootAssembliesArray insertObject:assemblyToMove atIndex:indexToAddTo];
      
      
      
      //dependencies checking code
      for (NSUInteger i = 0; i < _rootAssembliesArray.count; ++i)
        {
        Assembly* currentAssembly = [_rootAssembliesArray objectAtIndex:i];
        BOOL baseAssemblyOK = _rootAssembliesArray.count < 2 ||
                           (i == 0 && nil == currentAssembly.baseAssembly) ||
                           (i != 0 && [_rootAssembliesArray objectAtIndex:i-1] == currentAssembly.baseAssembly);
        BOOL extendedAssemblyOK = _rootAssembliesArray.count < 2 ||
                        (i+1 == _rootAssembliesArray.count && nil == currentAssembly.extendedAssembly) ||
                        (i+1 != _rootAssembliesArray.count && [_rootAssembliesArray objectAtIndex:i+1] == currentAssembly.extendedAssembly);
        if(!baseAssemblyOK || !extendedAssemblyOK)
          {
          NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          NSLog(@"_rootAssembliesArray = %@", _rootAssembliesArray);
          break;
          }
        }
      
      //not effective but looks like no other partial ways to update work correctly
      [self performSelector:@selector(reloadVisibleAssembliesCells) withObject:nil afterDelay:0.3];
    
      // Commit the change.
      NSError *error = nil;
      if (![_managedObjectContext save:&error])
        NSLog(@"Error: %@", error.debugDescription);
      }
    }
  }


@end
