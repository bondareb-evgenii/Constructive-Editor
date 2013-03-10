//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailViewController.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "Detail.h"
#import "DetailType.h"
#import "AssembliesAndDetailsViewController.h"
#import "EditDetailTypeViewController.h"
#import "DetailTypesViewController.h"
#import "ImageVisualFrameCalculator.h"
#import "NSManagedObjectContextExtension.h"
#import "VisualSelectablePointer.h"

@interface EditDetailViewController ()
  {
  NSInteger                           _selectedPointIndex;
  CGPoint                             _deltaFromDraggingPointToThePinTargetPoint;
  VisualSelectablePointer*            _pinMetaInfo;
  NSMutableArray*                     _pins;
  NSMutableArray*                     _pinsHorizontalConstraints;
  NSMutableArray*                     _pinsVerticalConstraints;
  UIImage*                            _pinImage;
  UIImage*                            _selectedPinImage;
  ImageVisualFrameCalculator*         _parentImageVisualFrameCalculator;
  __weak IBOutlet UIImageView*        _imageView;
  __weak IBOutlet UIImageView*        _imageViewParent;
    IBOutlet UITapGestureRecognizer*  _tapOnParentImageGestureRecognizer;
    IBOutlet UIPanGestureRecognizer *_dragOnParentImageGestureRecognizer;
  __weak IBOutlet UIButton*           _doneButton;
  __weak IBOutlet UIStepper*          _countStepper;
  __weak IBOutlet UILabel*            _countLabel;
  }

@end

@implementation EditDetailViewController

@synthesize details = _details;

- (Detail*)detail
  {
  return (Detail*)[_details lastObject];
  }

- (void)updatePins
  {
  while (_pins.count < _details.count)
    {
    UIImageView* pin = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _pinImage.size.width, _pinImage.size.width)];
    pin.translatesAutoresizingMaskIntoConstraints = NO;
    [_imageViewParent addSubview:pin];
    [_pins addObject:pin];
    NSArray* pinHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[pin]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pin)];
    [_imageViewParent addConstraints:pinHorizontalConstraints];
    NSArray* pinVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pin]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pin)];
    [_pinsHorizontalConstraints addObjectsFromArray:pinHorizontalConstraints];
    [_imageViewParent addConstraints:pinVerticalConstraints];
    [_pinsVerticalConstraints addObjectsFromArray:pinVerticalConstraints];
    }
  
  while (_pins.count > _details.count)
    {
    [[_pins lastObject] removeFromSuperview];
    [_pins removeLastObject];
    [_pinsHorizontalConstraints removeLastObject];
    [_pinsVerticalConstraints removeLastObject];
    }
    
  CGRect imageVisualFrame = [_parentImageVisualFrameCalculator imageVisualFrameInViewCoordinates];
  for (int i = 0; i < _details.count; ++i)
    {
    NSValue* connectionPointValue = [[self.details objectAtIndex:i] connectionPoint];
    CGPoint pinPointRelativeToParentImageSize = nil!= connectionPointValue
                                              ? [connectionPointValue CGPointValue]
                                              : CGPointZero;
    CGPoint topLeftPinViewCorner = [_pinMetaInfo topLeftImageCornerPointForTargetPoint:CGPointMake(imageVisualFrame.origin.x + imageVisualFrame.size.width*pinPointRelativeToParentImageSize.x, imageVisualFrame.origin.y + imageVisualFrame.size.height - imageVisualFrame.size.height*pinPointRelativeToParentImageSize.y)];
    ((NSLayoutConstraint*)[_pinsHorizontalConstraints objectAtIndex:i]).constant =  topLeftPinViewCorner.x;
    ((NSLayoutConstraint*)[_pinsVerticalConstraints objectAtIndex:i]).constant = topLeftPinViewCorner.y;
    
    if (i == _selectedPointIndex)
      [[_pins objectAtIndex:i] setImage:_selectedPinImage];
    else
      [[_pins objectAtIndex:i] setImage:_pinImage];
    }
  [_imageViewParent bringSubviewToFront:[_pins objectAtIndex:_selectedPointIndex]];
  [self.view layoutIfNeeded];
  }
  
- (void)hidePin
  {
  [UIView animateWithDuration:0.2 animations:^
    {
    for (UIView* pin in _pins)
      pin.alpha = 0;
    }];
  }

- (void)showPinAnimated:(BOOL)animated
  {
  if (![self.detail.assemblyToInstallTo pictureToShow])
    return;
  if (animated)
    {
    [UIView animateWithDuration:0.3 animations:^
      {
      for (UIView* pin in _pins)
        pin.alpha = 1;
      }];
    }
  else
    for (UIView* pin in _pins)
      pin.alpha = 1;
  }
  
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
  {
  [self hidePin];
  }

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
  {
  [self updatePins];
  [self showPinAnimated:YES];
  }
  
