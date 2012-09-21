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

@interface AssembliesAndDetailsViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@interface AssembliesAndDetailsViewController ()
  {
  NSMutableArray*                   _assembliesGroups;
  NSMutableArray*                   _detailsGroups;
  NSMutableDictionary*              _assembliesGroupsDictionary;
  NSMutableDictionary*              _detailsGroupsDictionary;
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

@synthesize assemblyType = _assemblyType;

- (void)updateData
  {
  _assembliesGroups = [[NSMutableArray alloc] initWithCapacity:self.assemblyType.assembliesInstalled.count];
  _assembliesGroupsDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.assemblyType.assembliesInstalled.count];
  for (Assembly* assembly in [self.assemblyType.assembliesInstalled allObjects])
    {
    NSValue* key = [NSValue valueWithNonretainedObject:assembly.type];
    NSMutableArray* assemblies = [_assembliesGroupsDictionary objectForKey:key];
    if (assemblies.count)
      [assemblies addObject:assembly];
    else
      {
      assemblies = [[NSMutableArray alloc] initWithCapacity:1];
      [assemblies addObject:assembly];
      [_assembliesGroups addObject:key];
      [_assembliesGroupsDictionary setObject:assemblies forKey:key];
      }
    }
  
  _detailsGroups = [[NSMutableArray alloc] initWithCapacity:self.assemblyType.detailsInstalled.count];
  _detailsGroupsDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.assemblyType.detailsInstalled.count];
  for (Detail* detail in [self.assemblyType.detailsInstalled allObjects])
    {
    NSValue* key = [NSValue valueWithNonretainedObject:detail.type];
    NSMutableArray* details = [_detailsGroupsDictionary objectForKey:key];
    if (details.count)
      [details addObject:detail];
    else
      {
      details = [[NSMutableArray alloc] initWithCapacity:1];
      [details addObject:detail];
      [_detailsGroups addObject:key];
      [_detailsGroupsDictionary setObject:details forKey:key];
      }
    }
  }
  
- (void)reloadTableViewAnimated:(BOOL)animated
  {
  [_assembliesAndDetailsTable reloadData];
  }
  
- (void)updateInterpretButtons
  {
  BOOL isAssemblySplit = _assemblyType.detailsInstalled.count && !_assemblyType.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != _assemblyType.assemblyBase;
  BOOL isAssemblyTransformed = nil != _assemblyType.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != _assemblyType.assemblyBeforeRotation;
  _detachButton.enabled = !arePartsDetachedFromAssembly;
  _splitButton.enabled = !isAssemblySplit;
  _rotateButton.enabled = !isAssemblyRotated;
  _transformButton.enabled = !isAssemblyTransformed;
  }
  
