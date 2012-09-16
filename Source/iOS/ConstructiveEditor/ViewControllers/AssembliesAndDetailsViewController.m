//
//  AssembliesAndDetailsViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "AssembliesAndDetailsViewController.h"

#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyCellView.h"
#import "Detail.h"
#import "DetailType.h"
#import "DetailCellView.h"
#import "EditAssemblyViewController.h"
#import "EditDetailViewController.h"
#import "DetailTypesViewController.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"
#import "StandardActionsPerformer.h"
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
  __weak IBOutlet UITableView*      _assembliesAndDetailsTable;
  __weak IBOutlet UIButton* _detachButton;
  __weak IBOutlet UIButton* _splitButton;
  __weak IBOutlet UIButton* _rotateButton;
  __weak IBOutlet UIButton* _transformButton;
  __weak IBOutlet UIButton* _preferencesButton;
  __weak IBOutlet UIButton* _exportButton;
  }
@end
  
@implementation AssembliesAndDetailsViewController

@synthesize assembly = _assembly;

- (void)updateData
  {
  _assemblies = [[NSMutableArray alloc] initWithCapacity:self.assembly.type.assembliesInstalled.count];
  [_assemblies addObjectsFromArray:[self.assembly.type.assembliesInstalled allObjects]];
  _details = [[NSMutableArray alloc] initWithCapacity:self.assembly.type.detailsInstalled.count];
  [_details addObjectsFromArray:[self.assembly.type.detailsInstalled allObjects]];
  }
  
- (void)reloadTableViewAnimated:(BOOL)animated
  {
  [_assembliesAndDetailsTable reloadData];
  }
  
- (void)updateInterpretButtons
  {
  BOOL isAssemblySplit = _assembly.type.detailsInstalled.count && !_assembly.type.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != _assembly.type.assemblyBase;
  BOOL isAssemblyTransformed = nil != _assembly.type.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != _assembly.type.assemblyBeforeRotation;
  _detachButton.enabled = !arePartsDetachedFromAssembly;
  _splitButton.enabled = !isAssemblySplit;
  _rotateButton.enabled = !isAssemblyRotated;
  _transformButton.enabled = !isAssemblyTransformed;
  }
  
- (void)viewDidLoad
  {
  [super viewDidLoad];
  [self updateData];
  _assembliesAndDetailsTable.delegate = self;
  _assembliesAndDetailsTable.dataSource = self;
  [_assembliesAndDetailsTable setEditing:YES animated:NO];//always aditable (the application is called Editor :))
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
  
  //activate appropriate buttons on navigation bar
  [self updateInterpretButtons];
  _preferencesButton.enabled = YES;
  _exportButton.enabled = NO;
  
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
    if (self.assembly.type.assemblyBase)
      return self.assembly.type.assemblyBase;
    if (self.assembly.type.assemblyBeforeTransformation)
      return self.assembly.type.assemblyBeforeTransformation;
    if (self.assembly.type.assemblyBeforeRotation)
      return self.assembly.type.assemblyBeforeRotation;
    }
    
  if (self.assembly.type.assemblyBase && 1 == indexPath.section)
    {
    NSUInteger assemblyIndex = indexPath.row;
    if (_assembliesAndDetailsTable.editing && assemblyIndex == _addAssemblyIndex)
      return nil;//this is an add item cell
    
    if (_assembliesAndDetailsTable.editing && assemblyIndex > _addAssemblyIndex)
      --assemblyIndex;
    return (Assembly*)[_assemblies objectAtIndex:assemblyIndex];
    }
    
//  if (( self.assembly.type.assemblyBase && 2 == indexPath.section) ||
//      (!self.assembly.type.assemblyBase && _details.count && 0 == indexPath.section))
//    return nil;//this is a details section
  return nil;
  }
  
