//
//  DetailTypesViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "DetailTypesViewController.h"

#import "Detail.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"
#import "CoreData/CoreData.h"

@interface DetailTypesViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface DetailTypesViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@interface DetailTypesViewController ()
  {
  __weak IBOutlet UITableView*      _assembliesAndDetailsTable;
  }
@end

@implementation DetailTypesViewController

@synthesize detail = _detail;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
//  _assembliesAndDetailsTable.delegate = self;
//  _assembliesAndDetailsTable.dataSource = self;
  }

- (void)viewDidUnload
  {
  _assembliesAndDetailsTable = nil;
  [super viewDidUnload];
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
	[_assembliesAndDetailsTable reloadData];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }

- (IBAction)Back:(id)sender
  {
  [_detail.managedObjectContext saveAndHandleError];
  [self dismissModalViewControllerAnimated:YES];
  }
    
- (IBAction)editDetailType:(id)sender
  {
  //TODO:Implement
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  //TODO:Implement
  }
  
@end

@implementation DetailTypesViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  //TODO:Implement
  return 0;
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  //TODO:Implement
  return 0;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  //TODO:Implement
  return nil;
  }
  
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  //TODO:Implement
  return nil;
  }
  
@end

@implementation DetailTypesViewController (UITableViewDelegate)

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  }*/
  
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
  //TODO:Implement
  return UITableViewCellEditingStyleNone;
  }
  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  //TODO:Implement
  }
  
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
  {
  //should we really move anything?
  return NO;
  }
  
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath 
	  toIndexPath:(NSIndexPath *)toIndexPath 
  {
  if (tableView != _assembliesAndDetailsTable)
    return;
    
//  if (fromIndexPath.row == _addItemIndex)
//    _addItemIndex = toIndexPath.row;
//  else
//    {
//    BOOL initialPosIsAfterAddItem = fromIndexPath.row > _addItemIndex;
//    BOOL resutingPosIsAfterAddItem = (toIndexPath.row > _addItemIndex) ||
//                                     (toIndexPath.row == _addItemIndex && toIndexPath.row > fromIndexPath.row);
//    NSUInteger indexToDeleteFrom = initialPosIsAfterAddItem ? fromIndexPath.row-1 : fromIndexPath.row;
//    NSUInteger indexToAddTo = resutingPosIsAfterAddItem ? toIndexPath.row-1 : toIndexPath.row;
//    
//    if (initialPosIsAfterAddItem && !resutingPosIsAfterAddItem)
//      ++_addItemIndex;
//    else if (!initialPosIsAfterAddItem && resutingPosIsAfterAddItem)
//      --_addItemIndex;
//    
//    if (indexToDeleteFrom == indexToAddTo)
//      return;
//    else
//      {
//      Assembly* assemblyToMove = [_rootAssembliesArray objectAtIndex:indexToDeleteFrom];
//      Assembly* previousChild = assemblyToMove.assemblyBase;
//      Assembly* previousassemblyExtended = assemblyToMove.assemblyExtended;
//      
//      [_rootAssembliesArray removeObjectAtIndex:indexToDeleteFrom];
//      
//      Assembly* newChild = 0 == indexToAddTo
//                         ? nil
//                         : [_rootAssembliesArray objectAtIndex:indexToAddTo-1];
//                         
//      Assembly* newassemblyExtended = _rootAssembliesArray.count == indexToAddTo
//                          ? nil
//                          : [_rootAssembliesArray objectAtIndex:indexToAddTo];
//                          
//      assemblyToMove.assemblyExtended = newassemblyExtended;
//      assemblyToMove.assemblyBase = newChild;
//      previousChild.assemblyExtended = previousassemblyExtended;
//      
//      [_rootAssembliesArray insertObject:assemblyToMove atIndex:indexToAddTo];
//      
//      
//      
//      //dependencies checking code
//      for (NSUInteger i = 0; i < _rootAssembliesArray.count; ++i)
//        {
//        Assembly* currentAssembly = [_rootAssembliesArray objectAtIndex:i];
//        BOOL assemblyBaseOK = _rootAssembliesArray.count < 2 ||
//                           (i == 0 && nil == currentAssembly.assemblyBase) ||
//                           (i != 0 && [_rootAssembliesArray objectAtIndex:i-1] == currentAssembly.assemblyBase);
//        BOOL assemblyExtendedOK = _rootAssembliesArray.count < 2 ||
//                        (i+1 == _rootAssembliesArray.count && nil == currentAssembly.assemblyExtended) ||
//                        (i+1 != _rootAssembliesArray.count && [_rootAssembliesArray objectAtIndex:i+1] == currentAssembly.assemblyExtended);
//        if(!assemblyBaseOK || !assemblyExtendedOK)
//          {
//          NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//          NSLog(@"_rootAssembliesArray = %@", _rootAssembliesArray);
//          break;
//          }
//        }
//      
//      //not effective but looks like no other partial ways to update work correctly
//      [self performSelector:@selector(reloadVisibleAssembliesCells) withObject:nil afterDelay:0.3];
//    
//      // Commit the change.
//      [_assembly.managedObjectContext saveAndHandleError];
//      }
//    }
  }


@end