- (void)removeDetailsAtIndexPath:(NSIndexPath*)indexPath
  {
  BOOL afterAddItem = indexPath.row > _addDetailIndex;
  if (!afterAddItem)
    --_addDetailIndex;
  
  NSUInteger detailIndex = [self detailIndexForRowAtIndexPath:indexPath];
  NSValue* key = [_detailsGroups objectAtIndex:detailIndex];
  for (Detail* detail in [_detailsGroupsDictionary objectForKey:key])
    [_assemblyType.managedObjectContext deleteObject:detail];
  // Commit the change.
  [_assemblyType.managedObjectContext saveAndHandleError];
  
  [_detailsGroups removeObjectAtIndex:detailIndex];
  [_detailsGroupsDictionary removeObjectForKey:key];
  
  //no updates, just go to previous screen
  if (!self.assemblyType.assemblyBase && !_detailsGroupsDictionary.count)
    [self.navigationController popViewControllerAnimated:YES];
  else //update UI
    {
    [_assembliesAndDetailsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
    if (!_assembliesGroupsDictionary.count && !_detailsGroupsDictionary.count)
      [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
    }
  }
  
- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
  
  [self updateData];
  _assembliesAndDetailsTable.delegate = self;
  _assembliesAndDetailsTable.dataSource = self;
  [_assembliesAndDetailsTable setEditing:YES animated:NO];//always aditable (the application is called Editor :))
  
  //activate appropriate buttons on navigation bar
  [self updateInterpretButtons];
  _preferencesButton.enabled = YES;
  _exportButton.enabled = NO;
  
  NSIndexPath* selectedIndexPath = [_assembliesAndDetailsTable indexPathForSelectedRow];
  Detail* detail = [self detailForRowAtIndexPath:selectedIndexPath];
  if (detail && !detail.type)//remove the detail added if there is no type selected for it
    [self removeDetailsAtIndexPath:selectedIndexPath];
  else
    {
    NSMutableArray* details = [_detailsGroupsDictionary objectForKey:[NSNull null]];
    if (details)//replace NSNull key with a detail type value
      {
      NSValue* key = [NSValue valueWithNonretainedObject:[(Detail*)details.lastObject type]];
      [_detailsGroupsDictionary removeObjectForKey:[NSNull null]];
      [_detailsGroupsDictionary setObject:details forKey:key];
      NSInteger nullObjectIndex = [_detailsGroups indexOfObject:[NSNull null]];
      [_detailsGroups setObject:key atIndexedSubscript:nullObjectIndex];
      }
    }
  
	[_assembliesAndDetailsTable reloadData];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }
  
- (NSInteger)assemblyIndexForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  if (0 == indexPath.section)
    {
    if (self.assemblyType.assemblyBase)
      return 0;
    if (self.assemblyType.assemblyBeforeTransformation)
      return 0;
    if (self.assemblyType.assemblyBeforeRotation)
      return 0;
    }
  
  if (self.assemblyType.assemblyBase && 1 == indexPath.section)
    return _assembliesAndDetailsTable.editing && indexPath.row > _addAssemblyIndex ? indexPath.row-1 : indexPath.row;
  return -1;
  }
  
- (Assembly*)assemblyForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  return [[self assembliesForRowAtIndexPath:indexPath] lastObject];
  }
  
- (NSMutableArray*)assembliesForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  if (0 == indexPath.section)
    {
    if (self.assemblyType.assemblyBase)
      {
      NSMutableArray* assemblies = [NSMutableArray arrayWithCapacity:1];
      [assemblies addObject:self.assemblyType.assemblyBase];
      return assemblies;
      }
    if (self.assemblyType.assemblyBeforeTransformation)
      {
      NSMutableArray* assemblies = [NSMutableArray arrayWithCapacity:1];
      [assemblies addObject:self.assemblyType.assemblyBeforeTransformation];
      return assemblies;
      }
    if (self.assemblyType.assemblyBeforeRotation)
      {
      NSMutableArray* assemblies = [NSMutableArray arrayWithCapacity:1];
      [assemblies addObject:self.assemblyType.assemblyBeforeRotation];
      return assemblies;
      }
    }
    
  if (self.assemblyType.assemblyBase && 1 == indexPath.section)
    {
    NSUInteger assemblyIndex = indexPath.row;
    if (_assembliesAndDetailsTable.editing && assemblyIndex == _addAssemblyIndex)
      return nil;//this is an add item cell
    
    if (_assembliesAndDetailsTable.editing && assemblyIndex > _addAssemblyIndex)
      --assemblyIndex;
    return [_assembliesGroupsDictionary objectForKey:[_assembliesGroups objectAtIndex:assemblyIndex]];
    }
  return nil;
  }
  
- (NSInteger)detailIndexForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  if (( self.assemblyType.assemblyBase && 2 == indexPath.section) ||
      (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && 0 == indexPath.section))
    {
    if (_assembliesAndDetailsTable.editing && indexPath.row == _addDetailIndex)
      {
      return -1;
      }
      
    return _assembliesAndDetailsTable.editing && indexPath.row > _addDetailIndex ? indexPath.row-1 : indexPath.row;
    }
  return -1;
  }
  
- (Detail*)detailForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  return [[self detailsForRowAtIndexPath:indexPath] lastObject];
  }

- (NSMutableArray*)detailsForRowAtIndexPath:(NSIndexPath*)indexPath
  {
  if (( self.assemblyType.assemblyBase && 2 == indexPath.section) ||
      (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && 0 == indexPath.section))
    {
    if (_assembliesAndDetailsTable.editing && indexPath.row == _addDetailIndex)
      {
      return nil;
      }
      
    NSUInteger detailIndex = indexPath.row;
    if (_assembliesAndDetailsTable.editing && indexPath.row > _addDetailIndex)
      --detailIndex;
    return [_detailsGroupsDictionary objectForKey:[_detailsGroups objectAtIndex:detailIndex]];
    }
  return nil;
  }
  
