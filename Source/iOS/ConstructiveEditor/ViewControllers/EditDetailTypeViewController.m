//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailTypeViewController.h"
#import "Constants.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"
#import <QuartzCore/QuartzCore.h>

@interface EditDetailTypeViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@interface EditDetailTypeViewController (UIPickerViewDataSource) <UIPickerViewDataSource>
@end

@interface EditDetailTypeViewController (UIPickerViewDelegate) <UIPickerViewDelegate>
@end

@interface EditDetailTypeViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface EditDetailTypeViewController ()
  {
  __weak IBOutlet UITextField*        _detailLabelTextField;
  __weak IBOutlet UIStepper*          _detailLengthStepper;
  __weak IBOutlet UILabel*            _detailLengthLabel;
  
  __weak IBOutlet UIView*             _pictureImageViewContainer;
  __weak IBOutlet NSLayoutConstraint* _constraintViewContainerLeadingSpaceToSuperview;
  
  __weak IBOutlet UIPickerView*       _detailClassPicker;
  __weak IBOutlet NSLayoutConstraint* _constraintVerticalSpaceFromPickerToViewContainer;
  __weak IBOutlet NSLayoutConstraint* _constraintPickerTrainlingSpaceToSuperview;
  
  __weak IBOutlet UIImageView*        _pictureImageView;
  
  UIImageView*                        _rulerImageView;
  
  NSArray*                            _constraintsForPortraitOrientation;
  NSArray*                            _constraintsVerticalForLandscapeOrientation;
  NSArray*                            _constraintsHorizontalForLandscapeOrientation;
  NSArray*                            _detailClassesLabels;
  }
@end
  
@implementation EditDetailTypeViewController

@synthesize detailType = _detailType;

- (NSInteger)pickerRowByDetailClassIdentifier:(NSString*)classIdentifier
  {
  if ([detailClassCustomLabeled isEqualToString:_detailType.classIdentifier])
    return 0;
  //if ([detailClassOther isEqualToString:_detailType.classIdentifier])
    //return 1;
  if ([detailClassTechnicAxle isEqualToString:_detailType.classIdentifier])
    return 2;
  if ([detailClassTechnicLiftarm isEqualToString:_detailType.classIdentifier])
    return 3;
  if ([detailClassTechnicBrick isEqualToString:_detailType.classIdentifier])
    return 4;
  if ([detailClassTechnicGear isEqualToString:_detailType.classIdentifier])
    return 5;
  return 1;//detailClassOther
  }

- (NSString*)detailClassIdentifierByPickerRow:(NSInteger)pickerRow
  {
  switch (pickerRow)
    {
    case 0:
      return detailClassCustomLabeled;
    
    case 2:
      return detailClassTechnicAxle;
      
    case 3:
      return detailClassTechnicLiftarm;
      
    case 4:
      return detailClassTechnicBrick;
      
    case 5:
      return detailClassTechnicGear;
      
    default://1
      return detailClassOther;
    }
  }
    
- (void)viewDidLoad
  {
  [super viewDidLoad];
  _detailLabelTextField.text = _detailType.identifier;
  _detailLabelTextField.delegate = self;
  _pictureImageView.image = [_detailType pictureToShow]
                  ? [_detailType pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];
  _detailClassesLabels = [NSArray arrayWithObjects:
      NSLocalizedString(@"Custom, labeled", @"detail class"),
      NSLocalizedString(@"Other",  @"detail class"),
      NSLocalizedString(@"Technic Axle",  @"detail class"),
      NSLocalizedString(@"Technic Liftarm",  @"detail class"),
      NSLocalizedString(@"Technic Brick", @"detail class"),
      //Not implemented yet, is it really needed?
      //NSLocalizedString(@"Technic Gear" @"detail class"),
      nil];
  _detailClassPicker.dataSource = self;
  _detailClassPicker.delegate = self;
  
  NSInteger defaultRowToSelect = [self pickerRowByDetailClassIdentifier:_detailType.classIdentifier];
  [_detailClassPicker selectRow:defaultRowToSelect inComponent:0 animated:NO];
  [self pickerView:_detailClassPicker didSelectRow:defaultRowToSelect inComponent:0];
  
  //constraints initialization
  UIImageView* imageView = _pictureImageView;
  UIPickerView* picker = _detailClassPicker;
  _constraintsForPortraitOrientation = [NSArray arrayWithObjects:_constraintViewContainerLeadingSpaceToSuperview, _constraintPickerTrainlingSpaceToSuperview, _constraintVerticalSpaceFromPickerToViewContainer, nil];
  _constraintsHorizontalForLandscapeOrientation = [NSLayoutConstraint constraintsWithVisualFormat:@"[picker(==imageView)]-0-[imageView]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView, picker)];
  _constraintsVerticalForLandscapeOrientation = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[picker(==imageView)]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView, picker)];
  
  if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    [self updateConstraintsAccordingToInterfaceOrientation:self.interfaceOrientation];
  }