- (void)updateDoneButton
  {
  BOOL arePointsSetForAllTheDetails = YES;
  for (Detail* detail in _details)
    if (!detail.connectionPoint)
      {
      arePointsSetForAllTheDetails = NO;
      break;
      }
  _doneButton.enabled = arePointsSetForAllTheDetails;
  }

- (void)viewDidLoad
  {
  [super viewDidLoad];
  
  _parentImageVisualFrameCalculator = [[ImageVisualFrameCalculator alloc] initWithImageView:_imageViewParent];
  _selectedPointIndex = _details.count-1;
  [self correctSelectedPointIndex];
  _pinImage = [UIImage imageNamed:@"pin.png"];
  _selectedPinImage = [UIImage imageNamed:@"pinSelected.png"];
  
  _pinMetaInfo = [[VisualSelectablePointer alloc] initWithSelectionCenter:CGPointMake(15, 10) selectionRadius:30 andTargetPoint:CGPointMake(0, 45)];
  _pins = [[NSMutableArray alloc] initWithCapacity:1];
  _pinsHorizontalConstraints = [[NSMutableArray alloc] initWithCapacity:1];
  _pinsVerticalConstraints = [[NSMutableArray alloc] initWithCapacity:1];
  }
  
- (void)viewWillAppear:(BOOL)animated
  {
  //moved to here from viewDidLoad because detail type updates when go back from DetailTypesViewController
  _imageView.image = [self.detail.type
                     pictureToShowThumbnail60x60AspectFit]
                   ? [self.detail.type pictureToShowThumbnail60x60AspectFit]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];
                   
  UIImage* parentPicture = [self.detail.assemblyToInstallTo pictureToShow];
  _imageViewParent.image = parentPicture
                         ? parentPicture
                         : [UIImage imageNamed:@"NoPhotoBig.png"];
                        
  _countLabel.text = [NSString stringWithFormat:@"%d", _details.count];
  _countStepper.value = _details.count;
  
  [self updatePins];
  for (UIView* pin in _pins)
    pin.alpha = 0;
  
  _tapOnParentImageGestureRecognizer.enabled = nil != parentPicture;
  _dragOnParentImageGestureRecognizer.enabled = nil != parentPicture;
  [self updateDoneButton];
  }
  
- (void)viewDidAppear:(BOOL)animated
  {
  [self updatePins];
  [self showPinAnimated:YES];
  }

- (void)movePinToPoint:(CGPoint)position
  {
  CGRect imageVisualFrame = [_parentImageVisualFrameCalculator imageVisualFrameInViewCoordinates];
  CGPoint pinPointRelativeToParentImageSize = CGPointMake((position.x+_deltaFromDraggingPointToThePinTargetPoint.x)/imageVisualFrame.size.width, (imageVisualFrame.size.height-(position.y+_deltaFromDraggingPointToThePinTargetPoint.y))/imageVisualFrame.size.height);
  [(Detail*)[self.details objectAtIndex:_selectedPointIndex] setConnectionPoint:[NSValue valueWithCGPoint:pinPointRelativeToParentImageSize]];
  [self updatePins];
  [self showPinAnimated:NO];
  }

- (BOOL)tryToSelectPinAtPoint:(CGPoint)point
  {
  return [self tryToSelectPinAtPoint:point andGetDeltaFromItToPinTargetPoint:nil];
  }

- (BOOL)tryToSelectPinAtPoint:(CGPoint)point andGetDeltaFromItToPinTargetPoint:(CGPoint*)delta
  {
  CGRect imageVisualFrame = [_parentImageVisualFrameCalculator imageVisualFrameInViewCoordinates];
  for (int i = 0; i < _details.count; ++i)
    {
    Detail* detail = [_details objectAtIndex:i];
    CGPoint connectionPointRelativeToImageSize = [detail.connectionPoint CGPointValue];
    CGPoint targetPoint = CGPointMake(imageVisualFrame.size.width*connectionPointRelativeToImageSize.x, imageVisualFrame.size.height - imageVisualFrame.size.height*connectionPointRelativeToImageSize.y);
    if ([_pinMetaInfo shouldSelectPointerPointingTo:targetPoint byPoint:point])
      {
      if (delta)
        {
        delta->x = targetPoint.x - point.x;
        delta->y = targetPoint.y - point.y;
        }
      _selectedPointIndex = i;
      [self updatePins];
      return YES;
      }
    }
  return NO;
  }

- (IBAction)onTapOnParentImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  CGRect imageVisualFrame = [_parentImageVisualFrameCalculator imageVisualFrameInViewCoordinates];
  CGPoint position = [gestureRecognizer locationInView:_imageViewParent];
  position.x += imageVisualFrame.origin.x;
  position.y -= imageVisualFrame.origin.y;
  
  if ([self tryToSelectPinAtPoint:position])
    return;
  [self movePinToPoint:position];
  [self correctSelectedPinPosition];
  [self.detail.managedObjectContext saveAsyncAndHandleError];
  [self updateDoneButton];
  }
  
