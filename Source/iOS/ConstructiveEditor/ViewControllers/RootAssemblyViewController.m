//
//  RootAssemblyViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "RootAssemblyViewController.h"

#import "Assembly.h"
#import "AssemblyCellView.h"
#import "Detail.h"
#import "DetailType.h"
#import "EditAssemblyViewController.h"
#import "AssembliesAndDetailsViewController.h"
#import "NSManagedObjectContextExtension.h"
#import "ActionSheet.h"
#import "PreferencesKeys.h"
#import "ReinterpretActionHandler.h"
#import "CoreData/CoreData.h"

@interface RootAssemblyViewController ()
  {
  NSPersistentStoreCoordinator*           _persistentStoreCoordinator;
  NSManagedObjectModel*                   _managedObjectModel;
  NSManagedObjectContext*                 _managedObjectContext;
  Assembly*                               _rootAssembly;
  ReinterpretActionHandler*               _interpreter;
  __weak IBOutlet UITableView*            _rootAssemblyTable;
  }
@end

@interface RootAssemblyViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface RootAssemblyViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@implementation RootAssemblyViewController
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

- (NSString *)applicationDocumentsDirectory
  {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  return basePath;
  } 

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  _managedObjectContext = [self managedObjectContext];
  /*
	 Fetch existing assemblies.
	 Create a fetch request, add a sort descriptor, then execute the fetch.
	 */
	NSFetchRequest *assembliesRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *assemblyEntity = [NSEntityDescription entityForName:@"Assembly" inManagedObjectContext:_managedObjectContext];
	[assembliesRequest setEntity:assemblyEntity];
  [assembliesRequest setPredicate:[NSPredicate predicateWithFormat:@"(assemblyToInstallTo = nil) AND (assemblyExtended = nil) AND (assemblyTransformed = nil) AND (assemblyRotated = nil)"]];
	
	// Execute the fetch -- create a mutable copy of the result.
	NSError *assembliesError = nil;
	NSArray* rootAssemblies = [[_managedObjectContext executeFetchRequest:assembliesRequest error:&assembliesError] mutableCopy];
  if (rootAssemblies == nil)
    {
		NSLog(@"Error: %@", assembliesError.debugDescription);
    return;
    }

  if (1 == rootAssemblies.count)
    _rootAssembly = [rootAssemblies objectAtIndex:0];
  else if (rootAssemblies.count > 1)
    NSLog(@"There is more then one root assembly in model: %@", rootAssemblies);
  else if (0 == rootAssemblies.count)
    {
    _rootAssembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.managedObjectContext];
    _rootAssembly.assemblyExtended = nil;
    _rootAssembly.assemblyBase = nil;
    // Commit the change.
    [_managedObjectContext saveAndHandleError];
    }
  rootAssemblies = nil;
  
  _rootAssemblyTable.delegate = self;
  _rootAssemblyTable.dataSource = self;
  [_rootAssemblyTable setEditing:NO animated:NO];//nothing to move, add or delete here
  _interpreter = [[ReinterpretActionHandler alloc] initWithViewController:self andSegueToNextViewControllerName:@"ShowRootAssemblyDetails"];
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated]; 
	[_rootAssemblyTable reloadData];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditRootAssemblyInterpreted"     isEqualToString:segue.identifier] ||
      [@"EditRootAssemblyNotInterpreted"  isEqualToString:segue.identifier])
    ((EditAssemblyViewController*)segue.destinationViewController).assembly = _rootAssembly;
  else if([@"ShowRootAssemblyDetails" isEqualToString:segue.identifier])
    ((AssembliesAndDetailsViewController*)segue.destinationViewController).assembly = _rootAssembly;
  }
  
- (IBAction)interpret:(id)sender
  {
  [_interpreter interpretAssembly:_rootAssembly];
  }
  
- (IBAction)reinterpret:(id)sender
  {
  [_interpreter reinterpretAssembly:_rootAssembly];
  }
  
- (IBAction)goBackFromEditAssembly:(UIStoryboardSegue*)segue
  {
  [_managedObjectContext saveAndHandleError];
  }
  
- (IBAction)goBackFromAssembliesAndDetails:(UIStoryboardSegue*)segue
  {
  [_managedObjectContext saveAndHandleError];
  }
  
@end

@implementation RootAssemblyViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _rootAssemblyTable)
    return 0;
  return 1;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _rootAssemblyTable)
    return 0;
  return 1;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _rootAssemblyTable)
    return nil;
  return NSLocalizedString(@"End result", @"Root assembly table header");
  }
  
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _rootAssemblyTable || indexPath.section != 0 || indexPath.row != 0)
    return nil;
    
  BOOL isAssemblyInterpreted = _rootAssembly.detailsInstalled.count ||
                               nil != _rootAssembly.assemblyBase ||
                               nil != _rootAssembly.assemblyBeforeTransformation ||
                               nil != _rootAssembly.assemblyBeforeRotation;
  AssemblyCellView* cell = (AssemblyCellView*)[tableView dequeueReusableCellWithIdentifier: isAssemblyInterpreted
                         ? @"AssemblyInterpretedCell"
                         : @"AssemblyNotInterpretedCell"];
  cell.picture.image = [_rootAssembly pictureToShow]
                     ? [_rootAssembly pictureToShow]
                     : [UIImage imageNamed:@"camera.png"];
  return cell;
  }
  
@end

@implementation RootAssemblyViewController (UITableViewDelegate)
@end

