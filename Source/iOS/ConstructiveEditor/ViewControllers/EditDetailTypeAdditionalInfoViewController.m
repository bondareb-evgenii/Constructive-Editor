//
//  ViewController.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "EditDetailTypeAdditionalInfoViewController.h"
#import "Constants.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@interface EditDetailTypeAdditionalInfoViewController (UIImagePickerControllerDelegate) <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@interface EditDetailTypeAdditionalInfoViewController (UIPickerViewDataSource) <UIPickerViewDataSource>
@end

@interface EditDetailTypeAdditionalInfoViewController (UIPickerViewDelegate) <UIPickerViewDelegate>
@end

@interface EditDetailTypeAdditionalInfoViewController (UITextFieldDelegate) <UITextFieldDelegate>
@end

@interface EditDetailTypeAdditionalInfoViewController ()
  {
  __weak IBOutlet UITextField*        _detailLabelTextField;
  __weak IBOutlet UIStepper*          _detailLengthStepper;
  __weak IBOutlet UILabel*            _detailLengthLabel;
  
  __weak IBOutlet UIPickerView*       _detailClassPicker;

  NSArray*                            _detailClassesLabels;
  }
@end
  
@implementation EditDetailTypeAdditionalInfoViewController

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
  _detailLabelTextField.text = _detailType.identifier;
  _detailLabelTextField.delegate = self;
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
  }

- (void)viewWillDisappear:(BOOL)animated
  {
  if (!_detailLabelTextField.hidden)
    [self textFieldShouldReturn:_detailLabelTextField];
  }

- (void)updateLengthControls
  {
  int length = _detailType.length.intValue;
  if (length < 2)
    {
    length = 2;
    _detailType.length = [NSNumber numberWithInt:length];
    [_detailType.managedObjectContext saveAsyncAndHandleError];
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
  [_detailType.managedObjectContext saveAsyncAndHandleError];
  [self updateLengthControls];
  }
  
@end

@implementation EditDetailTypeAdditionalInfoViewController (UIPickerViewDataSource)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
  {
  return 1;
  }
  
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
  {
  return _detailClassesLabels.count;
  }
  
@end

@implementation EditDetailTypeAdditionalInfoViewController (UIPickerViewDelegate)
  
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
  [_detailType.managedObjectContext saveAsyncAndHandleError];
  }
  
@end

@implementation EditDetailTypeAdditionalInfoViewController (UITextFieldDelegate)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
  {
  [_detailLabelTextField resignFirstResponder];
  NSString* label = _detailLabelTextField.text;
  if (!label.length)
    label = nil;
  _detailType.identifier = label;
  [_detailType.managedObjectContext saveAsyncAndHandleError];
  return YES;
  }

@end