//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailTypeViewController.h"
#import "EditDetailTypeAdditionalInfoViewController.h"
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
  __weak IBOutlet UIView*             _pictureImageViewContainer;
  __weak IBOutlet UIImageView*        _pictureImageView;
  __weak IBOutlet UILabel*            _additionalInfoLabel;
  UIImageView*                        _rulerImageView;
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
  [super viewDidLoad];
  _pictureImageView.image = [_detailType pictureToShow]
                  ? [_detailType pictureToShow]
                  : [UIImage imageNamed:@"NoPhotoBig.png"];
  }

- (void)viewWillAppear:(BOOL)animated
  {
  [self.view layoutIfNeeded];//Layout first to use the views frames for calculations
  _additionalInfoLabel.text = [self additionalInfoString];
  [self showRuler];
  }

- (void)showRuler
  {
  if (_rulerImageView)
    return;
    
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
    [_detailType.managedObjectContext saveAndHandleError];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
  {
  return YES;
  }
  
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
  {
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
