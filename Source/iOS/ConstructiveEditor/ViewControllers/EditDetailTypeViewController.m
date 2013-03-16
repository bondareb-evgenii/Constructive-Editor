//
//  ViewController.m
//  ConstructiveEditor


#import "EditDetailTypeViewController.h"
#import "EditDetailTypeAdditionalInfoViewController.h"
#import "Constants.h"
#import "DetailType.h"
#import "ImageVisualFrameCalculator.h"
#import "NSManagedObjectContextExtension.h"
#import "Picture.h"
#import "PreferencesKeys.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger LiftarmLengthInPins = 15;//maximum length of real liftarms
static const float RulerImageLengthInPins = 14.8854449406065;//manually calculated value for the generated image of ruler of length 15

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
  __weak IBOutlet UIView*             _pictureImageViewContainer;
  __weak IBOutlet UIImageView*        _pictureImageView;
  __weak IBOutlet UILabel*            _additionalInfoLabel;
  UIImageView*                        _rulerImageView;
  UIImage*                            _rulerImage;
  ImageVisualFrameCalculator*         _pictureImageVisualFrameCalculator;
  CGRect                              _pictureImageVisualFrameBeforeRotation;
  CGRect                              _pictureImageViewRealFrameBeforeRotation;
  }
@end
  
@implementation EditDetailTypeViewController

@synthesize detailType = _detailType;

- (NSInteger)pickerRowByDetailClassIdentifier:(NSString*)classIdentifier
  {
  if ([detailClassCustomLabeled isEqualToString:classIdentifier])
    return 0;
  //if ([detailClassOther isEqualToString:classIdentifier])
    //return 1;
  if ([detailClassTechnicAxle isEqualToString:classIdentifier])
    return 2;
  if ([detailClassTechnicLiftarm isEqualToString:classIdentifier])
    return 3;
  if ([detailClassTechnicBrick isEqualToString:classIdentifier])
    return 4;
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
      
    default://1
      return detailClassOther;
    }
  }
    
- (void)viewDidLoad
  {
  _rulerImage = [self liftarmImageOfLength:LiftarmLengthInPins];
  _pictureImageVisualFrameCalculator = [[ImageVisualFrameCalculator alloc] initWithImageView:_pictureImageView];
  [super viewDidLoad];
  UIImage* picture = _detailType.pictureToShow;
  _pictureImageView.image = picture ? picture : [UIImage imageNamed:@"NoPhotoBig.png"];
  }

- (void)viewWillAppear:(BOOL)animated
  {
  [self.view layoutIfNeeded];//Layout first to use the views frames for calculations
  _additionalInfoLabel.text = [self additionalInfoString];
  [self showRuler];
  }

- (void)showRuler
  {
  if (_rulerImageView || !_detailType.pictureToShow)
    return;
  
  _rulerImageView = [[UIImageView alloc] initWithImage:_rulerImage];
  _rulerImageView.autoresizingMask = UIViewAutoresizingNone;
  _rulerImageView.translatesAutoresizingMaskIntoConstraints = YES;//make autolayout to simulate the old behavior for this view
  _rulerImageView.userInteractionEnabled = NO;
  _rulerImageView.layer.anchorPoint = self.initialRulerImageViewAnchorPoint;
  _rulerImageView.center = self.initialRulerImageViewCenter;
  _rulerImageView.transform = self.initialRulerImageViewTransform;
  _rulerImageView.alpha = 0.7;
  
  [_pictureImageViewContainer addSubview:_rulerImageView];
  }

- (CGPoint)initialRulerImageViewAnchorPoint
  {
  if (_detailType.rulerImageAnchorPointX && _detailType.rulerImageAnchorPointY)
    return CGPointMake(_detailType.rulerImageAnchorPointX.floatValue, _detailType.rulerImageAnchorPointY.floatValue);
  else
    return CGPointMake(0.5, 0.5);
  }

- (CGPoint)initialRulerImageViewCenter
  {
  CGSize superviewSize = _pictureImageViewContainer.bounds.size;
  if (_detailType.rulerImageOffsetX && _detailType.rulerImageOffsetY)
    return CGPointMake(_detailType.rulerImageOffsetX.floatValue, _detailType.rulerImageOffsetY.floatValue);
  else
    return CGPointMake(superviewSize.width/2, superviewSize.height/2);
  }

