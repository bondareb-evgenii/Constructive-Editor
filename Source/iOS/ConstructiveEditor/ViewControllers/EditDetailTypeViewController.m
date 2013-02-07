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
  __weak IBOutlet UIPickerView*       _detailClassPicker;
  __weak IBOutlet UIView*             _pictureImageViewContainer;
  __weak IBOutlet UIImageView*        _pictureImageView;
  __weak IBOutlet UIImageView*        _pinPlatePictureImageView;
  __weak IBOutlet NSLayoutConstraint* _constraintVerticalSpaceFromPickerToViewContainer;
  __weak IBOutlet NSLayoutConstraint* _constraintViewContainerLeadingSpaceToSuperview;
  __weak IBOutlet NSLayoutConstraint* _constraintPickerTrainlingSpaceToSuperview;
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