//
//  RootAssemblyViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "RootAssemblyViewController.h"

#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyCellView.h"
#import "Detail.h"
#import "DetailType.h"
#import "EditAssemblyViewController.h"
#import "AssembliesAndDetailsViewController.h"
#import "AssemblyValidator.h"
#import "ActionSheet.h"
#import "PreferencesKeys.h"
#import "StandardActionsPerformer.h"
#import "NSManagedObjectContextExtension.h"
#import "CoreData/CoreData.h"

@interface RootAssemblyViewController ()
  {
  __weak IBOutlet UITableView*  _rootAssemblyTable;
  __weak IBOutlet UIButton*     _preferencesButton;
  __weak IBOutlet UIButton*     _exportButton;
  }
@end

@interface RootAssemblyViewController (UITableViewDataSource) <UITableViewDataSource>
@end

@interface RootAssemblyViewController (UITableViewDelegate) <UITableViewDelegate>
@end

@interface RootAssemblyViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation RootAssemblyViewController

@synthesize rootAssembly = _rootAssembly;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  }

- (void)viewWillAppear:(BOOL)animated
  {
	[super viewWillAppear:animated];
  
  //activate appropriate buttons on navigation bar
  _preferencesButton.enabled = YES;
  _exportButton.enabled = [AssemblyValidator isAssemblyComplete:_rootAssembly withError:nil];
  
  _rootAssemblyTable.delegate = self;
  _rootAssemblyTable.dataSource = self;
  [_rootAssemblyTable setEditing:NO animated:NO];//nothing to move, add or delete here
	[_rootAssemblyTable reloadData];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if([@"ShowRootAssemblyDetails" isEqualToString:segue.identifier])
    {
    BOOL isAssemblyInterpreted = _rootAssembly.type.detailsInstalled.count ||
                                 nil != _rootAssembly.type.assemblyBase ||
                                 nil != _rootAssembly.type.assemblyBeforeTransformation ||
                                 nil != _rootAssembly.type.assemblyBeforeRotation;
    if (!isAssemblyInterpreted)
      {
      //Perform a default action on the assembly (split to details / detach smaller parts / rotate / transform)
      NSString* defaultActionName = [[NSUserDefaults standardUserDefaults] stringForKey:standardActionOnAssembly];
      if (!defaultActionName)
        defaultActionName = standardActionOnAssembly_Default;
      [StandardActionsPerformer performStandardActionNamed:defaultActionName onAssemblyType:_rootAssembly.type inView:self.view withCompletionBlock:nil];
      }
    ((AssembliesAndDetailsViewController*)segue.destinationViewController).assemblyType = _rootAssembly.type;
    }
  }

- (IBAction)exportDocument:(id)sender
  {
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
    
  BOOL isPhotoSet = nil != _rootAssembly.type.pictureToShow;
  AssemblyCellView* cell = (AssemblyCellView*)[tableView dequeueReusableCellWithIdentifier: isPhotoSet
                         ? @"AssemblyWithPhotoCell"
                         : @"AssemblyNoPhotoCell"];
  cell.picture.image = [_rootAssembly.type pictureToShow]
                     ? [_rootAssembly.type pictureToShow]
                     : [UIImage imageNamed:@"camera.png"];
  return cell;
  }
  
@end

@implementation RootAssemblyViewController (UITableViewDelegate)

- (void)selectPhoto
  {
  BOOL cameraModeIsPreferredByUser = YES;//default
  NSString* picturesSourcePreferredByUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"preferredPicturesSource"];
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
  
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
  {
  [self selectPhoto];
  }

@end

@implementation RootAssemblyViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
  _rootAssembly.type.picture = selectedImage;
  // Commit the change.
	[_rootAssembly.managedObjectContext saveAndHandleError];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