- (CGAffineTransform) initialRulerImageViewTransform
  {
  CGAffineTransform transform = CGAffineTransformIdentity;
  //apply saved transformations of a ruler if it is present in a document, or calculate it so that the ruler fits detail picture
  if (_detailType.pictureWidthInPins && _detailType.rulerImageRotationAngle)
    {
    [self.view layoutIfNeeded];//Layout first to use the views frames for calculations
    float rulerImageZoomFactor = RulerImageLengthInPins*_pictureImageVisualFrameCalculator.imageVisualFrameInViewCoordinates.size.width/_rulerImage.size.width/_detailType.pictureWidthInPins.floatValue;
    //transform = CGAffineTransformTranslate(transform, _detailType.rulerImageOffsetX.floatValue, _detailType.rulerImageOffsetY.floatValue);
    transform = CGAffineTransformRotate(transform, _detailType.rulerImageRotationAngle.floatValue);
    transform = CGAffineTransformScale(transform, rulerImageZoomFactor, rulerImageZoomFactor);
    }
  else
    {
    CGSize superviewSize = _pictureImageViewContainer.bounds.size;
    CGSize imageSize = _rulerImage.size;
    float xScale = superviewSize.width/imageSize.width;
    float yScale = superviewSize.height/imageSize.height;
    float minScale = xScale;
    if (minScale > yScale)
      minScale = yScale;
    transform = CGAffineTransformScale(transform, minScale, minScale);
    }
  return transform;
  }

