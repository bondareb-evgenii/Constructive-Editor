//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailTypeViewController.h"
#import "Assembly.h"
#import "NSManagedObjectContextExtension.h"

@interface EditDetailTypeViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation EditDetailTypeViewController

@synthesize assembly = _assembly;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  imageView.image = [_assembly pictureToShow]
                  ? [_assembly pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }

- (IBAction)goBack:(id)sender
  {
  [_assembly.managedObjectContext saveAndHandleError];
  [self dismissModalViewControllerAnimated:YES];
  }
  
- (IBAction)addPhoto:(id)sender
  {
//  UIImagePickerControllerSourceType desiredSourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
//                                                      ? UIImagePickerControllerSourceTypeCamera
//                                                      : UIImagePickerControllerSourceTypePhotoLibrary;
  UIImagePickerController *imagePicker = [UIImagePickerController new];
//  imagePicker.sourceType = desiredSourceType;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
  }
  
@end

@implementation EditDetailTypeViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
	_assembly.picture = selectedImage;
  // Commit the change.
	[_assembly.managedObjectContext saveAndHandleError];
  imageView.image = [_assembly pictureToShow]
                  ? [_assembly pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
