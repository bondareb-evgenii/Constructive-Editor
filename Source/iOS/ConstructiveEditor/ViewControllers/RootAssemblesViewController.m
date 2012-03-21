//
//  RootAssemblesViewController.m
//  CoreDataTest1
//
//  Created by Evgenii Bondarev on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootAssemblesViewController.h"

#import "Assembly.h"
#import "Detail.h"
#import "DetailType.h"
//#import "EditAssemblyViewController.h"
//#import "EditDetailTypeViewController.h"
//#import "SelectDetailTypeViewController.h"
#import "CoreData/CoreData.h"

//@interface RootAssemblesViewController () <EditAssemblyViewControllerDelegate, SelectDetailTypeViewControllerDelegate>
//@end

@interface RootAssemblesViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface RootAssemblesViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation RootAssemblesViewController

//@synthesize detailToAdd = _detailToAdd;
//@synthesize assemblyToAdd = _assemblyToAdd;
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
  /*
	 Fetch existing assemblies.
	 Create a fetch request, add a sort descriptor, then execute the fetch.
	 */
	NSFetchRequest *assembliesRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *assemblyEntity = [NSEntityDescription entityForName:@"Assembly" inManagedObjectContext:_managedObjectContext];
	[assembliesRequest setEntity:assemblyEntity];
	
	// Order the assemblies by creation date, most recent first.
	/*NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];*/
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *assembliesError = nil;
	_rootAssembliesArray = [[_managedObjectContext executeFetchRequest:assembliesRequest error:&assembliesError] mutableCopy];
  if (_rootAssembliesArray == nil)
		NSLog(@"Error: %@", assembliesError.debugDescription);
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

- (IBAction)addAssembly:(id)sender
  {
  //_selectedIndexPath = nil;
  [self performSegueWithIdentifier:@"EntitiesToEditAssembly" sender:self];
  }
  
- (IBAction)addDetail:(id)sender
  {
  //_selectedIndexPath = nil;
  [self performSegueWithIdentifier:@"EntitiesToSelectDetailType" sender:self];
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

/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EntitiesToEditAssembly" isEqualToString:segue.identifier])
    {
    EditAssemblyViewController* editAssemblyVC = ((EditAssemblyViewController*)segue.destinationViewController);
    editAssemblyVC.delegate = self;
    editAssemblyVC.managedObjectContext = _managedObjectContext;
    if (nil == _selectedIndexPath)
      return;
    editAssemblyVC.assembly = [_rootAssembliesArray objectAtIndex:_selectedIndexPath.row];
    }
  else if ([@"EntitiesToSelectDetailType" isEqualToString:segue.identifier])
    {
    SelectDetailTypeViewController* selectDetailVC = ((SelectDetailTypeViewController*)segue.destinationViewController);
    selectDetailVC.delegate = self;
    selectDetailVC.managedObjectContext = _managedObjectContext;
    if (nil == _selectedIndexPath)
      return;
    selectDetailVC.detail = [_detailsArray objectAtIndex:_selectedIndexPath.row];
    }
  _selectedIndexPath = nil;
  }*/
  
@end

@implementation RootAssemblesViewController (UITableViewDataSource)

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
    
  static NSString *CellIdentifier = @"AssembliesCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil)
    {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
  if (_rootAssembliesTable.editing)
    {
    if(indexPath.row == _addItemIndex)
      {
      cell.textLabel.text = @"ADD";
      return cell;
      }
    else
      {
      NSUInteger assemblyIndex;
      if (indexPath.row > _addItemIndex)
        assemblyIndex = indexPath.row - 1;
      else
        assemblyIndex = indexPath.row;
      Assembly *assembly = (Assembly*)[_rootAssembliesArray objectAtIndex:assemblyIndex];
      cell.textLabel.text = @"";//[NSString stringWithFormat:@"%d", [assembly.level intValue]+1];
      cell.imageView.image = assembly.picture;
      }
    }
  else
    {
    Assembly *assembly = (Assembly*)[_rootAssembliesArray objectAtIndex:indexPath.row];
      cell.textLabel.text = @"";//[NSString stringWithFormat:@"%d", [assembly.level intValue]+1];
      cell.imageView.image = assembly.picture;
    }
    
  return cell;
  }
  
@end

@implementation RootAssemblesViewController (UITableViewDelegate)

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
    
    NSManagedObject *assemblyToDelete = [_rootAssembliesArray objectAtIndex:assemblyIndex];
    [_managedObjectContext deleteObject:assemblyToDelete];
    
    // Update the array and table view.
    [_rootAssembliesArray removeObjectAtIndex:indexPath.row];
    [_rootAssembliesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // Commit the change.
    NSError *error = nil;
    if (![_managedObjectContext save:&error])
      NSLog(@"Error: %@", error.debugDescription);
    }
  else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    [_rootAssembliesArray insertObject:[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.managedObjectContext] atIndex:_addItemIndex];
    [_rootAssembliesTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addItemIndex +1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationFade];
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
      [_rootAssembliesArray removeObjectAtIndex:indexToDeleteFrom];
      [_rootAssembliesArray insertObject:assemblyToMove atIndex:indexToAddTo];
      // Commit the change.
      NSError *error = nil;
      if (![_managedObjectContext save:&error])
        NSLog(@"Error: %@", error.debugDescription);
      }
    }
  }


@end