- (BOOL)shouldPutAddDetailCellForIndexPath:(NSIndexPath *)indexPath
  {
  return _assembliesAndDetailsTable.editing && indexPath.row == _addDetailIndex && (( self.assemblyType.assemblyBase && 2 == indexPath.section) || (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && 0 == indexPath.section));
  }

- (BOOL)shouldPutAddAssemblyCellForIndexPath:(NSIndexPath *)indexPath
  {
  return self.assemblyType.assemblyBase && 1 == indexPath.section &&_assembliesAndDetailsTable.editing && indexPath.row == _addAssemblyIndex;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditAssemblyPhotoSet"  isEqualToString:segue.identifier])
    ((EditAssemblyViewController*)segue.destinationViewController).assemblies = [self assembliesForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForSelectedRow]];
  else if([@"SelectDetailType" isEqualToString:segue.identifier])
    {
    ((DetailTypesViewController*)segue.destinationViewController).details = [self detailsForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForSelectedRow]];
    }
  else if([@"SelectDetailTypeForNewDetail" isEqualToString:segue.identifier])
    {
    //BOOL shouldUpdateFirstSection = !_assembliesGroupsDictionary.count && !_detailsGroupsDictionary.count;
    Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:self.assemblyType.managedObjectContext];
    [self.assemblyType addDetailsInstalledObject:detail];
    // Commit the change.
    [_assemblyType.managedObjectContext saveAndHandleError];

    //update cache
    NSMutableArray* details = [NSMutableArray arrayWithCapacity:1];
    [details addObject:detail];
    [_detailsGroupsDictionary setObject:details forKey:[NSNull null]];
    [_detailsGroups insertObject:[NSNull null] atIndex:_addDetailIndex];
    
    NSIndexPath* newDetailIndexPath = [NSIndexPath indexPathForRow:_addDetailIndex+1 inSection:[_assembliesAndDetailsTable indexPathForSelectedRow].section];
    //add ans select a cell for the new detail
    [_assembliesAndDetailsTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:newDetailIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [_assembliesAndDetailsTable selectRowAtIndexPath:newDetailIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
  //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
  //  if (shouldUpdateFirstSection)
  //    [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
    ((DetailTypesViewController*)segue.destinationViewController).details = details;
    }
  else if([@"SelectDetailConnectionPoint" isEqualToString:segue.identifier])
    {
    ((EditDetailViewController*)segue.destinationViewController).details = [self detailsForRowAtIndexPath:[_assembliesAndDetailsTable indexPathForSelectedRow]];
    }
  else if([@"ShowAssemblyDetails" isEqualToString:segue.identifier])
    {
    NSIndexPath* indexPath = [_assembliesAndDetailsTable indexPathForCell:(UITableViewCell*)sender];
    Assembly* assembly = [self assemblyForRowAtIndexPath:indexPath];
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
      [StandardActionsPerformer performStandardActionNamed:defaultActionName onAssemblyType:assembly.type inView:self.view withCompletionBlock:nil];
      }

    ((AssembliesAndDetailsViewController*)segue.destinationViewController).assemblyType = assembly.type;
    }
  }
  
- (IBAction)detachSmallerParts:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_DetachSmallerParts onAssemblyType:_assemblyType inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)splitToDetails:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_SplitToDetails onAssemblyType:_assemblyType inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)rotate:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_Rotate onAssemblyType:_assemblyType inView:self.view withCompletionBlock:^(BOOL actionPerformed)
    {
    [self updateData];
    [self reloadTableViewAnimated:YES];
    [self updateInterpretButtons];
    }];
  }
  
