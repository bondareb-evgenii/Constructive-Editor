//
//  EditAssemblyViewController.h
//  ConstructiveEditor
//
//  Created by Evgenii Bondarev on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
