//
//  AlertView.h
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports
#import <Foundation/Foundation.h>


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Predeclarations
@class AlertView;
@protocol AlertViewDelegate;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
extern NSString* const AlertViewDidDismissNotification;
extern NSString* const AlertViewButtonIndexUserInfo;

enum
  {
  // Button index passed to the delegate when application becomes inactive i.e. close method was called
  kAlertViewCloseButtonIndex = -1
  };

typedef void(^AlertViewClickButtonBlock)(AlertView* alertView, NSInteger buttonIndex);


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface
@interface AlertView : UIAlertView 

  + (AlertView*)currentAlert;

  - (id)initWithTitle:(NSString *)title message:(NSString *)message clickButtonBlock:(AlertViewClickButtonBlock)clickBlock
      cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

  - (void)close;
  
@end
