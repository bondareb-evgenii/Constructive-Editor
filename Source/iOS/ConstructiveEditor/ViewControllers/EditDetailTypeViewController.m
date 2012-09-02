//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailTypeViewController.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"

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
//  UIImagePickerControllerSourceType desiredSourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
//                                                      ? UIImagePickerControllerSourceTypeCamera
//                                                      : UIImagePickerControllerSourceTypePhotoLibrary;
  UIImagePickerController *imagePicker = [UIImagePickerController new];
//  imagePicker.sourceType = desiredSourceType;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
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