- (NSString*)additionalInfoString
  {
  if ([detailClassCustomLabeled isEqualToString:_detailType.classIdentifier])
    {
    NSString* formatString = NSLocalizedString(@"Custom detail with label: %@", @"detail type additional info");
    NSString* label = _detailType.identifier;
    if (!label)
      label = NSLocalizedString(@"(Not specified)", @"detail type additional info");
    return [NSString stringWithFormat:formatString, label];
    }
  //if ([detailClassOther isEqualToString:_detailType.classIdentifier])
    //return  NSLocalizedString(@"No additional information", @"detail type additional info");
    
  int length = _detailType.length.intValue;
  if (length < 2)
    {
    length = 2;
    _detailType.length = [NSNumber numberWithInt:length];
    [_detailType.managedObjectContext saveAsyncAndHandleError];
    }
    
  if ([detailClassTechnicAxle isEqualToString:_detailType.classIdentifier])
    {
    NSString* formatString = NSLocalizedString(@"Lego Technic Axle of length: %d", @"detail type additional info");
    return [NSString stringWithFormat:formatString, length];
    }
  if ([detailClassTechnicLiftarm isEqualToString:_detailType.classIdentifier])
    {
    NSString* formatString = NSLocalizedString(@"Lego Technic Liftarm of length: %d", @"detail type additional info");
    return [NSString stringWithFormat:formatString, length];
    }
  if ([detailClassTechnicBrick isEqualToString:_detailType.classIdentifier])
    {
    NSString* formatString = NSLocalizedString(@"Lego Technic Brick of length: %d", @"detail type additional info");
    return [NSString stringWithFormat:formatString, length];
    }

  return  NSLocalizedString(@"No additional information", @"detail type additional info");//detailClassOther
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if ([@"EditAdditionalInfo" isEqualToString:segue.identifier])
    ((EditDetailTypeAdditionalInfoViewController*)segue.destinationViewController).detailType = self.detailType;
  }
  
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
  {
  //populate the cache with current image frame
  _pictureImageVisualFrameBeforeRotation = _pictureImageVisualFrameCalculator.imageVisualFrameInViewCoordinates;
  //Don't call this method again in between the willRotateToInterfaceOrientation and didRotateFromInterfaceOrientation!!!
  
  _pictureImageViewRealFrameBeforeRotation = _pictureImageView.frame;
  }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  //Take a value calculated and cached in willRotateToInterfaceOrientation
  CGRect pictureImageVisualFrameAfterRotation = _pictureImageVisualFrameCalculator.imageVisualFrameInViewCoordinates;
  
  //calculate multiplier for the new zoom factor of a ruler
  float zoomFactorX = pictureImageVisualFrameAfterRotation.size.width/_pictureImageVisualFrameBeforeRotation.size.width;
  float zoomFactorY = pictureImageVisualFrameAfterRotation.size.height/_pictureImageVisualFrameBeforeRotation.size.height;
  assert(fabs(zoomFactorX-zoomFactorY) < 0.00001);
  float zoomFactor = zoomFactorX;
  
  //calculate new center of a ruler
  CGPoint rullerCenterInImageCoordinates = CGPointMake((_rulerImageView.center.x - _pictureImageVisualFrameBeforeRotation.origin.x)*zoomFactor, (_rulerImageView.center.y - _pictureImageVisualFrameBeforeRotation.origin.y)*zoomFactor);
  CGPoint newRulerCenter = CGPointMake(rullerCenterInImageCoordinates.x + pictureImageVisualFrameAfterRotation.origin.x, rullerCenterInImageCoordinates.y + pictureImageVisualFrameAfterRotation.origin.y);
  
  _rulerImageView.center = newRulerCenter;
  _rulerImageView.transform = CGAffineTransformScale(_rulerImageView.transform, zoomFactor, zoomFactor);
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
  else if (gestureRecognizer.state != UIGestureRecognizerStatePossible)//ended, cancelled, failed or recognized states
    {
    [self updateDetailTypesZoomFactorAndRulerTransform];
    [self.detailType.managedObjectContext saveAsyncAndHandleError];
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
  else if (gestureRecognizer.state != UIGestureRecognizerStatePossible)//ended, cancelled, failed or recognized states
    {
    [self updateDetailTypesZoomFactorAndRulerTransform];
    [self.detailType.managedObjectContext saveAsyncAndHandleError];
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
  else if (gestureRecognizer.state != UIGestureRecognizerStatePossible)//ended, cancelled, failed or recognized states
    {
    [self updateDetailTypesZoomFactorAndRulerTransform];
    [self.detailType.managedObjectContext saveAsyncAndHandleError];
    }
  }

- (void)updateDetailTypesZoomFactorAndRulerTransform
  {
  CGAffineTransform transform = _rulerImageView.transform;
  
  //Get a zoom factor, rotation and displacement from the ruler view transformation matrix, see explanations here: http://math.stackexchange.com/questions/13150/extracting-rotation-scale-values-from-2d-transformation-matrix
  float rulerImageZoomFactor = sqrtf(transform.a*transform.a + transform.b*transform.b);
  float rulerImageRotationAngle = acosf(transform.a/rulerImageZoomFactor);//[0, Pi]
  if (transform.b < 0)
    rulerImageRotationAngle = M_PI*2 - rulerImageRotationAngle;
  
  float pictureWidthInPins = RulerImageLengthInPins*_pictureImageVisualFrameCalculator.imageVisualFrameInViewCoordinates.size.width/_rulerImage.size.width/rulerImageZoomFactor;
  
  self.detailType.pictureWidthInPins = [NSNumber numberWithFloat:pictureWidthInPins];
  self.detailType.rulerImageRotationAngle = [NSNumber numberWithFloat:rulerImageRotationAngle];
  self.detailType.rulerImageOffsetX = [NSNumber numberWithFloat:_rulerImageView.center.x];
  self.detailType.rulerImageOffsetY = [NSNumber numberWithFloat:_rulerImageView.center.y];
  self.detailType.rulerImageAnchorPointX = [NSNumber numberWithFloat:_rulerImageView.layer.anchorPoint.x];
  self.detailType.rulerImageAnchorPointY = [NSNumber numberWithFloat:_rulerImageView.layer.anchorPoint.y];
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
  
@end

@implementation EditDetailTypeViewController (UIImagePickerControllerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo
  {
  if (nil == _detailType.picture)
    {
    Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:_detailType.managedObjectContext];
    _detailType.picture = picture;
    }
  if (nil == _detailType.pictureThumbnail60x60AspectFit)
    {
    Picture* picture = (Picture*)[NSEntityDescription insertNewObjectForEntityForName:@"Picture" inManagedObjectContext:_detailType.managedObjectContext];
    _detailType.pictureThumbnail60x60AspectFit = picture;
    }
	_detailType.picture.image = selectedImage;
  _detailType.pictureThumbnail60x60AspectFit.image = [selectedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(60, 60) interpolationQuality:kCGInterpolationHigh];;
  // Commit the change.
	[_detailType.managedObjectContext saveAsyncAndHandleError];
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
