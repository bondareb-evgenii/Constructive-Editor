//
//  ActionSheet.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports
#import <Foundation/Foundation.h>


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Predeclarations
@class ActionSheet;
@protocol ActionSheetDelegate;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
extern NSString* const ActionSheetDidDismissNotification;
extern NSString* const ActionSheetButtonIndexUserInfo;

enum
  {
  // Button index passed to the delegate when application becomes inactive i.e. close method was called
  kActionSheetCancelButtonIndex = -1
  };

typedef void(^ActionSheetClickButtonBlock)(ActionSheet* ActionSheet, NSInteger buttonIndex);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface
@interface ActionSheet : UIActionSheet 

  + (ActionSheet*)currentActionSheet;

  - (id)initWithTitle:(NSString *)title clickButtonBlock:(ActionSheetClickButtonBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *) otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

  - (void)close;
  
@end
