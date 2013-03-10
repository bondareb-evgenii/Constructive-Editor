//
//  UINavigationControllerExtension.m
//  ConstructiveEditor

#import "UINavigationControllerExtension.h"

@implementation UINavigationController (Extension)

- (BOOL)shouldAutorotate
  {
  return YES;
  }

- (NSUInteger)supportedInterfaceOrientations
  {
  return UIInterfaceOrientationMaskAll;
  }

@end
