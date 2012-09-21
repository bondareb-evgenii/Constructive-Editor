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

@interface EditDetailViewController ()
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

@implementation EditDetailViewController

@synthesize details = _details;

- (Detail*)detail
  {
  return (Detail*)[_details lastObject];
  }
  
- (void)updateConstraints
  {
  float containerWidth = _containerViewForParentImageView.bounds.size.width;
  float containerHeight = _containerViewForParentImageView.bounds.size.height;
  float containerWidthToHeightProportion = containerWidth/containerHeight;
  UIImage* parentPicture = [self.detail.assemblyToInstallTo pictureToShow];
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
  if (![self.detail.assemblyToInstallTo pictureToShow])
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
  
  _viewPin.alpha = 0;
  _pinPointRelativeToParentImageSize = nil!= self.detail.connectionPoint
                                     ? [self.detail.connectionPoint CGPointValue]
                                     : CGPointZero;
  _tapOnParentImageGestureRecognizer.enabled = nil != parentPicture;
  [self updateDoneButton];
  }
  
- (void)viewDidAppear:(BOOL)animated
  {
  [self updateConstraints];
  [self.view layoutIfNeeded];
  [self showPinAnimated:YES];
  }

- (void)movePinToPoint:(CGPoint)position
  {
  _pinPointRelativeToParentImageSize = CGPointMake(position.x/_viewAspectFit.bounds.size.width, (_viewAspectFit.bounds.size.height-position.y)/_viewAspectFit.bounds.size.height);
  self.detail.connectionPoint = [NSValue valueWithCGPoint:_pinPointRelativeToParentImageSize];
  [self updateConstraints];
  [_viewAspectFit layoutIfNeeded];
  [self showPinAnimated:NO];
  }
  
- (IBAction)onTapOnParentImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
  [self movePinToPoint:position];
  [self.detail.managedObjectContext saveAndHandleError];
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
    }
  else
    {
    deltaCount = abs(deltaCount);
    NSRange range = NSMakeRange(_details.count - deltaCount, deltaCount);
    NSArray* detailsToRemove = [_details subarrayWithRange:range];
    [_details removeObjectsInRange:range];
    for (Detail* detail in detailsToRemove)
      [lastDetail.managedObjectContext deleteObject:detail];
    }
  [lastDetail.managedObjectContext saveAndHandleError];
  [self updateDoneButton];
  }
  
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if([@"ChangeDetailType" isEqualToString:segue.identifier])
    {
    ((DetailTypesViewController*)segue.destinationViewController).details = self.details;
    }
  }
  
@end
