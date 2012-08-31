//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditAssemblyViewController.h"
#import "Assembly.h"
#import "NSManagedObjectContextExtension.h"

@interface EditAssemblyViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation EditAssemblyViewController

@synthesize assembly = _assembly;

- (void)viewDidLoad
  {
  [super viewDidLoad];
  imageView.image = _assembly.picture;
  }

- (void)viewDidUnload
  {
  imageView = nil;
  [super viewDidUnload];
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
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

@implementation EditAssemblyViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
	_assembly.picture = selectedImage;
  // Commit the change.
	[_assembly.managedObjectContext saveAndHandleError];
  imageView.image = _assembly.picture;

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
