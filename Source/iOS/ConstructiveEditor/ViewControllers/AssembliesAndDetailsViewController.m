//
//  AssembliesAndDetailsViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "AssembliesAndDetailsViewController.h"

#import "Assembly.h"
#import "AssemblyCellView.h"
#import "Detail.h"
#import "DetailType.h"
#import "DetailCellView.h"
#import "EditAssemblyViewController.h"
#import "DetailTypesViewController.h"
#import "NSManagedObjectContextExtension.h"
#import "ReinterpretActionHandler.h"
#import "CoreData/CoreData.h"

@interface AssembliesAndDetailsViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface AssembliesAndDetailsViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@interface AssembliesAndDetailsViewController ()
  {
  NSMutableArray*                   _assemblies;
  NSMutableArray*                   _details;
  NSUInteger                        _addAssemblyIndex;
  NSUInteger                        _addDetailIndex;
  ReinterpretActionHandler*         _interpreter;
  __weak IBOutlet UITableView*      _assembliesAndDetailsTable;
  }
@end
  
@implementation AssembliesAndDetailsViewController

@synthesize assembly = _assembly;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  _assemblies = [[NSMutableArray alloc] initWithCapacity:self.assembly.assembliesInstalled.count];
  [_assemblies addObjectsFromArray:[self.assembly.assembliesInstalled allObjects]];
  _details = [[NSMutableArray alloc] initWithCapacity:self.assembly.detailsInstalled.count];
  [_details addObjectsFromArray:[self.assembly.detailsInstalled allObjects]];
  _assembliesAndDetailsTable.delegate = self;
  _assembliesAndDetailsTable.dataSource = self;
  [_assembliesAndDetailsTable setEditing:YES animated:NO];//always aditable (the application is called Editor :))
  _interpreter = [[ReinterpretActionHandler alloc] initWithViewController:self andSegueToNextViewControllerName:@"ShowAssemblyDetails"];
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
  
- (Assembly*)assemblyForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  if (0 == indexPath.section)
    {
    if (self.assembly.assemblyBase)
      return self.assembly.assemblyBase;
    if (self.assembly.assemblyBeforeTransformation)
      return self.assembly.assemblyBeforeTransformation;
    if (self.assembly.assemblyBeforeRotation)
      return self.assembly.assemblyBeforeRotation;
    }
    
  if (self.assembly.assemblyBase && 1 == indexPath.section)
    {
    NSUInteger assemblyIndex = indexPath.row;
    if (_assembliesAndDetailsTable.editing && assemblyIndex == _addAssemblyIndex)
      return nil;//this is an add item cell
    
    if (_assembliesAndDetailsTable.editing && assemblyIndex > _addAssemblyIndex)
      --assemblyIndex;
    return (Assembly*)[_assemblies objectAtIndex:assemblyIndex];
    }
    
//  if (( self.assembly.assemblyBase && 2 == indexPath.section) ||
//      (!self.assembly.assemblyBase && _details.count && 0 == indexPath.section))
//    return nil;//this is a details section
  return nil;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditAssemblyInterpreted"     isEqualToString:segue.identifier] ||
      [@"EditAssemblyNotInterpreted"  isEqualToString:segue.identifier])
    ((EditAssemblyViewController*)segue.destinationViewController).assembly = [self assemblyForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)((UIView*)sender).superview.superview]];
  else if([@"ShowAssemblyDetails" isEqualToString:segue.identifier])
    {
    Assembly* assembly = nil == sender
                       ? _interpreter.assembly
                       : [self assemblyForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)sender]];
    ((AssembliesAndDetailsViewController*)segue.destinationViewController).assembly = assembly;
    }
  }
  
- (IBAction)interpret:(id)sender
  {
  [_interpreter interpretAssembly:[self assemblyForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)((UIView*)sender).superview.superview]]];
  }

- (IBAction)reinterpret:(id)sender
  {
  [_interpreter reinterpretAssembly:[self assemblyForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)((UIView*)sender).superview.superview]]];
  }
  
@end

