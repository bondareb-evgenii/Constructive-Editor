//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailTypeViewController.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@interface EditDetailTypeViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@interface EditDetailTypeViewController ()
  {
  __weak IBOutlet UIImageView* pictureImageView;
  }
@end
  
@implementation EditDetailTypeViewController

@synthesize detailType = _detailType;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  pictureImageView.image = [_detailType pictureToShow]
                  ? [_detailType pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }
  
- (void)selectPicture
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
  
- (IBAction)onTapOnPicture:(id)sender
  {
  [self selectPicture];
  }
  
@end

@implementation EditDetailTypeViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
	_detailType.picture = selectedImage;
  // Commit the change.
	[_detailType.managedObjectContext saveAndHandleError];
  pictureImageView.image = [_detailType pictureToShow]
                  ? [_detailType pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