- (void)viewWillAppear:(BOOL)animated
  {
  //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  //Layout first!
  [self.view layoutIfNeeded];
  
  NSUInteger liftarmLengthInPins = 15;//maximum length of real liftarms
  UIImage* liftarmImage = [self liftarmImageOfLength:liftarmLengthInPins];
  
  _rulerImageView = [[UIImageView alloc] initWithImage:liftarmImage];
  _rulerImageView.autoresizingMask = UIViewAutoresizingNone;
  _rulerImageView.translatesAutoresizingMaskIntoConstraints = YES;//make autolayout to simulate the old behavior for this view
  _rulerImageView.userInteractionEnabled = NO;
  
  CGSize superviewSize = _pictureImageViewContainer.bounds.size;
  CGSize imageSize = liftarmImage.size;
  float xScale = superviewSize.width/imageSize.width;
  float yScale = superviewSize.height/imageSize.height;
  float minScale = xScale;
  if (minScale > yScale)
    minScale = yScale;
    
  _rulerImageView.center = CGPointMake(superviewSize.width/2, superviewSize.height/2);
  _rulerImageView.transform = CGAffineTransformScale(_rulerImageView.transform, minScale, minScale);
  _rulerImageView.alpha = 0.7;
  
  [_pictureImageViewContainer addSubview:_rulerImageView];
  }

- (UIImage*)liftarmImageOfLength:(NSUInteger)length
  {
  const NSUInteger countOfCentralSections = length<3 ? 1 :length - 2;
  
  const NSUInteger deltaYCentralFromBottomLeftImage = 58;
  const NSUInteger deltaYCentralFromOtherCentralImage = 58;
  const NSUInteger deltaYTopRightFromCentralImage = 37;
  
  UIImage* bottomLeftEndImage = [UIImage imageNamed:@"liftarm_bottom_left"];
  UIImage* centerImage = [UIImage imageNamed:@"liftarm_center"];
  UIImage* topRightEndImage = [UIImage imageNamed:@"liftarm_top_right"];
  
  CGFloat resultingWidth = bottomLeftEndImage.size.width + centerImage.size.width*countOfCentralSections + topRightEndImage.size.width;
  CGFloat resultingHeight = bottomLeftEndImage.size.height + deltaYCentralFromBottomLeftImage + deltaYCentralFromOtherCentralImage*(countOfCentralSections - 1) + deltaYTopRightFromCentralImage;

  // build the actual glued image

  UIGraphicsBeginImageContextWithOptions(CGSizeMake(resultingWidth, resultingHeight), NO, 1);
  [bottomLeftEndImage drawAtPoint:CGPointMake(0, resultingHeight - bottomLeftEndImage.size.height)];
  
  [centerImage drawAtPoint:CGPointMake(bottomLeftEndImage.size.width, resultingHeight - bottomLeftEndImage.size.height - deltaYCentralFromBottomLeftImage)];
  for (NSUInteger i = 1; i < countOfCentralSections; ++i)
    [centerImage drawAtPoint:CGPointMake(bottomLeftEndImage.size.width + centerImage.size.width*i, resultingHeight - bottomLeftEndImage.size.height - deltaYCentralFromBottomLeftImage - deltaYCentralFromOtherCentralImage*i)];
  [topRightEndImage drawAtPoint:CGPointMake(bottomLeftEndImage.size.width + centerImage.size.width*countOfCentralSections, resultingHeight - bottomLeftEndImage.size.height - deltaYCentralFromBottomLeftImage - deltaYCentralFromOtherCentralImage*(countOfCentralSections - 1) - deltaYTopRightFromCentralImage)];
  
  UIImage* resultingImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return resultingImage;
  }

- (void)viewWillDisappear:(BOOL)animated
  {
  if (!_detailLabelTextField.hidden)
    [self textFieldShouldReturn:_detailLabelTextField];
  }
  
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }
  
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
  {
  [self updateConstraintsAccordingToInterfaceOrientation:toInterfaceOrientation];
  }

- (void)updateConstraintsAccordingToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
  {
  if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
    [self.view removeConstraints:_constraintsForPortraitOrientation];
    [self.view addConstraints:_constraintsHorizontalForLandscapeOrientation];
    [self.view addConstraints:_constraintsVerticalForLandscapeOrientation];
    }
  else
    {
    [self.view removeConstraints:_constraintsHorizontalForLandscapeOrientation];
    [self.view removeConstraints:_constraintsVerticalForLandscapeOrientation];
    [self.view addConstraints:_constraintsForPortraitOrientation];
    }
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

- (IBAction)moveRuler:(UIPanGestureRecognizer *)gestureRecognizer
  {
  [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
  
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    UIView* view = gestureRecognizer.view;
    CGPoint translation = [gestureRecognizer translationInView:view];
    
    _rulerImageView.center = CGPointMake(_rulerImageView.center.x + translation.x, _rulerImageView.center.y + translation.y);
    [gestureRecognizer setTranslation:CGPointZero inView:view];
    }
  }

