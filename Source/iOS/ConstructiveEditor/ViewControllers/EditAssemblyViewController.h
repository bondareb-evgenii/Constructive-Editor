//
//  EditAssemblyViewController.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Assembly;
  
@interface EditAssemblyViewController : UIViewController
  {
  @private
    __weak IBOutlet UIImageView *imageView;
  }

@property (nonatomic, strong) Assembly* assembly;

@end