- (IBAction)onDragOnParentImage:(UIPanGestureRecognizer*)gestureRecognizer
  {
  CGRect imageVisualFrame = [_parentImageVisualFrameCalculator imageVisualFrameInViewCoordinates];
  CGPoint position = [gestureRecognizer locationInView:_imageViewParent];
  position.x += imageVisualFrame.origin.x;
  position.y -= imageVisualFrame.origin.y;
  
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    if ([self tryToSelectPinAtPoint:position andGetDeltaFromItToPinTargetPoint:&_deltaFromDraggingPointToThePinTargetPoint])
      [self updatePins];
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
      gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    [self movePinToPoint:position];
    }
  else if (gestureRecognizer.state != UIGestureRecognizerStatePossible)//ended, cancelled, failed or recognized states
    {
    _deltaFromDraggingPointToThePinTargetPoint = CGPointZero;
    [self correctSelectedPinPosition];
    [self.detail.managedObjectContext saveAsyncAndHandleError];
    [self updateDoneButton];
    }
  }
  
- (IBAction)onImagePressed:(id)sender
  {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count >= 2 && [[viewControllers objectAtIndex:viewControllers.count-2] isKindOfClass:[DetailTypesViewController class]])
    [self.navigationController popViewControllerAnimated:YES];
  else
    [self performSegueWithIdentifier:@"ChangeDetailType" sender:nil];
  }
  
- (void)goToParentAssemblyScreen
  {
  for (UIViewController* viewController in self.navigationController.viewControllers.reverseObjectEnumerator)
    if ([viewController isKindOfClass:[AssembliesAndDetailsViewController class]])
      {
      [self.navigationController popToViewController:viewController animated:YES];
      break;
      }
  }
  
- (IBAction)onBackPressed:(id)sender
  {
  [self goToParentAssemblyScreen];
  }
  
- (IBAction)onDonePressed:(id)sender
  {
  [self goToParentAssemblyScreen];
  }

- (void)correctSelectedPointIndex
  {
  if (_selectedPointIndex > _details.count-1)
    _selectedPointIndex = _details.count-1;
  if (_selectedPointIndex < 0)
    _selectedPointIndex = 0;
  }

- (void)correctSelectedPinPosition
  {
  NSValue* connectionPointValue = [[_details objectAtIndex:_selectedPointIndex] connectionPoint];
  CGPoint connectionPoint = [connectionPointValue CGPointValue];
  if (connectionPoint.x < 0 || connectionPoint.x >1 || connectionPoint.y < 0 ||connectionPoint.y > 1)
    {
    if (connectionPoint.x < 0)
      connectionPoint.x = 0;
    if (connectionPoint.x >1)
      connectionPoint.x = 1;
    if (connectionPoint.y < 0)
      connectionPoint.y = 0;
    if (connectionPoint.y > 1)
      connectionPoint.y = 1;
    
    [[_details objectAtIndex:_selectedPointIndex] setConnectionPoint:[NSValue valueWithCGPoint:connectionPoint]];
    [self updatePins];
    }
  }

- (IBAction)onCountChanged:(id)sender
  {
  NSInteger newCount = _countStepper.value;
  NSInteger oldCount = _details.count;
  NSInteger deltaCount = newCount - oldCount;
  _countLabel.text = [NSString stringWithFormat:@"%d", newCount];
  Detail* lastDetail = self.detail;
  if (deltaCount >= 0)
    {
    NSMutableArray* detailsToAdd = [[NSMutableArray alloc] initWithCapacity:deltaCount];
    DetailType* type = lastDetail.type;
    for (int i = 0; i < deltaCount; ++i)
      {
      Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:lastDetail.managedObjectContext];
      detail.type = type;
      detail.assemblyToInstallTo = lastDetail.assemblyToInstallTo;
      [detailsToAdd addObject:detail];
      }
    [_details addObjectsFromArray:detailsToAdd];
    _selectedPointIndex = _details.count - 1;
    }
  else
    {
    deltaCount = abs(deltaCount);
    if (deltaCount == 1)
      {
      Detail* detail = [_details objectAtIndex:_selectedPointIndex];
      [lastDetail.managedObjectContext deleteObject:detail];
      [_details removeObjectAtIndex:_selectedPointIndex];
      }
    else
      {
      NSRange range = NSMakeRange(_details.count - deltaCount, deltaCount);
      NSArray* detailsToRemove = [_details subarrayWithRange:range];
      [_details removeObjectsInRange:range];
      for (Detail* detail in detailsToRemove)
        [lastDetail.managedObjectContext deleteObject:detail];
      }
    }
  [lastDetail.managedObjectContext saveAsyncAndHandleError];
  [self correctSelectedPointIndex];
  [self updateDoneButton];
  [self updatePins];
  }
  
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if([@"ChangeDetailType" isEqualToString:segue.identifier])
    {
    ((DetailTypesViewController*)segue.destinationViewController).details = self.details;
    }
  }
  
@end
