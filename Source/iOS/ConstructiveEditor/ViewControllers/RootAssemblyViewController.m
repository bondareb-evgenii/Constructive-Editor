//
//  RootAssemblyViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "RootAssemblyViewController.h"

#import "ActionSheet.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "AssemblyCellView.h"
#import "AssembliesAndDetailsViewController.h"
#import "AssemblyValidator.h"
#import "Detail.h"
#import "DetailType.h"
#import "EditAssemblyViewController.h"
#import "NSManagedObjectContextExtension.h"
#import "Picture.h"
#import "PreferencesKeys.h"
#import "StandardActionsPerformer.h"
#import "UIImage+Resize.h"

#import <CoreData/CoreData.h>

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
  _exportButton.enabled = YES;
  
  _rootAssemblyTable.delegate = self;
  _rootAssemblyTable.dataSource = self;
  [_rootAssemblyTable setEditing:NO animated:NO];//nothing to move, add or delete here
	[_rootAssemblyTable reloadData];
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
  else if ([@"PreviewInstructionFromRootAssemblyVC" isEqualToString:segue.identifier])
    {
    //Fill the instruction preview view controller with the data required
    }
  }

- (IBAction)exportDocument:(id)sender
  {
  PreviewInstructionBlock previewInstructionBlock = ^(Assembly* assembly)
    {
    [self performSegueWithIdentifier:@"PreviewInstructionFromRootAssemblyVC" sender:self];
    };
    
  [AssemblyValidator showExportMenuForRootAssembly:_rootAssembly currentAssembly:_rootAssembly inView:self.view previewInstructionBlock:previewInstructionBlock];
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
  
  UIImage* pictureToShowThumbnail60x60AspectFit = _rootAssembly.type.pictureToShowThumbnail60x60AspectFit;
    
  BOOL isPhotoSet = nil != pictureToShowThumbnail60x60AspectFit;
  AssemblyCellView* cell = (AssemblyCellView*)[tableView dequeueReusableCellWithIdentifier: isPhotoSet
                         ? @"AssemblyWithPhotoCell"
                         : @"AssemblyNoPhotoCell"];
  cell.picture.image = isPhotoSet
                     ? pictureToShowThumbnail60x60AspectFit
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
  if (nil == _rootAssembly.type.picture)
    {
    Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:_rootAssembly.type.managedObjectContext];
    _rootAssembly.type.picture = picture;
    }
  if (nil == _rootAssembly.type.pictureThumbnail60x60AspectFit)
    {
    Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:_rootAssembly.type.managedObjectContext];
    _rootAssembly.type.pictureThumbnail60x60AspectFit = picture;
    }
  _rootAssembly.type.picture.image = selectedImage;
  _rootAssembly.type.pictureThumbnail60x60AspectFit.image = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];
  
  // Commit the change.
	[_rootAssembly.managedObjectContext saveAsyncAndHandleError];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
