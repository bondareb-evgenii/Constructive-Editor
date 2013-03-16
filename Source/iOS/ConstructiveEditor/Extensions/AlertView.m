//
//  AlertView.m
//  ConstructiveEditor


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports
#import "AlertView.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
NSString* const AlertViewDidDismissNotification = @"AlertViewDidDismissNotification";
NSString* const AlertViewButtonIndexUserInfo = @"AlertViewButtonIndexUserInfo";

static AlertView *sCurrentAlert = nil;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface
@protocol AlertViewDelegate <UIAlertViewDelegate> 

  - (void)notifyCloseAlert:(AlertView*)alert;

@end

@interface AlertViewBlockDelegate : NSObject <AlertViewDelegate>
  {
  AlertViewClickButtonBlock        _clickBlock;
  BOOL                                _clickInProgress;
  }
  
  - (id)initWithClickButtonBlock:(AlertViewClickButtonBlock)clickBlock;

@end

@interface AlertViewRedirectDelegate : NSObject <AlertViewDelegate>
  {
  id                  _delegate;
  BOOL                _clickInProgress;
  struct 
    {
    unsigned int delegateClickedButtonAtIndex:1;
    unsigned int delegateCancel:1;
    unsigned int delegateWillPresent:1;
    unsigned int delegateDidPresent:1;
    unsigned int delegateWillDismiss:1;
    unsigned int delegateDidDismiss:1;
    }                 _flags;
  }
  
  - (id)initWithDelegate:(id)delegate;

@end

@interface AlertView ()
  {
  id<AlertViewDelegate>          _internalDelegate;
  }
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation
@implementation AlertView

+ (AlertView*)currentAlert
  {
  return sCurrentAlert;
  }

- (id)initWithTitle:(NSString *)title message:(NSString *)message clickButtonBlock:(AlertViewClickButtonBlock)clickBlock
    cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
  {
  va_list ap;
  va_start(ap, otherButtonTitles);

  _internalDelegate = [[AlertViewBlockDelegate alloc] initWithClickButtonBlock:clickBlock];
  
  if (!otherButtonTitles)
    {
    self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
        otherButtonTitles:nil]; 
    }
  else
    {
    NSString* otherButtonTitle1 = va_arg(ap, NSString*);
    if (!otherButtonTitle1)
      {
      self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
          otherButtonTitles:otherButtonTitles, nil]; 
      }
    else
      {
      NSString* otherButtonTitle2 = va_arg(ap, NSString*);
      if (!otherButtonTitle2)
        {
        self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
            otherButtonTitles:otherButtonTitles, otherButtonTitle1, nil]; 
        }
      else
        {
        NSString* otherButtonTitle3 = va_arg(ap, NSString*);
        if (!otherButtonTitle3)
          {
          self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
              otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, nil]; 
          }
        else
          {
          NSAssert(nil, @"Unsupported number of buttons > 2");
          }
        }
      }
    }

  va_end(ap);

  return self;
  }

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<UIAlertViewDelegate>*/)inDelegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
  {
  va_list ap;
  va_start(ap, otherButtonTitles);

  _internalDelegate = [[AlertViewRedirectDelegate alloc] initWithDelegate:inDelegate];
  
  if (!otherButtonTitles)
    {
    self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
        otherButtonTitles:nil]; 
    }
  else
    {
    NSString* otherButtonTitle1 = va_arg(ap, NSString*);
    if (!otherButtonTitle1)
      {
      self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
          otherButtonTitles:otherButtonTitles, nil]; 
      }
    else
      {
      NSString* otherButtonTitle2 = va_arg(ap, NSString*);
      if (!otherButtonTitle2)
        {
        self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
            otherButtonTitles:otherButtonTitles, otherButtonTitle1, nil]; 
        }
      else
        {
        NSString* otherButtonTitle3 = va_arg(ap, NSString*);
        if (!otherButtonTitle3)
          {
          self = [super initWithTitle:title message:message delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
              otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, nil]; 
          }
        else
          {
          NSAssert(nil, @"Unsupported number of buttons > 2");
          }
        }
      }
    }

  va_end(ap);

  return self;
  }