- (IBAction)zoomRuler:(UIPinchGestureRecognizer *)gestureRecognizer
  {
  [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    _rulerImageView.transform = CGAffineTransformScale(_rulerImageView.transform, gestureRecognizer.scale, gestureRecognizer.scale);
    gestureRecognizer.scale = 1;
    }
  }

- (IBAction)rotateRuler:(UIRotationGestureRecognizer *)gestureRecognizer
  {
  [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    _rulerImageView.transform = CGAffineTransformRotate(_rulerImageView.transform, gestureRecognizer.rotation);
    gestureRecognizer.rotation = 0;
    }
  }

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
  {
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    UIView* view = gestureRecognizer.view;
    CGPoint locationInView = [gestureRecognizer locationInView:_rulerImageView];
    CGPoint locationInSuperview = [gestureRecognizer locationInView:view];
    
    _rulerImageView.layer.anchorPoint = CGPointMake(locationInView.x / _rulerImageView.bounds.size.width, locationInView.y / _rulerImageView.bounds.size.height);

    _rulerImageView.center = locationInSuperview;
    }
  }

// ensure that the pinch, pan and rotate gesture recognizers on a particular view can all recognize simultaneously
// prevent other gesture recognizers from recognizing simultaneously
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
  {
  if (gestureRecognizer.view != _pictureImageViewContainer || otherGestureRecognizer.view != _pictureImageViewContainer)
    return NO;
  
  // if the gesture recognizers are on different views, don't allow simultaneous recognition
  if (gestureRecognizer.view != otherGestureRecognizer.view)
    return NO;
  
  // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
  if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    return NO;
  
  return YES;
  }

- (void)updateLengthControls
  {
  int length = _detailType.length.intValue;
  if (length < 2)
    {
    length = 2;
    _detailType.length = [NSNumber numberWithInt:length];
    [_detailType.managedObjectContext saveAndHandleError];
    }
  _detailLengthLabel.text = [NSString stringWithFormat:@"Length = %d", length];
  _detailLengthStepper.value = length;
  }
  
- (void)updateLabelConrol
  {
  _detailLabelTextField.text = _detailType.identifier;
  }
  
- (IBAction)detailLengthStepperValueChanged:(id)sender
  {
  _detailType.length = [NSNumber numberWithInt:(int)_detailLengthStepper.value];
  [_detailType.managedObjectContext saveAndHandleError];
  [self updateLengthControls];
  }
  
@end

@implementation EditDetailTypeViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {	
  //WORKS REALLY LONG TIME: check the photo picker example to see how we can speed it up
	_detailType.picture = selectedImage;
  // Commit the change.
	[_detailType.managedObjectContext saveAndHandleError];
  _pictureImageView.image = [_detailType pictureToShow]
                  ? [_detailType pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];

  [self dismissModalViewControllerAnimated:YES];
  }


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
  {
	[self dismissModalViewControllerAnimated:YES];
  }

@end

@implementation EditDetailTypeViewController (UIPickerViewDataSource)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
  {
  return 1;
  }
  
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
  {
  return _detailClassesLabels.count;
  }
  
@end

@implementation EditDetailTypeViewController (UIPickerViewDelegate)
  
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
  {
  return [_detailClassesLabels objectAtIndex:row];
  }
  
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
  {
  _detailType.classIdentifier = [self detailClassIdentifierByPickerRow:row];
  switch (row)
    {
    case 0://Custom, labeled
      _detailLabelTextField.hidden = NO;
      _detailLengthLabel.hidden = YES;
      _detailLengthStepper.hidden = YES;
      _detailType.length = nil;
      [self updateLabelConrol];
      break;
    case 2://Technic Axle
    case 3://Technic Liftarm
    case 4://Technic Brick
      _detailLabelTextField.hidden = YES;
      _detailLengthLabel.hidden = NO;
      _detailLengthStepper.hidden = NO;
      _detailType.identifier = nil;
      [self updateLengthControls];
      break;
//    case 5://Technic Gear
//      _detailLabelTextField.hidden = YES;
//      _detailLengthLabel.hidden = NO;
//      _detailLengthStepper.hidden = NO;
//      break;
    default://Other (1)
      _detailLabelTextField.hidden = YES;
      _detailLengthLabel.hidden = YES;
      _detailLengthStepper.hidden = YES;
      _detailType.identifier = nil;
      _detailType.length = nil;
      break;
    }
  [_detailType.managedObjectContext saveAndHandleError];
  }
  
@end

@implementation EditDetailTypeViewController (UITextFieldDelegate)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
  {
  [_detailLabelTextField resignFirstResponder];
  NSString* label = _detailLabelTextField.text;
  if (!label.length)
    label = nil;
  _detailType.identifier = label;
  [_detailType.managedObjectContext saveAndHandleError];
  return YES;
  }

@end