- (IBAction)transform:(id)sender
  {
  [StandardActionsPerformer  performStandardActionNamed:standardActionOnAssembly_Transform onAssemblyType:_assemblyType inView:self.view withCompletionBlock:^(BOOL actionPerformed)
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
  
- (IBAction)onAssembliesCountChanged:(UIStepper*)stepper
  {
  AssemblyCellView* assemblyCell = (AssemblyCellView*)stepper.superview.superview;
  NSIndexPath* cellIndexPath = [_assembliesAndDetailsTable indexPathForCell:assemblyCell];
  NSMutableArray* assemblies = [self assembliesForRowAtIndexPath:cellIndexPath];
  NSInteger newCount = stepper.value;
  NSInteger oldCount = assemblies.count;
  NSInteger deltaCount = newCount - oldCount;
  assemblyCell.countLabel.text = [NSString stringWithFormat:@"%d", newCount];
  if (deltaCount >= 0)
    {
    NSMutableArray* assembliesToAdd = [[NSMutableArray alloc] initWithCapacity:deltaCount];
    AssemblyType* type = [(Assembly*)[assemblies lastObject] type];
    for (int i = 0; i < deltaCount; ++i)
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.assemblyType.managedObjectContext];
      assembly.type = type;
      assembly.assemblyToInstallTo = _assemblyType;
      [assembliesToAdd addObject:assembly];
      }
    [assemblies addObjectsFromArray:assembliesToAdd];
    }
  else
    {
    deltaCount = abs(deltaCount);
    NSRange range = NSMakeRange(assemblies.count - deltaCount, deltaCount);
    NSArray* assembliesToRemove = [assemblies subarrayWithRange:range];
    [assemblies removeObjectsInRange:range];
    for (Assembly* assembly in assembliesToRemove)
      [_assemblyType.managedObjectContext deleteObject:assembly];
    }
  [_assemblyType.managedObjectContext saveAndHandleError];
  }
  
- (IBAction)onDetailsCountChanged:(UIStepper*)stepper
  {
  DetailCellView* detailCell = (DetailCellView*)stepper.superview.superview;
  NSIndexPath* cellIndexPath = [_assembliesAndDetailsTable indexPathForCell:detailCell];
  NSMutableArray* details = [self detailsForRowAtIndexPath:cellIndexPath];
  NSInteger newCount = stepper.value;
  NSInteger oldCount = details.count;
  NSInteger deltaCount = newCount - oldCount;
  detailCell.countLabel.text = [NSString stringWithFormat:@"%d", newCount];
  if (deltaCount >= 0)
    {
    NSMutableArray* detailsToAdd = [[NSMutableArray alloc] initWithCapacity:deltaCount];
    DetailType* type = [(Detail*)[details lastObject] type];
    for (int i = 0; i < deltaCount; ++i)
      {
      Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:self.assemblyType.managedObjectContext];
      detail.type = type;
      detail.assemblyToInstallTo = _assemblyType;
      [detailsToAdd addObject:detail];
      }
    [details addObjectsFromArray:detailsToAdd];
    }
  else
    {
    deltaCount = abs(deltaCount);
    NSRange range = NSMakeRange(details.count - deltaCount, deltaCount);
    NSArray* detailsToRemove = [details subarrayWithRange:range];
    [details removeObjectsInRange:range];
    for (Detail* detail in detailsToRemove)
      [_assemblyType.managedObjectContext deleteObject:detail];
    }
  [_assemblyType.managedObjectContext saveAndHandleError];
  }
  
@end

