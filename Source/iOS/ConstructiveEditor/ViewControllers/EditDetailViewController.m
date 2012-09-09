//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailViewController.h"
#import "Assembly.h"
#import "Detail.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"

@interface EditDetailViewController ()
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

@implementation EditDetailViewController

@synthesize detail = _detail;

- (void)updateLabelText
  {
  BOOL areAllConnectionPointsSet = nil != self.detail.connectionPoint;
  _labelInstalledTo.text = areAllConnectionPointsSet
                         ? NSLocalizedString(@"Installed to:", @"Label text")
                         : NSLocalizedString(@"Specify the nstallation point!!!", @"Label text");
  _labelInstalledTo.textColor = areAllConnectionPointsSet
                              ? [UIColor blackColor]
                              : [UIColor redColor];
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
  
- (void)viewDidLoad
  {
  [super viewDidLoad];
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
  
- (void)viewWillAppear:(BOOL)animated
  {
  //moved to here from viewDidLoad because detail type updates when go back from DetailTypesViewController
  [self updateLabelText];
  _imageView.image = [self.detail.type pictureToShow]
                   ? [self.detail.type pictureToShow]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];
                   
  UIImage* parentPicture = [self.detail.assemblyToInstallTo pictureToShow];
  _imageViewParent.image = parentPicture
                         ? parentPicture
                         : [UIImage imageNamed:@"NoPhotoBig.png"];
                        
  _viewPin.alpha = 0;
  _pinPointRelativeToParentImageSize = nil!= self.detail.connectionPoint
                                     ? [self.detail.connectionPoint CGPointValue]
                                     : CGPointZero;
  _tapOnParentImageGestureRecognizer.enabled = nil != parentPicture;
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
  [self updateLabelText];
  }
  
- (IBAction)onTapOnParentImage:(UITapGestureRecognizer *)gestureRecognizer
  {
  CGPoint position = [gestureRecognizer locationInView:_viewAspectFit];
  [self movePinToPoint:position];
  [self.detail.managedObjectContext saveAndHandleError];
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
    [self.detail.managedObjectContext saveAndHandleError];
  }
  
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
  {
  if([@"SelectDetailType" isEqualToString:segue.identifier])
    {
    ((EditDetailViewController*)segue.destinationViewController).detail = self.detail;
    }
  }
  
@end