@implementation AssembliesAndDetailsViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  if (self.assembly.assemblyBase)
    return 3;
  return 1;//split, rotated or transformed
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  if (self.assembly.assemblyBase && 0 == section)
    return 1;
  if (self.assembly.assemblyBase && 1 == section)
    return _assembliesAndDetailsTable.editing ? _assemblies.count + 1 : _assemblies.count;
  if (( self.assembly.assemblyBase && 2 == section) ||
      (!self.assembly.assemblyBase && _details.count && 0 == section))
    return _assembliesAndDetailsTable.editing ? _details.count + 1 : _details.count;
  if (self.assembly.assemblyBeforeTransformation && 0 == section)
    return 1;
  if (self.assembly.assemblyBeforeRotation && 0 == section)
    return 1;
  return 0;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  if (self.assembly.assemblyBase && 0 == section)
    return NSLocalizedString(@"Bigger assembly", @"Assemblies and details: section header");
  if (self.assembly.assemblyBase && 1 == section)
    return NSLocalizedString(@"Smaller assemblies", @"Assemblies and details: section header");
  if (( self.assembly.assemblyBase && 2 == section) ||
      (!self.assembly.assemblyBase && _details.count && 0 == section))
    return NSLocalizedString(@"Details", @"Assemblies and details: section header");
  if (self.assembly.assemblyBeforeTransformation && 0 == section)
    return NSLocalizedString(@"Transformed assembly", @"Assemblies and details: section header");
  if (self.assembly.assemblyBeforeRotation && 0 == section)
    return NSLocalizedString(@"Rotated assembly", @"Assemblies and details: section header");
  return nil;
  }

- (UITableViewCell*)cellForAssembly:(Assembly*)assembly
  {
  if (!assembly)
    return nil;
    
  BOOL isAssemblyInterpreted = assembly.detailsInstalled.count ||
                               nil != assembly.assemblyBase ||
                               nil != assembly.assemblyBeforeTransformation ||
                               nil != assembly.assemblyBeforeRotation;
  AssemblyCellView* cell = (AssemblyCellView*)[_assembliesAndDetailsTable dequeueReusableCellWithIdentifier: isAssemblyInterpreted
                         ? @"AssemblyInterpretedCell"
                         : @"AssemblyNotInterpretedCell"];
  cell.picture.image = [assembly pictureToShow]
                     ? [assembly pictureToShow]
                     : [UIImage imageNamed:@"camera.png"];
  return cell;
  }
    
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  
  if (( self.assembly.assemblyBase && 2 == indexPath.section) ||
      (!self.assembly.assemblyBase && _details.count && 0 == indexPath.section))
    {
    if (_assembliesAndDetailsTable.editing && indexPath.row == _addDetailIndex)
      {
      UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
      addItemCell.textLabel.text = NSLocalizedString(@"Add detail", @"Assemblies and details: cell label");
      return addItemCell;
      }
      
    NSUInteger detailIndex = indexPath.row;
    if (_assembliesAndDetailsTable.editing && indexPath.row > _addDetailIndex)
      --detailIndex;
    Detail* detail = (Detail*)[_details objectAtIndex:detailIndex];
    DetailCellView* cell = (DetailCellView*)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    cell.picture.image = [detail.type pictureToShow]
                       ? [detail.type pictureToShow]
                       : [UIImage imageNamed:@"camera.png"];
    return cell;
    }
  if (self.assembly.assemblyBase && 1 == indexPath.section &&_assembliesAndDetailsTable.editing && indexPath.row == _addAssemblyIndex)
    {
    UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
    addItemCell.textLabel.text = NSLocalizedString(@"Add assembly", @"Assemblies and details: cell label");
    return addItemCell;
    }
    
  return [self cellForAssembly:[self assemblyForRowAtIndexPath:indexPath]];
  }
  
@end

@implementation AssembliesAndDetailsViewController (UITableViewDelegate)

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return;

  }*/
  
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
    // No editing style if not editing or the index path is nil.
  if (aTableView != _assembliesAndDetailsTable || !_assembliesAndDetailsTable.editing || !indexPath)
    return UITableViewCellEditingStyleNone;
  if (self.assembly.assemblyBase && indexPath.section == 0)
    {
    if (self.assembly.assembliesInstalled.count || self.assembly.detailsInstalled.count)
      return UITableViewCellEditingStyleNone;
    else
      return UITableViewCellEditingStyleDelete;
    }
  // Determine the editing style based on whether the cell is a placeholder for adding content or already 
  // existing content. Existing content can be deleted.    
  if (_assembliesAndDetailsTable.editing &&
      (( self.assembly.assemblyBase && indexPath.section == 1 && indexPath.row == _addAssemblyIndex) ||
       ( self.assembly.assemblyBase && indexPath.section == 2 && indexPath.row == _addDetailIndex) ||
       (!self.assembly.assemblyBase && _details.count && indexPath.section == 0 && indexPath.row == _addDetailIndex)))
		return UITableViewCellEditingStyleInsert;
  return UITableViewCellEditingStyleDelete;
  }
  