- (Detail*)detailForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  if (( self.assembly.type.assemblyBase && 2 == indexPath.section) ||
      (!self.assembly.type.assemblyBase && _details.count && 0 == indexPath.section))
    {
    if (_assembliesAndDetailsTable.editing && indexPath.row == _addDetailIndex)
      {
      return nil;
      }
      
    NSUInteger detailIndex = indexPath.row;
    if (_assembliesAndDetailsTable.editing && indexPath.row > _addDetailIndex)
      --detailIndex;
    return (Detail*)[_details objectAtIndex:detailIndex];
    }
  return nil;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditAssemblyPhotoSet"     isEqualToString:segue.identifier] ||
      [@"EditAssemblyNoPhoto"  isEqualToString:segue.identifier])
    ((EditAssemblyViewController*)segue.destinationViewController).assembly = [self assemblyForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)sender]];
  else if([@"SelectDetailType" isEqualToString:segue.identifier])
    {
    ((DetailTypesViewController*)segue.destinationViewController).detail = [self detailForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForSelectedRow]];
    }
  else if([@"SelectDetailConnectionPoint" isEqualToString:segue.identifier])
    {
    ((EditDetailViewController*)segue.destinationViewController).detail = [self detailForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForSelectedRow]];
    }
  else if([@"ShowAssemblyDetails" isEqualToString:segue.identifier])
    {
    Assembly* assembly = [self assemblyForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)sender]];
    BOOL isAssemblyInterpreted = assembly.type.detailsInstalled.count ||
                                 nil != assembly.type.assemblyBase ||
                                 nil != assembly.type.assemblyBeforeTransformation ||
                                 nil != assembly.type.assemblyBeforeRotation;
    if (!isAssemblyInterpreted)
      {
      //Perform a default action on the assembly (split to details / detach smaller parts / rotate / transform)
      NSString* defaultActionName = [[NSUserDefaults standardUserDefaults] stringForKey:standardActionOnAssembly];
      if (!defaultActionName)
        defaultActionName = standardActionOnAssembly_Default;
      [StandardActionsPerformer performStandardActionNamed:defaultActionName onAssembly:assembly inView:self.view withCompletionBlock:nil];
      }

    ((AssembliesAndDetailsViewController*)segue.destinationViewController).assembly = assembly;
    }
  }
  
- (IBAction)detachSmallerParts:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_DetachSmallerParts onAssembly:_assembly inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)splitToDetails:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_SplitToDetails onAssembly:_assembly inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)rotate:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_Rotate onAssembly:_assembly inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)transform:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_Transform onAssembly:_assembly inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)showPreferences:(id)sender
  {
  }
  
- (IBAction)exportDocument:(id)sender
  {
  }
  
  
  
  
  
  
@end

@implementation AssembliesAndDetailsViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  if (self.assembly.type.assemblyBase)
    return 3;
  return 1;//split, rotated or transformed
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  if (self.assembly.type.assemblyBase && 0 == section)
    return 1;
  if (self.assembly.type.assemblyBase && 1 == section)
    return _assembliesAndDetailsTable.editing ? _assemblies.count + 1 : _assemblies.count;
  if (( self.assembly.type.assemblyBase && 2 == section) ||
      (!self.assembly.type.assemblyBase && _details.count && 0 == section))
    return _assembliesAndDetailsTable.editing ? _details.count + 1 : _details.count;
  if (self.assembly.type.assemblyBeforeTransformation && 0 == section)
    return 1;
  if (self.assembly.type.assemblyBeforeRotation && 0 == section)
    return 1;
  return 0;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  if (self.assembly.type.assemblyBase && 0 == section)
    return NSLocalizedString(@"Bigger assembly", @"Assemblies and details: section header");
  if (self.assembly.type.assemblyBase && 1 == section)
    return NSLocalizedString(@"Smaller assemblies", @"Assemblies and details: section header");
  if (( self.assembly.type.assemblyBase && 2 == section) ||
      (!self.assembly.type.assemblyBase && _details.count && 0 == section))
    return NSLocalizedString(@"Details", @"Assemblies and details: section header");
  if (self.assembly.type.assemblyBeforeTransformation && 0 == section)
    return NSLocalizedString(@"Transformed assembly", @"Assemblies and details: section header");
  if (self.assembly.type.assemblyBeforeRotation && 0 == section)
    return NSLocalizedString(@"Rotated assembly", @"Assemblies and details: section header");
  return nil;
  }
    
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  
  BOOL shouldPutAddDetailCellForIndexPath = _assembliesAndDetailsTable.editing && indexPath.row == _addDetailIndex && (( self.assembly.type.assemblyBase && 2 == indexPath.section) || (!self.assembly.type.assemblyBase && _details.count && 0 == indexPath.section));
  if (shouldPutAddDetailCellForIndexPath)
    {
    UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
    addItemCell.textLabel.text = NSLocalizedString(@"Add detail", @"Assemblies and details: cell label");
    return addItemCell;
    }
  
  BOOL shouldPutAddAssemblyCellForIndexPath = self.assembly.type.assemblyBase && 1 == indexPath.section &&_assembliesAndDetailsTable.editing && indexPath.row == _addAssemblyIndex;
  if (shouldPutAddAssemblyCellForIndexPath)
    {
    UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
    addItemCell.textLabel.text = NSLocalizedString(@"Add assembly", @"Assemblies and details: cell label");
    return addItemCell;
    }
  
  Assembly* assembly = [self assemblyForRowAtIndexPath:indexPath];
  if (assembly)
    {
    BOOL isAssemblyPhotoSelected = nil !=assembly.type.pictureToShow;
    AssemblyCellView* cell = (AssemblyCellView*)[_assembliesAndDetailsTable dequeueReusableCellWithIdentifier: isAssemblyPhotoSelected
                           ? @"AssemblyWithPhotoCell"
                           : @"AssemblyNoPhotoCell"];
    cell.picture.image = isAssemblyPhotoSelected
                       ? [assembly.type pictureToShow]
                       : [UIImage imageNamed:@"camera.png"];
    return cell;
    }
    
  Detail* detail = [self detailForRowAtIndexPath:indexPath];
  if (detail)
    {
    DetailCellView* cell = (DetailCellView*)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    cell.picture.image = [detail.type pictureToShow]
                       ? [detail.type pictureToShow]
                       : [UIImage imageNamed:@"camera.png"];
    return cell;
    }
    
  return nil;
  }
  
