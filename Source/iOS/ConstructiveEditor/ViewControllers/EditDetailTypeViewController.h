//
//  EditDetailTypeViewController.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Assembly;
  
@interface EditDetailTypeViewController : UIViewController
  {
  @private
    __weak IBOutlet UIImageView *imageView;
  }

@property (nonatomic, strong) Assembly* assembly;

@end