- (void)show
  {
  [super show];
  }

- (void)close
  {
  [self dismissWithClickedButtonIndex:kAlertViewCloseButtonIndex animated:NO];
  [_internalDelegate notifyCloseAlert:self];
  }

@end



@implementation AlertViewBlockDelegate

- (id)initWithClickButtonBlock:(AlertViewClickButtonBlock)clickBlock
  {
  self = [super init];
  if (self)
    {
    _clickBlock = [clickBlock copy];
    }
    
  return self;
  }

- (void)notifyCloseAlert:(AlertView*)alert
  {
  if (!_clickInProgress)
    {
    sCurrentAlert = nil;
    _clickBlock(alert, kAlertViewCloseButtonIndex);
    }
  }

#pragma mark Alert View delegate

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
  {
  sCurrentAlert = nil;
  _clickInProgress = YES;
  _clickBlock(alertView, buttonIndex);
  _clickInProgress = NO;
  }

- (void)willPresentAlertView:(AlertView *)alertView
  {
  sCurrentAlert = alertView;
  }

- (void)alertView:(AlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  sCurrentAlert = nil;
  }

- (void)alertView:(AlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  [[NSNotificationCenter defaultCenter] postNotificationName:AlertViewDidDismissNotification object:alertView 
    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:buttonIndex] forKey:AlertViewButtonIndexUserInfo]];
  }

@end

@implementation AlertViewRedirectDelegate

- (id)initWithDelegate:(id)delegate;
  {
  self = [super init];
  if (self)
    {
    _delegate = delegate;

    _flags.delegateClickedButtonAtIndex = [_delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)];
    _flags.delegateCancel = [_delegate respondsToSelector:@selector(alertViewCancel:)];
    _flags.delegateWillPresent = [_delegate respondsToSelector:@selector(willPresentAlertView:)];
    _flags.delegateDidPresent = [_delegate respondsToSelector:@selector(didPresentAlertView:)];
    _flags.delegateWillDismiss = [_delegate respondsToSelector:@selector(alertView:illDismissWithButtonIndex:)];
    _flags.delegateDidDismiss = [_delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)];
    }
    
  return self;
  }

- (void)notifyCloseAlert:(AlertView*)alert
  {
  if (!_clickInProgress)
    {
    [self alertView:alert clickedButtonAtIndex:kAlertViewCloseButtonIndex];
    sCurrentAlert = nil;
    }
  }

#pragma mark Alert View delegate

- (void)alertView:(AlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
  {
  if (_flags.delegateClickedButtonAtIndex)
    {
    sCurrentAlert = nil;
    _clickInProgress = YES;
    [_delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    _clickInProgress = NO;
    }
  }

- (void)alertViewCancel:(AlertView *)alertView
  {
  if (_flags.delegateCancel)
    {
    [_delegate alertViewCancel:alertView];
    }
  }

- (void)willPresentAlertView:(AlertView *)alertView
  {
  if (_flags.delegateWillPresent)
    {
    [_delegate willPresentAlertView:alertView];
    }
  sCurrentAlert = alertView;
  }
  
- (void)didPresentAlertView:(AlertView *)alertView
  {
  if (_flags.delegateDidPresent)
    {
    [_delegate didPresentAlertView:alertView];
    }
  }

- (void)alertView:(AlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  sCurrentAlert = nil;
  if (_flags.delegateWillDismiss)
    {
    [_delegate alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
  }
  
- (void)alertView:(AlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  if (_flags.delegateDidDismiss)
    {
    [_delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
  [[NSNotificationCenter defaultCenter] postNotificationName:AlertViewDidDismissNotification object:alertView 
    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:buttonIndex] forKey:AlertViewButtonIndexUserInfo]];
  }

@end