@implementation AssembliesAndDetailsViewController (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  if (self.assemblyType.assemblyBase)
    return 3;
  return 1;//split, rotated or transformed
  }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return 0;
  if (self.assemblyType.assemblyBase && 0 == section)
    return 1;
  if (self.assemblyType.assemblyBase && 1 == section)
    return _assembliesAndDetailsTable.editing ? _assembliesGroupsDictionary.count + 1 : _assembliesGroupsDictionary.count;
  if (( self.assemblyType.assemblyBase && 2 == section) ||
      (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && 0 == section))
    return _assembliesAndDetailsTable.editing ? _detailsGroupsDictionary.count + 1 : _detailsGroupsDictionary.count;
  if (self.assemblyType.assemblyBeforeTransformation && 0 == section)
    return 1;
  if (self.assemblyType.assemblyBeforeRotation && 0 == section)
    return 1;
  return 0;
  }

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  if (self.assemblyType.assemblyBase && 0 == section)
    return NSLocalizedString(@"Bigger assembly", @"Assemblies and details: section header");
  if (self.assemblyType.assemblyBase && 1 == section)
    return NSLocalizedString(@"Smaller assemblies", @"Assemblies and details: section header");
  if (( self.assemblyType.assemblyBase && 2 == section) ||
      (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && 0 == section))
    return NSLocalizedString(@"Details", @"Assemblies and details: section header");
  if (self.assemblyType.assemblyBeforeTransformation && 0 == section)
    return NSLocalizedString(@"Transformed assembly", @"Assemblies and details: section header");
  if (self.assemblyType.assemblyBeforeRotation && 0 == section)
    return NSLocalizedString(@"Rotated assembly", @"Assemblies and details: section header");
  return nil;
  }
  
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return nil;
  
  if ([self shouldPutAddDetailCellForIndexPath:indexPath])
    {
    UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
    addItemCell.textLabel.text = NSLocalizedString(@"Add detail", @"Assemblies and details: cell label");
    return addItemCell;
    }
  
  if ([self shouldPutAddAssemblyCellForIndexPath:indexPath])
    {
    UITableViewCell* addItemCell = [tableView dequeueReusableCellWithIdentifier:@"AddItemCell"];
    addItemCell.textLabel.text = NSLocalizedString(@"Add assembly", @"Assemblies and details: cell label");
    return addItemCell;
    }
  
  NSMutableArray* assemblies = [self assembliesForRowAtIndexPath:indexPath];
  Assembly* assembly = [assemblies lastObject];
  if (assembly)
    {
    BOOL isAssemblyPhotoSelected = nil != assembly.type.pictureToShow;
    AssemblyCellView* cell = (AssemblyCellView*)[_assembliesAndDetailsTable dequeueReusableCellWithIdentifier: isAssemblyPhotoSelected
                           ? @"AssemblyWithPhotoCell"
                           : @"AssemblyNoPhotoCell"];
    cell.picture.image = isAssemblyPhotoSelected
                       ? [assembly.type pictureToShow]
                       : [UIImage imageNamed:@"camera.png"];
    BOOL isBaseTransformedOrRotatedAsssembly = nil != assembly.assemblyExtended || nil != assembly.assemblyTransformed || nil != assembly.assemblyRotated;
    cell.countLabel.hidden = isBaseTransformedOrRotatedAsssembly;
    cell.countStepper.hidden = isBaseTransformedOrRotatedAsssembly;
    if (!isBaseTransformedOrRotatedAsssembly)
      {
      cell.countLabel.text = [NSString stringWithFormat:@"%d", assemblies.count];
      cell.countStepper.value = assemblies.count;
      }
    return cell;
    }
    
  NSMutableArray* details = [self detailsForRowAtIndexPath:indexPath];
  Detail* detail = [details lastObject];
  if (detail)
    {
    DetailCellView* cell = (DetailCellView*)[tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
    cell.picture.image = [detail.type pictureToShow]
                       ? [detail.type pictureToShow]
                       : [UIImage imageNamed:@"camera.png"];
    cell.countLabel.text = [NSString stringWithFormat:@"%d", details.count];
    cell.countStepper.value = details.count;
    return cell;
    }
    
  return nil;
  }
  
@end

@implementation AssembliesAndDetailsViewController (UITableViewDelegate)

- (void)selectPhoto
  {
  BOOL cameraModeIsPreferredByUser = YES;//default
  NSString* picturesSourcePreferredByUser = [[NSUserDefaults standardUserDefaults] stringForKey:preferredPicturesSource];
  if (picturesSourcePreferredByUser && ![picturesSourcePreferredByUser isEqualToString:preferredPicturesSource_Camera])
    cameraModeIsPreferredByUser = NO;
  UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  if (cameraModeIsPreferredByUser)
    sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
                                                      ? UIImagePickerControllerSourceTypeCamera
                                                      : UIImagePickerControllerSourceTypePhotoLibrary;
  UIImagePickerController *imagePicker = [UIImagePickerController new];
  imagePicker.sourceType = sourceType;
	imagePicker.delegate = self;
	[self presentViewController:imagePicker animated:YES completion:nil];
  }

