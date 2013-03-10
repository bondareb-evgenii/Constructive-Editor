//
//  UIImagePickerControllerExtension.m
//  ConstructiveEditor

#import "UIImagePickerControllerExtension.h"

@implementation UIImagePickerController (Extension)

- (BOOL)shouldAutorotate
  {
  return YES;
  }

- (NSUInteger)supportedInterfaceOrientations
  {
  return UIInterfaceOrientationMaskAll;
  }

@end
