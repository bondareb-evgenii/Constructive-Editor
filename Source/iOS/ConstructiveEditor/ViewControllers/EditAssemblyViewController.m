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

@interface EditAssemblyViewController ()
  {
  CGPoint _pinPointRelativeToParentImageSize;
  __weak IBOutlet UIImageView *_imageView;
  __weak IBOutlet UIView *_containerViewForParentImageView;
  __weak IBOutlet UIImageView *_imageViewParent;
  __weak IBOutlet UILabel *_labelInstalledTo;
  __weak IBOutlet UIView *_viewAspectFit;
  __weak IBOutlet NSLayoutConstraint *_constraintViewAspectFitWidth;
  __weak IBOutlet NSLayoutConstraint *_constraintViewAspectFitHeight;
  __weak IBOutlet UIImageView *_viewPin;
  __weak IBOutlet NSLayoutConstraint *_constraintViewPinX;
  __weak IBOutlet NSLayoutConstraint *_constraintViewPinY;
    IBOutlet UITapGestureRecognizer *_tapOnParentImageGestureRecognizer;
  }

@end

@implementation EditAssemblyViewController

@synthesize assembly = _assembly;

- (void)updateConstraints
  {
  float containerWidth = _containerViewForParentImageView.bounds.size.width;
  float containerHeight = _containerViewForParentImageView.bounds.size.height;
  float containerWidthToHeightProportion = containerWidth/containerHeight;
  UIImage* parentPicture = [self.assembly.assemblyToInstallTo pictureToShow];
  float widthToHeightProportionOfParentImage = nil != parentPicture
                                             ? parentPicture.size.width/parentPicture.size.height
                                             : 1;//just a value bigger then 0
  float updatedViewAspectFitWidth;
  float updatedViewAspectFitHeight;
  if (containerWidthToHeightProportion > widthToHeightProportionOfParentImage)//allign by height
    {
    updatedViewAspectFitWidth = containerHeight*widthToHeightProportionOfParentImage;
    updatedViewAspectFitHeight = containerHeight;
    }
  else//allign by width
    {
    updatedViewAspectFitWidth = containerWidth;
    updatedViewAspectFitHeight = containerWidth/widthToHeightProportionOfParentImage;
    }
  _constraintViewAspectFitWidth.constant = updatedViewAspectFitWidth;
  _constraintViewAspectFitHeight.constant = updatedViewAspectFitHeight;
  _constraintViewPinX.constant = updatedViewAspectFitWidth*_pinPointRelativeToParentImageSize.x;
  _constraintViewPinY.constant = updatedViewAspectFitHeight*_pinPointRelativeToParentImageSize.y;
  }
  
- (void)hidePin
  {
  [UIView animateWithDuration:0.2 animations:^
    {
    _viewPin.alpha = 0;
    }];
  }

- (void)showPinAnimated:(BOOL)animated
  {
  if (![self.assembly.assemblyToInstallTo pictureToShow])
    return;
  if (animated)
    {[UIView animateWithDuration:0.3 animations:^
      {
      _viewPin.alpha = 1;
      }];
    }
  else
    _viewPin.alpha = 1;
  }
  
- (void)viewDidLoad
  {
  [super viewDidLoad];
  _imageView.image = [_assembly pictureToShow]
                   ? [_assembly pictureToShow]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];
  UIImage* parentPicture = [self.assembly.assemblyToInstallTo pictureToShow];
  
  BOOL isSmallerPart = nil != self.assembly.assemblyToInstallTo;
  BOOL shouldShowParentImage = isSmallerPart;
  
  if (!shouldShowParentImage)
    {
    [_containerViewForParentImageView removeFromSuperview];
    [_labelInstalledTo removeFromSuperview];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_imageView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_imageView)]];
    }
  
  _imageViewParent.image = parentPicture
                         ? parentPicture
                         : [UIImage imageNamed:@"NoPhotoBig.png"];
                        
  _viewPin.alpha = 0;
  _pinPointRelativeToParentImageSize = nil!= self.assembly.connectionPoint
                                     ? [self.assembly.connectionPoint CGPointValue]
                                     : CGPointZero;
  _tapOnParentImageGestureRecognizer.enabled = nil != parentPicture;
  }

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }
  
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
  {
  [self hidePin];
  }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  [self updateConstraints];
  [self.view layoutIfNeeded];
  [self showPinAnimated:YES];
  }
  
- (void)viewDidAppear:(BOOL)animated
  {
  [self updateConstraints];
  [self.view layoutIfNeeded];
  [self showPinAnimated:YES];
  }
  
- (void)selectPhoto
  {
//  UIImagePickerControllerSourceType desiredSourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
//                                                      ? UIImagePickerControllerSourceTypeCamera
//                                                      : UIImagePickerControllerSourceTypePhotoLibrary;
  UIImagePickerController *imagePicker = [UIImagePickerController new];
//  imagePicker.sourceType = desiredSourceType;
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
  }
  
- (IBAction)onTapOnImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  [self selectPhoto];
  }
  
- (IBAction)onTapOnParentImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
  _pinPointRelativeToParentImageSize = CGPointMake(position.x/_viewAspectFit.bounds.size.width, (_viewAspectFit.bounds.size.height-position.y)/_viewAspectFit.bounds.size.height);
  self.assembly.connectionPoint = [NSValue valueWithCGPoint:_pinPointRelativeToParentImageSize];
  [self.assembly.managedObjectContext saveAndHandleError];
  [self updateConstraints];
  [self.view layoutIfNeeded];
  [self showPinAnimated:NO];
  }
  
@end

@implementation EditAssemblyViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
	_assembly.picture = selectedImage;
  // Commit the change.
	_imageView.image = [_assembly pictureToShow]
                   ? [_assembly pictureToShow]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