- (void)reloadVisibleAssembliesCells
  {
  [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[_assembliesAndDetailsTable indexPathsForVisibleRows] withRowAnimation:UITableViewRowAnimationNone];
  //next code may be useful if we use another animation where the user can see what cells are updating (of course we should not update all the visible cells every time though)
  /*NSArray* indexPathsForVisibleRows = [_assembliesAndDetailsTable indexPathsForVisibleRows];
  NSUInteger visibleCellsCount = indexPathsForVisibleRows.count;
  NSMutableArray* visibleAssembliesCellsIndexPaths = [NSMutableArray arrayWithCapacity:visibleCellsCount];
  [visibleAssembliesCellsIndexPaths addObjectsFromArray:indexPathsForVisibleRows];
  for (NSUInteger i = 0; i < visibleCellsCount; ++i)
    {
    NSIndexPath* indexPath = [visibleAssembliesCellsIndexPaths objectAtIndex:i];
    if (![[_assembliesAndDetailsTable cellForRowAtIndexPath:indexPath] isKindOfClass:[AssemblyCellView class]])
      {
      [visibleAssembliesCellsIndexPaths removeObjectAtIndex:i];
      break;
      }
    }
  [_assembliesAndDetailsTable reloadRowsAtIndexPaths:visibleAssembliesCellsIndexPaths withRowAnimation:UITableViewRowAnimationNone];*/
  }
  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return;
    
    
    //this is for smaller assemblies only; need the same for details;
    //and also deletion for: assemblyBase; assemblyRotated and assemblyTransformed
    
  
  if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
    if (0 == indexPath.section &&
         ((self.assembly.assemblyBase) ||
          (self.assembly.assemblyBeforeTransformation) ||
          (self.assembly.assemblyBeforeRotation)))
      {
      if ((self.assembly.assemblyBase))
        [_assembly.managedObjectContext deleteObject:self.assembly.assemblyBase];
      if (self.assembly.assemblyBeforeTransformation)
        [_assembly.managedObjectContext deleteObject:self.assembly.assemblyBeforeTransformation];
      if (self.assembly.assemblyBeforeRotation)
        [_assembly.managedObjectContext deleteObject:self.assembly.assemblyBeforeRotation];
        
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      //go to previous screen
      [self.navigationController popViewControllerAnimated:YES];
      }
    
    if ( self.assembly.assemblyBase && indexPath.section == 1)
      {
      BOOL afterAddItem = indexPath.row > _addAssemblyIndex;
      NSUInteger assemblyIndex = afterAddItem ? indexPath.row-1 : indexPath.row;
      if (!afterAddItem)
        --_addAssemblyIndex;
        
      [_assembly.managedObjectContext deleteObject:[_assemblies objectAtIndex:assemblyIndex]];
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      
      //update cache and UI
      [_assemblies removeObjectAtIndex:assemblyIndex];
      [_assembliesAndDetailsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
      if (!_assemblies.count && !_details.count)
        [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
      }
    else if ( ( self.assembly.assemblyBase && indexPath.section == 2) ||
              (!self.assembly.assemblyBase && _details.count && indexPath.section == 0))
      {
      BOOL afterAddItem = indexPath.row > _addDetailIndex;
      NSUInteger detailIndex = afterAddItem ? indexPath.row-1 : indexPath.row;
      if (!afterAddItem)
        --_addDetailIndex;
        
      [_assembly.managedObjectContext deleteObject:[_details objectAtIndex:detailIndex]];
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      
      [_details removeObjectAtIndex:detailIndex];
      
      //no updates, just go to previous screen
      if (!self.assembly.assemblyBase && !_details.count)
        [self.navigationController popViewControllerAnimated:YES];
      else //update UI
        {
        [_assembliesAndDetailsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
        if (!_assemblies.count && !_details.count)
          [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
        }
      }
    }
    
  else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    if ( self.assembly.assemblyBase && indexPath.section == 1)
      {
      BOOL shouldUpdateFirstSection = !_assemblies.count && !_details.count;
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.assembly.managedObjectContext];
      [self.assembly addAssembliesInstalledObject:assembly];
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      
      //update cache and UI
      [_assemblies insertObject:assembly atIndex:_addAssemblyIndex];
      [_assembliesAndDetailsTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addAssemblyIndex+1 inSection:indexPath.section], nil] withRowAnimation:UITableViewRowAnimationFade];
      //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
      if (shouldUpdateFirstSection)
        [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
      }
    else if ( ( self.assembly.assemblyBase && indexPath.section == 2) ||
              (!self.assembly.assemblyBase && _details.count && indexPath.section == 0))
      {
      BOOL shouldUpdateFirstSection = !_assemblies.count && !_details.count;
      Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:self.assembly.managedObjectContext];
      [self.assembly addDetailsInstalledObject:detail];
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      
      //update cache and UI
      [_details insertObject:detail atIndex:_addDetailIndex];
      [_assembliesAndDetailsTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addDetailIndex+1 inSection:indexPath.section], nil] withRowAnimation:UITableViewRowAnimationFade];
      //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
      if (shouldUpdateFirstSection)
        [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
      }
    }
  }
  
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
  {
  return NO;
  }

@end
