//
//  ViewController.m
//  CoreDataTest1
//
//  Created by Evgenii Bondarev on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "Assembly.h"
#import "Detail.h"
#import "DetailType.h"
#import "EditAssemblyViewController.h"
#import "EditDetailTypeViewController.h"
#import "SelectDetailTypeViewController.h"
#import "CoreData/CoreData.h"

@interface ViewController () <EditAssemblyViewControllerDelegate, SelectDetailTypeViewControllerDelegate>
@end

@interface ViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface ViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation ViewController

@synthesize detailToAdd = _detailToAdd;
@synthesize assemblyToAdd = _assemblyToAdd;
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
  
  _entitiesTable.delegate = self;
  _entitiesTable.dataSource = self;
  
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
	_assembliesArray = [[_managedObjectContext executeFetchRequest:assembliesRequest error:&assembliesError] mutableCopy];
  if (_assembliesArray == nil)
    {
		NSLog(@"Error: %@", assembliesError.debugDescription);
    }
    
  NSFetchRequest *detailsRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *detailEntity = [NSEntityDescription entityForName:@"Detail" inManagedObjectContext:_managedObjectContext];
	[detailsRequest setEntity:detailEntity];
  NSError *detailsError = nil;
  _detailsArray = [[_managedObjectContext executeFetchRequest:detailsRequest error:&detailsError] mutableCopy];
	if (_detailsArray == nil)
		NSLog(@"Error: %@", detailsError.debugDescription);
  }

- (void)viewDidUnload
  {
  _entitiesTable = nil;
    [super viewDidUnload];
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
  
  if (nil != self.assemblyToAdd)
    [_assembliesArray insertObject:self.assemblyToAdd atIndex:0];
  else if (nil != self.detailToAdd)
    [_detailsArray insertObject:self.detailToAdd atIndex:0];
  
	[_entitiesTable reloadData];
  
  if (nil != self.assemblyToAdd)
    {
    [_entitiesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.assemblyToAdd = nil;
    }
  else if (nil != self.detailToAdd)
    {
    [_entitiesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.detailToAdd = nil;
    }
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)addAssembly:(id)sender
  {
  _selectedIndexPath = nil;
  [self performSegueWithIdentifier:@"EntitiesToEditAssembly" sender:self];
  }
  
- (IBAction)addDetail:(id)sender
  {
  _selectedIndexPath = nil;
  [self performSegueWithIdentifier:@"EntitiesToSelectDetailType" sender:self];
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EntitiesToEditAssembly" isEqualToString:segue.identifier])
    {
    EditAssemblyViewController* editAssemblyVC = ((EditAssemblyViewController*)segue.destinationViewController);
    editAssemblyVC.delegate = self;
    editAssemblyVC.managedObjectContext = _managedObjectContext;
    if (nil == _selectedIndexPath)
      return;
    editAssemblyVC.assembly = [_assembliesArray objectAtIndex:_selectedIndexPath.row];
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
  }
  
@end

@implementation ViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _entitiesTable)
    return 0;
  return 2;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _entitiesTable)
    return 0;
  else if (0 == section)
    return _assembliesArray.count;
  else if (1 == section)
    return _detailsArray.count;
  return 0;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _entitiesTable)
    return nil;
  else if (0 == section)
    return @"Assemblies";
  else if (1 == section)
    return @"Details";
  return nil;
  }
  
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (0 == indexPath.section)
    {
    static NSString *CellIdentifier = @"AssembliesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
      {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      
    Assembly *assembly = (Assembly*)[_assembliesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d", [assembly.level intValue]+1];
    cell.imageView.image = assembly.picture;
      
    return cell;
    }
  else if (1 == indexPath.section)
    {
    static NSString *CellIdentifier = @"DetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
      {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
      cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
      }
      
    Detail *detail = (Detail*)[_detailsArray objectAtIndex:indexPath.row];
    NSString* detailTypeIdentifier = detail.type.identifier ? detail.type.identifier : @"";
    cell.textLabel.text = [NSString stringWithFormat:@"%@ l=%d", detailTypeIdentifier, [detail.type.length intValue]];
    cell.imageView.image = detail.type.picture;
      
    return cell;
    }
  return nil;
  }
  
@end

@implementation ViewController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _entitiesTable)
    return;
  _selectedIndexPath = indexPath;
  if (0 == indexPath.section)
    [self performSegueWithIdentifier:@"EntitiesToEditAssembly" sender:self];
  else if (1 == indexPath.section)
    [self performSegueWithIdentifier:@"EntitiesToSelectDetailType" sender:self];
  }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _entitiesTable)
    return;
    
  if (editingStyle == UITableViewCellEditingStyleDelete)
    {
    if (0 == indexPath.section)
      {
      NSManagedObject *assemblyToDelete = [_assembliesArray objectAtIndex:indexPath.row];
      [_managedObjectContext deleteObject:assemblyToDelete];
      
      // Update the array and table view.
      [_assembliesArray removeObjectAtIndex:indexPath.row];
      [_entitiesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
      
      // Commit the change.
      NSError *error = nil;
      if (![_managedObjectContext save:&error])
        {
        NSLog(@"Error: %@", error.debugDescription);
        }
      }
    else if (1 == indexPath.section)
      {
      NSManagedObject *detaiTypeToDelete = [_detailsArray objectAtIndex:indexPath.row];
      [_managedObjectContext deleteObject:detaiTypeToDelete];
      
      // Update the array and table view.
      [_detailsArray removeObjectAtIndex:indexPath.row];
      [_entitiesTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
      
      // Commit the change.
      NSError *error = nil;
      if (![_managedObjectContext save:&error])
        {
        NSLog(@"Error: %@", error.debugDescription);
        }
      }
    }
  } 

@end
