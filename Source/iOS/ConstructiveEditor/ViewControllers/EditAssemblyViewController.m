//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditAssemblyViewController.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@interface EditAssemblyViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@interface EditAssemblyViewController ()
  {
  CGPoint                             _pinPointRelativeToParentImageSize;
  __weak IBOutlet UIImageView*        _imageView;
  __weak IBOutlet UIView*             _containerViewForParentImageView;
  __weak IBOutlet UIImageView*        _imageViewParent;
  __weak IBOutlet UIView*             _viewAspectFit;
  __weak IBOutlet NSLayoutConstraint* _constraintViewAspectFitWidth;
  __weak IBOutlet NSLayoutConstraint* _constraintViewAspectFitHeight;
  __weak IBOutlet UIImageView*        _viewPin;
  __weak IBOutlet NSLayoutConstraint* _constraintViewPinX;
  __weak IBOutlet NSLayoutConstraint* _constraintViewPinY;
    IBOutlet UITapGestureRecognizer*  _tapOnParentImageGestureRecognizer;
  __weak IBOutlet UIButton*           _doneButton;
  __weak IBOutlet UIStepper*          _countStepper;
  __weak IBOutlet UILabel*            _countLabel;
  }

@end

@implementation EditAssemblyViewController

@synthesize assemblies = _assemblies;

- (Assembly*)assembly
  {
  return (Assembly*)[self.assemblies lastObject];
  }
  
- (void)updateConstraints
  {
  float containerWidth = _containerViewForParentImageView.bounds.size.width;
  float containerHeight = _containerViewForParentImageView.bounds.size.height;
  float containerWidthToHeightProportion = containerWidth/containerHeight;
  UIImage* parentPicture = [[self.assembly assemblyToInstallTo] pictureToShow];
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
  _imageView.image = [self.assembly.type pictureToShow]
                   ? [self.assembly.type pictureToShow]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];
  UIImage* parentPicture = [self.assembly.assemblyToInstallTo pictureToShow];
  _imageViewParent.image = parentPicture
                         ? parentPicture
                         : [UIImage imageNamed:@"NoPhotoBig.png"];
  _countLabel.text = [NSString stringWithFormat:@"%d", _assemblies.count];
  _countStepper.value = _assemblies.count;
                        
  _viewPin.alpha = 0;
  _pinPointRelativeToParentImageSize = nil!= self.assembly.connectionPoint
                                     ? [self.assembly.connectionPoint CGPointValue]
                                     : CGPointZero;
  _tapOnParentImageGestureRecognizer.enabled = nil != parentPicture;
  }

- (void)updateDoneButton
  {
  BOOL arePointsSetForAllTheAssemblies = YES;
  for (Assembly* assembly in _assemblies)
    if (!assembly.connectionPoint)
      {
      arePointsSetForAllTheAssemblies = NO;
      break;
      }
  _doneButton.enabled = arePointsSetForAllTheAssemblies;
  }
  
- (void)viewWillAppear:(BOOL)animated
  {
  [self updateDoneButton];
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

- (IBAction)onImagePressed:(id)sender
  {
  [self selectPhoto];
  }
  
- (IBAction)onDoneButtonPressed:(id)sender
  {
  [self.navigationController popViewControllerAnimated:YES];
  }
    
- (IBAction)onTapOnImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  [self selectPhoto];
  }
  
- (void)movePinToPoint:(CGPoint)position
  {
  _pinPointRelativeToParentImageSize = CGPointMake(position.x/_viewAspectFit.bounds.size.width, (_viewAspectFit.bounds.size.height-position.y)/_viewAspectFit.bounds.size.height);
  self.assembly.connectionPoint = [NSValue valueWithCGPoint:_pinPointRelativeToParentImageSize];
  [self updateConstraints];
  [_viewAspectFit layoutIfNeeded];
  [self showPinAnimated:NO];
  }
  
- (IBAction)onTapOnParentImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
  [self movePinToPoint:position];
  [self.assembly.managedObjectContext saveAndHandleError];
  [self updateDoneButton];
  }
  
- (IBAction)onDragOnParentImage:(UIPanGestureRecognizer*)gestureRecognizer
  {
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
      gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
    [self movePinToPoint:position];
    }
  else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
    [self.assembly.managedObjectContext saveAndHandleError];
    [self updateDoneButton];
    }
  }
  
- (IBAction)onCountChanged:(id)sender
  {
  NSInteger newCount = _countStepper.value;
  NSInteger oldCount = _assemblies.count;
  NSInteger deltaCount = newCount - oldCount;
  _countLabel.text = [NSString stringWithFormat:@"%d", newCount];
  Assembly* lastAssembly = self.assembly;
  if (deltaCount >= 0)
    {
    NSMutableArray* assembliesToAdd = [[NSMutableArray alloc] initWithCapacity:deltaCount];
    AssemblyType* type = lastAssembly.type;
    for (int i = 0; i < deltaCount; ++i)
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:self.assembly.managedObjectContext];
      assembly.type = type;
      assembly.assemblyToInstallTo = lastAssembly.assemblyToInstallTo;
      [assembliesToAdd addObject:assembly];
      }
    [_assemblies addObjectsFromArray:assembliesToAdd];
    }
  else
    {
    deltaCount = abs(deltaCount);
    NSRange range = NSMakeRange(_assemblies.count - deltaCount, deltaCount);
    NSArray* assembliesToRemove = [_assemblies subarrayWithRange:range];
    [_assemblies removeObjectsInRange:range];
    for (Assembly* assembly in assembliesToRemove)
      [lastAssembly.managedObjectContext deleteObject:assembly];
    }
  [lastAssembly.managedObjectContext saveAndHandleError];
  [self updateDoneButton];
  }
  
@end

@implementation EditAssemblyViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
	self.assembly.type.picture = selectedImage;
  // Commit the change.
  [self.assembly.managedObjectContext saveAndHandleError];
	_imageView.image = [self.assembly.type pictureToShow]
                   ? [self.assembly.type pictureToShow]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end