- (void)createAndEditNewAssemblyAtIndexPath:(NSIndexPath*)indexPath
  {
  //BOOL shouldUpdateFirstSection = !_assembliesGroupsDictionary.count && !_detailsGroupsDictionary.count;
  Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.assemblyType.managedObjectContext];
  AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assemblyType.managedObjectContext];
  assembly.type = assemblyType;
  [self.assemblyType addAssembliesInstalledObject:assembly];
  // Commit the change.
  [_assemblyType.managedObjectContext saveAndHandleError];
  
  //update cache
  NSMutableArray* assemblies = [NSMutableArray arrayWithCapacity:1];
  [assemblies addObject:assembly];
  [_assembliesGroupsDictionary setObject:assemblies forKey:[NSNull null]];
  [_assembliesGroups insertObject:[NSNull null] atIndex:_addAssemblyIndex];
  
  //insert and select new cell to select a photo for
  NSIndexPath* newAssemblyIndexPath = [NSIndexPath indexPathForRow:_addAssemblyIndex+1 inSection:[_assembliesAndDetailsTable indexPathForSelectedRow].section];
    [_assembliesAndDetailsTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:newAssemblyIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [_assembliesAndDetailsTable selectRowAtIndexPath:newAssemblyIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
//  if (shouldUpdateFirstSection)
//    [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
  [self selectPhoto];
  }

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
  else
    {
    Assembly* assembly = [self assemblyForRowAtIndexPath:indexPath];
    if (assembly)
      {
      if (assembly.assemblyExtended || assembly.assemblyTransformed || assembly.assemblyRotated)
        [self selectPhoto];
      else
        {
        if (!assembly.type.pictureToShow)
          [self selectPhoto];
        else
          [self performSegueWithIdentifier:@"EditAssemblyPhotoSet" sender:nil];
        }
      }
    else if ([self shouldPutAddDetailCellForIndexPath:indexPath])
      [self performSegueWithIdentifier:@"SelectDetailTypeForNewDetail" sender:nil];
    else if ([self shouldPutAddAssemblyCellForIndexPath:indexPath])
      [self createAndEditNewAssemblyAtIndexPath:indexPath];
    }
  }
  
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
  {
    // No editing style if not editing or the index path is nil.
  if (aTableView != _assembliesAndDetailsTable || !_assembliesAndDetailsTable.editing || !indexPath)
    return UITableViewCellEditingStyleNone;
  if (self.assemblyType.assemblyBase && indexPath.section == 0)
    {
    if (self.assemblyType.assembliesInstalled.count || self.assemblyType.detailsInstalled.count)
      return UITableViewCellEditingStyleNone;
    else
      return UITableViewCellEditingStyleDelete;
    }
  // Determine the editing style based on whether the cell is a placeholder for adding content or already 
  // existing content. Existing content can be deleted.    
  if (_assembliesAndDetailsTable.editing &&
      (( self.assemblyType.assemblyBase && indexPath.section == 1 && indexPath.row == _addAssemblyIndex) ||
       ( self.assemblyType.assemblyBase && indexPath.section == 2 && indexPath.row == _addDetailIndex) ||
       (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && indexPath.section == 0 && indexPath.row == _addDetailIndex)))
		return UITableViewCellEditingStyleInsert;
  return UITableViewCellEditingStyleDelete;
  }
  
