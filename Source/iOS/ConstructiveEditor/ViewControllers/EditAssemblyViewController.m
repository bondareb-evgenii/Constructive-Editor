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
#import "VisualSelectablePointer.h"

@interface EditAssemblyViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@interface EditAssemblyViewController ()
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

@implementation EditAssemblyViewController

@synthesize assemblies = _assemblies;

- (Assembly*)assembly
  {
  return (Assembly*)[self.assemblies lastObject];
  }

- (CGSize)updatedViewAspectFitSize
  {
  float containerWidth = _containerViewForParentImageView.bounds.size.width;
  float containerHeight = _containerViewForParentImageView.bounds.size.height;
  float containerWidthToHeightProportion = containerWidth/containerHeight;
  UIImage* parentPicture = [[self.assembly assemblyToInstallTo] pictureToShow];
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
  while (_pins.count < _assemblies.count)
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
  
  while (_pins.count > _assemblies.count)
    {
    [[_pins lastObject] removeFromSuperview];
    [_pins removeLastObject];
    [_pinsHorizontalConstraints removeLastObject];
    [_pinsVerticalConstraints removeLastObject];
    }
    
  CGSize updatedViewAspectFitSize = [self updatedViewAspectFitSize];
  for (int i = 0; i < _assemblies.count; ++i)
    {
    NSValue* connectionPointValue = [[self.assemblies objectAtIndex:i] connectionPoint];
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
  [_viewAspectFit bringSubviewToFront:[_pins objectAtIndex:_selectedPointIndex]];
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
  if (![self.assembly.assemblyToInstallTo pictureToShow])
    return;
  if (animated)
    {[UIView animateWithDuration:0.3 animations:^
      {
      for (UIView* pin in _pins)
        pin.alpha = 1;
      }];
    }
  else
    for (UIView* pin in _pins)
      pin.alpha = 1;
  }
  
- (void)viewDidLoad
  {
  [super viewDidLoad];
  _pinImage = [UIImage imageNamed:@"pin.png"];
  _selectedPinImage = [UIImage imageNamed:@"pinSelected.png"];
  
  _pinMetaInfo = [[VisualSelectablePointer alloc] initWithSelectionCenter:CGPointMake(15, 10) selectionRadius:30 andTargetPoint:CGPointMake(0, 45)];
  _pins = [[NSMutableArray alloc] initWithCapacity:1];
  _pinsHorizontalConstraints = [[NSMutableArray alloc] initWithCapacity:1];
  _pinsVerticalConstraints = [[NSMutableArray alloc] initWithCapacity:1];
  
  _imageView.image = [self.assembly.type pictureToShow]
                   ? [self.assembly.type pictureToShow]
                   : [UIImage imageNamed:@"NoPhotoBig.png"];
  UIImage* parentPicture = [self.assembly.assemblyToInstallTo pictureToShow];
  _imageViewParent.image = parentPicture
                         ? parentPicture
                         : [UIImage imageNamed:@"NoPhotoBig.png"];
  _countLabel.text = [NSString stringWithFormat:@"%d", _assemblies.count];
  _countStepper.value = _assemblies.count;
  
  [self updatePins];
  for (UIView* pin in _pins)
    pin.alpha = 0;
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
  [self updateViewAspectFit];
  [self updatePins];
  [self showPinAnimated:YES];
  }
  
- (void)viewDidAppear:(BOOL)animated
  {
  [self updateViewAspectFit];
  [self updatePins];
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
  CGPoint pinPointRelativeToParentImageSize = CGPointMake((position.x+_deltaFromDraggingPointToThePinTargetPoint.x)/_viewAspectFit.bounds.size.width, (_viewAspectFit.bounds.size.height-(position.y+_deltaFromDraggingPointToThePinTargetPoint.y))/_viewAspectFit.bounds.size.height);
  [(Assembly*)[self.assemblies objectAtIndex:_selectedPointIndex] setConnectionPoint:[NSValue valueWithCGPoint:pinPointRelativeToParentImageSize]];
  [self updatePins];
  [self showPinAnimated:NO];
  }

- (BOOL)tryToSelectPinAtPoint:(CGPoint)point
  {
  return NO;
  }

- (BOOL)tryToSelectPinAtPoint:(CGPoint)point delta:(CGPoint*)delta
  {
  for (int i = 0; i < _assemblies.count; ++i)
    {
    Assembly* assembly = [_assemblies objectAtIndex:i];
    CGSize updatedViewAspectFitSize = [self updatedViewAspectFitSize];
    CGPoint connectionPointRelativeToImageSize = [assembly.connectionPoint CGPointValue];
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
  if ([self tryToSelectPinAtPoint:position])
    return;
  if ([self tryToSelectPinAtPoint:position delta:nil])//we should not change the _deltaFromDraggingPointToThePinTargetPoint here
    return;
  [self movePinToPoint:position];
  [self.assembly.managedObjectContext saveAndHandleError];
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
    [self.assembly.managedObjectContext saveAndHandleError];
    [self updateDoneButton];
    }
  }

- (void)correctSelectedPointIndex
  {
  if (_selectedPointIndex > _assemblies.count-1)
    _selectedPointIndex = _assemblies.count-1;
  if (_selectedPointIndex < 0)
    _selectedPointIndex = 0;
  }

- (void)correctSelectedPinPosition
  {
  NSValue* connectionPointValue = [[_assemblies objectAtIndex:_selectedPointIndex] connectionPoint];
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
    
    [[_assemblies objectAtIndex:_selectedPointIndex] setConnectionPoint:[NSValue valueWithCGPoint:connectionPoint]];
    [self updatePins];
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
    _selectedPointIndex = _assemblies.count - 1;
    }
  else
    {
    deltaCount = abs(deltaCount);
    if (deltaCount == 1)
      {
      Assembly* assembly = [_assemblies objectAtIndex:_selectedPointIndex];
      [lastAssembly.managedObjectContext deleteObject:assembly];
      [_assemblies removeObjectAtIndex:_selectedPointIndex];
      }
    else
      {
      NSRange range = NSMakeRange(_assemblies.count - deltaCount, deltaCount);
      NSArray* assembliesToRemove = [_assemblies subarrayWithRange:range];
      [_assemblies removeObjectsInRange:range];
      for (Assembly* assembly in assembliesToRemove)
        [lastAssembly.managedObjectContext deleteObject:assembly];
      }
    }
  [lastAssembly.managedObjectContext saveAndHandleError];
  [self correctSelectedPointIndex];
  [self updateDoneButton];
  [self updatePins];
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