@end

@implementation AssembliesAndDetailsViewController (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return;
  Detail* detail = [self detailForRowAtIndexPath:indexPath];
  if (detail)
    {
    if (detail.type)
      [self performSegueWithIdentifier:@"SelectDetailConnectionPoint" sender:nil];
    else
      [self performSegueWithIdentifier:@"SelectDetailType" sender:nil];
    }
  }
  
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
    // No editing style if not editing or the index path is nil.
  if (aTableView != _assembliesAndDetailsTable || !_assembliesAndDetailsTable.editing || !indexPath)
    return UITableViewCellEditingStyleNone;
  if (self.assembly.type.assemblyBase && indexPath.section == 0)
    {
    if (self.assembly.type.assembliesInstalled.count || self.assembly.type.detailsInstalled.count)
      return UITableViewCellEditingStyleNone;
    else
      return UITableViewCellEditingStyleDelete;
    }
  // Determine the editing style based on whether the cell is a placeholder for adding content or already 
  // existing content. Existing content can be deleted.    
  if (_assembliesAndDetailsTable.editing &&
      (( self.assembly.type.assemblyBase && indexPath.section == 1 && indexPath.row == _addAssemblyIndex) ||
       ( self.assembly.type.assemblyBase && indexPath.section == 2 && indexPath.row == _addDetailIndex) ||
       (!self.assembly.type.assemblyBase && _details.count && indexPath.section == 0 && indexPath.row == _addDetailIndex)))
		return UITableViewCellEditingStyleInsert;
  return UITableViewCellEditingStyleDelete;
  }
  
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return;
  
  if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
    if (0 == indexPath.section &&
         ((self.assembly.type.assemblyBase) ||
          (self.assembly.type.assemblyBeforeTransformation) ||
          (self.assembly.type.assemblyBeforeRotation)))
      {
      if ((self.assembly.type.assemblyBase))
        [_assembly.managedObjectContext deleteObject:self.assembly.type.assemblyBase];
      if (self.assembly.type.assemblyBeforeTransformation)
        [_assembly.managedObjectContext deleteObject:self.assembly.type.assemblyBeforeTransformation];
      if (self.assembly.type.assemblyBeforeRotation)
        [_assembly.managedObjectContext deleteObject:self.assembly.type.assemblyBeforeRotation];
        
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      //go to previous screen
      [self.navigationController popViewControllerAnimated:YES];
      }
    
    if ( self.assembly.type.assemblyBase && indexPath.section == 1)
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
    else if ( ( self.assembly.type.assemblyBase && indexPath.section == 2) ||
              (!self.assembly.type.assemblyBase && _details.count && indexPath.section == 0))
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
      if (!self.assembly.type.assemblyBase && !_details.count)
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
    if ( self.assembly.type.assemblyBase && indexPath.section == 1)
      {
      BOOL shouldUpdateFirstSection = !_assemblies.count && !_details.count;
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.assembly.managedObjectContext];
      AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
      assembly.type = assemblyType;
      [self.assembly.type addAssembliesInstalledObject:assembly];
      // Commit the change.
      [_assembly.managedObjectContext saveAndHandleError];
      
      //update cache and UI
      [_assemblies insertObject:assembly atIndex:_addAssemblyIndex];
      [_assembliesAndDetailsTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:_addAssemblyIndex+1 inSection:indexPath.section], nil] withRowAnimation:UITableViewRowAnimationFade];
      //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
      if (shouldUpdateFirstSection)
        [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
      }
    else if ( ( self.assembly.type.assemblyBase && indexPath.section == 2) ||
              (!self.assembly.type.assemblyBase && _details.count && indexPath.section == 0))
      {
      BOOL shouldUpdateFirstSection = !_assemblies.count && !_details.count;
      Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:self.assembly.managedObjectContext];
      [self.assembly.type addDetailsInstalledObject:detail];
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