- (void)removeSmallerAssembliesAtIndexPath:(NSIndexPath*)indexPath
  {
  BOOL afterAddItem = indexPath.row > _addAssemblyIndex;
  if (!afterAddItem)
    --_addAssemblyIndex;
  
  NSUInteger assemblyIndex = [self assemblyIndexForRowAtIndexPath:indexPath];
  NSValue* key = [_assembliesGroups objectAtIndex:assemblyIndex];
  for (Assembly* assembly in [_assembliesGroupsDictionary objectForKey:key])
    [_assemblyType.managedObjectContext deleteObject:assembly];
  // Commit the change.
  [_assemblyType.managedObjectContext saveAndHandleError];
  
  //update cache
  [_assembliesGroups removeObjectAtIndex:assemblyIndex];
  [_assembliesGroupsDictionary removeObjectForKey:key];
  
  //update UI
  [_assembliesAndDetailsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  //update the first section if there are no more details or assemblies installed in order for user to be able to delete the base assembly
  if (!_assembliesGroupsDictionary.count && !_detailsGroupsDictionary.count)
    [_assembliesAndDetailsTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationNone];
  }
    
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
  {
  if (tableView != _assembliesAndDetailsTable)
    return;
  
  if (editingStyle == UITableViewCellEditingStyleDelete) 
    {
    if (0 == indexPath.section &&
         ((self.assemblyType.assemblyBase) ||
          (self.assemblyType.assemblyBeforeTransformation) ||
          (self.assemblyType.assemblyBeforeRotation)))
      {
      if ((self.assemblyType.assemblyBase))
        [_assemblyType.managedObjectContext deleteObject:self.assemblyType.assemblyBase];
      if (self.assemblyType.assemblyBeforeTransformation)
        [_assemblyType.managedObjectContext deleteObject:self.assemblyType.assemblyBeforeTransformation];
      if (self.assemblyType.assemblyBeforeRotation)
        [_assemblyType.managedObjectContext deleteObject:self.assemblyType.assemblyBeforeRotation];
        
      // Commit the change.
      [_assemblyType.managedObjectContext saveAndHandleError];
      //go to previous screen
      [self.navigationController popViewControllerAnimated:YES];
      }
    
    if ( self.assemblyType.assemblyBase && indexPath.section == 1)//remmoving smaller assembly
      [self removeSmallerAssembliesAtIndexPath:indexPath];
    else
      {
      Detail* detail = [self detailForRowAtIndexPath:indexPath];
      if (detail)
        [self removeDetailsAtIndexPath:indexPath];
      }
    }
  else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
    if ( self.assemblyType.assemblyBase && indexPath.section == 1)
      {
      [_assembliesAndDetailsTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
      [self createAndEditNewAssemblyAtIndexPath:indexPath];
      }
    else if ( ( self.assemblyType.assemblyBase && indexPath.section == 2) ||
              (!self.assemblyType.assemblyBase && _detailsGroupsDictionary.count && indexPath.section == 0))
      {
      [_assembliesAndDetailsTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
      [self performSegueWithIdentifier:@"SelectDetailTypeForNewDetail" sender:nil];
      }
    }
  }
  
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
  {
  return NO;
  }

@end

@implementation AssembliesAndDetailsViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {
  NSMutableArray* assemblies = [_assembliesGroupsDictionary objectForKey:[NSNull null]];
  if (assemblies)//replace NSNull key with an assembly type value
    {
    NSValue* key = [NSValue valueWithNonretainedObject:[(Assembly*)assemblies.lastObject type]];
    [_assembliesGroupsDictionary removeObjectForKey:[NSNull null]];
    [_assembliesGroupsDictionary setObject:assemblies forKey:key];
    NSInteger nullObjectIndex = [_assembliesGroups indexOfObject:[NSNull null]];
    [_assembliesGroups setObject:key atIndexedSubscript:nullObjectIndex];
    }
    
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
  NSIndexPath* selectedIndexPath = [_assembliesAndDetailsTable indexPathForSelectedRow];
	NSMutableArray* selectedAssemblies = [self assembliesForRowAtIndexPath:selectedIndexPath];
  for (Assembly* assembly in selectedAssemblies)
    assembly.type.picture = selectedImage;
  // Commit the change.
	[_assemblyType.managedObjectContext saveAndHandleError];
  
  NSArray* viewControllers = self.navigationController.viewControllers;
  Assembly* lastAssembly = [selectedAssemblies lastObject];
  if (![lastAssembly assemblyExtended] && ![lastAssembly assemblyTransformed] && ![lastAssembly assemblyRotated])
    {
    if (viewControllers.count >=2 && [[viewControllers objectAtIndex:viewControllers.count-2] isKindOfClass:[EditAssemblyViewController class]])
      {
      [self.navigationController popViewControllerAnimated:NO];
      }
    else
      {
      EditAssemblyViewController* editAssemblyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EditAssemblyViewController"];
      editAssemblyVC.assemblies = [self assembliesForRowAtIndexPath:selectedIndexPath];
      [self.navigationController pushViewController:editAssemblyVC animated:NO];
      }
    }

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
  NSIndexPath* selectedIndexPath = [_assembliesAndDetailsTable indexPathForSelectedRow];
  Assembly* assembly = [self assemblyForRowAtIndexPath:selectedIndexPath];
  if (assembly && !assembly.assemblyExtended && !assembly.type.pictureToShow)//remove the assembly added if there is no picture selected for it
    [self removeSmallerAssembliesAtIndexPath:selectedIndexPath];
	[self dismissModalViewControllerAnimated:YES];
  }

@end
