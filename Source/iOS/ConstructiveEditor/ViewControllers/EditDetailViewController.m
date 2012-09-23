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
  __weak IBOutlet UIImageView*        _imageView;
  __weak IBOutlet UIView*             _containerViewForParentImageView;
  __weak IBOutlet UIImageView*        _imageViewParent;
  __weak IBOutlet UIView*             _viewAspectFit;
  __weak IBOutlet NSLayoutConstraint* _constraintViewAspectFitWidth;
  __weak IBOutlet NSLayoutConstraint* _constraintViewAspectFitHeight;
    IBOutlet UITapGestureRecognizer*  _tapOnParentImageGestureRecognizer;
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

- (CGSize)updatedViewAspectFitSize
  {
  float containerWidth = _containerViewForParentImageView.bounds.size.width;
  float containerHeight = _containerViewForParentImageView.bounds.size.height;
  float containerWidthToHeightProportion = containerWidth/containerHeight;
  UIImage* parentPicture = [self.detail.assemblyToInstallTo pictureToShow];
  float widthToHeightProportionOfParentImage = nil != parentPicture
                                             ? parentPicture.size.width/parentPicture.size.height
                                             : 1;//just a value bigger then 0
  if (containerWidthToHeightProportion > widthToHeightProportionOfParentImage)//allign by height
    return CGSizeMake(containerHeight*widthToHeightProportionOfParentImage, containerHeight);
  else//allign by width
    return CGSizeMake(containerWidth, containerWidth/widthToHeightProportionOfParentImage);
  }

- (void)updateViewAspectFit
  {
  CGSize updatedViewAspectFitSize = [self updatedViewAspectFitSize];
  _constraintViewAspectFitWidth.constant = updatedViewAspectFitSize.width;
  _constraintViewAspectFitHeight.constant = updatedViewAspectFitSize.height;
  [self.view layoutIfNeeded];
  }

- (void)updatePins
  {
  while (_pins.count < _details.count)
    {
    UIImageView* pin = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _pinImage.size.width, _pinImage.size.width)];
    pin.translatesAutoresizingMaskIntoConstraints = NO;
    [_viewAspectFit addSubview:pin];
    [_pins addObject:pin];
    NSArray* pinHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[pin]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pin)];
    [_viewAspectFit addConstraints:pinHorizontalConstraints];
    NSArray* pinVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[pin]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(pin)];
    [_pinsHorizontalConstraints addObjectsFromArray:pinHorizontalConstraints];
    [_viewAspectFit addConstraints:pinVerticalConstraints];
    [_pinsVerticalConstraints addObjectsFromArray:pinVerticalConstraints];
    }
  
  while (_pins.count > _details.count)
    {
    [[_pins lastObject] removeFromSuperview];
    [_pins removeLastObject];
    [_pinsHorizontalConstraints removeLastObject];
    [_pinsVerticalConstraints removeLastObject];
    }
    
  CGSize updatedViewAspectFitSize = [self updatedViewAspectFitSize];
  for (int i = 0; i < _details.count; ++i)
    {
    NSValue* connectionPointValue = [[self.details objectAtIndex:i] connectionPoint];
    CGPoint pinPointRelativeToParentImageSize = nil!= connectionPointValue
                                              ? [connectionPointValue CGPointValue]
                                              : CGPointZero;
    CGPoint topLeftPinViewCorner = [_pinMetaInfo topLeftImageCornerPointForTargetPoint:CGPointMake(updatedViewAspectFitSize.width*pinPointRelativeToParentImageSize.x, updatedViewAspectFitSize.height - updatedViewAspectFitSize.height*pinPointRelativeToParentImageSize.y)];
    ((NSLayoutConstraint*)[_pinsHorizontalConstraints objectAtIndex:i]).constant =  topLeftPinViewCorner.x;
    ((NSLayoutConstraint*)[_pinsVerticalConstraints objectAtIndex:i]).constant = topLeftPinViewCorner.y;
    
    if (i == _selectedPointIndex)
      [[_pins objectAtIndex:i] setImage:_selectedPinImage];
    else
      [[_pins objectAtIndex:i] setImage:_pinImage];
    }
  [_viewAspectFit layoutIfNeeded];
  [_viewAspectFit bringSubviewToFront:[_pins objectAtIndex:_selectedPointIndex]];
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
  [self updateViewAspectFit];
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
  _imageView.image = [self.detail.type pictureToShow]
                   ? [self.detail.type pictureToShow]
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
  [self updateDoneButton];
  }
  
- (void)viewDidAppear:(BOOL)animated
  {
  [self updateViewAspectFit];
  [self updatePins];
  [self showPinAnimated:YES];
  }

- (void)movePinToPoint:(CGPoint)position
  {
  CGPoint pinPointRelativeToParentImageSize = CGPointMake((position.x+_deltaFromDraggingPointToThePinTargetPoint.x)/_viewAspectFit.bounds.size.width, (_viewAspectFit.bounds.size.height-(position.y+_deltaFromDraggingPointToThePinTargetPoint.y))/_viewAspectFit.bounds.size.height);
  [(Detail*)[self.details objectAtIndex:_selectedPointIndex] setConnectionPoint:[NSValue valueWithCGPoint:pinPointRelativeToParentImageSize]];
  [self updatePins];
  [self showPinAnimated:NO];
  }

- (BOOL)tryToSelectPinAtPoint:(CGPoint)point delta:(CGPoint*)delta
  {
  for (int i = 0; i < _details.count; ++i)
    {
    Detail* detail = [_details objectAtIndex:i];
    CGSize updatedViewAspectFitSize = [self updatedViewAspectFitSize];
    CGPoint connectionPointRelativeToImageSize = [detail.connectionPoint CGPointValue];
    CGPoint targetPoint = CGPointMake(updatedViewAspectFitSize.width*connectionPointRelativeToImageSize.x, updatedViewAspectFitSize.height - updatedViewAspectFitSize.height*connectionPointRelativeToImageSize.y);
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
  CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
  
  if ([self tryToSelectPinAtPoint:position delta:nil])//we should not change the _deltaFromDraggingPointToThePinTargetPoint here
    return;
  [self movePinToPoint:position];
  [self.detail.managedObjectContext saveAndHandleError];
  [self updateDoneButton];
  }
  
- (IBAction)onDragOnParentImage:(UIPanGestureRecognizer*)gestureRecognizer
  {
  CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    if ([self tryToSelectPinAtPoint:position delta:&_deltaFromDraggingPointToThePinTargetPoint])
      [self updatePins];
  if (gestureRecognizer.state == UIGestureRecognizerStateBegan ||
      gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
    [self movePinToPoint:position];
    }
  else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
    _deltaFromDraggingPointToThePinTargetPoint = CGPointZero;
    [self correctSelectedPinPosition];
    [self.detail.managedObjectContext saveAndHandleError];
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
  [lastDetail.managedObjectContext saveAndHandleError];
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
