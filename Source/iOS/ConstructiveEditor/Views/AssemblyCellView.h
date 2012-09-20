//
//  AssemblyCellView.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports
#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface
@interface AssemblyCellView : UITableViewCell 
  {
  }

  @property (nonatomic, weak) IBOutlet UIImageView* picture;
  @property (weak, nonatomic) IBOutlet UIStepper *countStepper;
  @property (weak, nonatomic) IBOutlet UILabel *countLabel;
  

@end
