//
//  ActionSheet.m
//  ConstructiveEditor


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Imports
#import "ActionSheet.h"


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Constants
NSString* const ActionSheetDidDismissNotification = @"ActionSheetDidDismissNotification";
NSString* const ActionSheetButtonIndexUserInfo = @"ActionSheetButtonIndexUserInfo";

static ActionSheet *sCurrentActionSheet = nil;


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface
@protocol ActionSheetDelegate <UIActionSheetDelegate> 

  - (void)notifyCloseAlert:(ActionSheet*)alert;

@end

@interface ActionSheetBlockDelegate : NSObject <ActionSheetDelegate>
  {
  ActionSheetClickButtonBlock        _clickBlock;
  BOOL                                _clickInProgress;
  }
  
  - (id)initWithClickButtonBlock:(ActionSheetClickButtonBlock)clickBlock;

@end

@interface ActionSheetRedirectDelegate : NSObject <ActionSheetDelegate>
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

@interface ActionSheet ()
  {
  id<ActionSheetDelegate>          _internalDelegate;
  }
@end
  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation
@implementation ActionSheet
  
+ (ActionSheet*)currentActionSheet
  {
  return sCurrentActionSheet;
  }

- (id)initWithTitle:(NSString *)title clickButtonBlock:(ActionSheetClickButtonBlock)clickBlock cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
  {
  va_list ap;
  va_start(ap, otherButtonTitles);

  _internalDelegate = [[ActionSheetBlockDelegate alloc] initWithClickButtonBlock:clickBlock];
  
  if (!otherButtonTitles)
    {
    self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle
        otherButtonTitles:nil]; 
    }
  else
    {
    NSString* otherButtonTitle1 = va_arg(ap, NSString*);
    if (!otherButtonTitle1)
      {
      self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
          destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil]; 
      }
    else
      {
      NSString* otherButtonTitle2 = va_arg(ap, NSString*);
      if (!otherButtonTitle2)
        {
        self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
            destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, nil]; 
        }
      else
        {
        NSString* otherButtonTitle3 = va_arg(ap, NSString*);
        if (!otherButtonTitle3)
          {
          self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, nil]; 
          }
        else
          {
          NSString* otherButtonTitle4 = va_arg(ap, NSString*);
          if (!otherButtonTitle4)
            {
            self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, otherButtonTitle3, nil];
            }
          else
            {
            NSString* otherButtonTitle5 = va_arg(ap, NSString*);
            if (!otherButtonTitle5)
              {
              self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, otherButtonTitle3, otherButtonTitle4, nil];
              }
            else
              {
              NSAssert(nil, @"Unsupported number of buttons > 4");
              }
            }
          }
        }
      }
    }

  va_end(ap);

  return self;
  }

- (id)initWithTitle:(NSString *)title delegate:(id /*<UIActionSheetDelegate>*/)inDelegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
  {
  va_list ap;
  va_start(ap, otherButtonTitles);

  _internalDelegate = [[ActionSheetRedirectDelegate alloc] initWithDelegate:inDelegate];
  
  if (!otherButtonTitles)
    {
    self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
        destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil]; 
    }
  else
    {
    NSString* otherButtonTitle1 = va_arg(ap, NSString*);
    if (!otherButtonTitle1)
      {
      self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
          destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, nil]; 
      }
    else
      {
      NSString* otherButtonTitle2 = va_arg(ap, NSString*);
      if (!otherButtonTitle2)
        {
        self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle 
            destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, nil]; 
        }
      else
        {
        NSString* otherButtonTitle3 = va_arg(ap, NSString*);
        if (!otherButtonTitle3)
          {
          self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, nil]; 
          }
        else
          {
          NSString* otherButtonTitle4 = va_arg(ap, NSString*);
          if (!otherButtonTitle4)
            {
            self = [super initWithTitle:title delegate:_internalDelegate cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles, otherButtonTitle1, otherButtonTitle2, otherButtonTitle3, nil];
            }
          else
            {
            NSAssert(nil, @"Unsupported number of buttons > 3");
            }
          }
        }
      }
    }

  va_end(ap);

  return self;
  }
  
- (void)close
  {
  [self dismissWithClickedButtonIndex:kActionSheetCancelButtonIndex animated:NO];
  [_internalDelegate notifyCloseAlert:self];
  }

@end



@implementation ActionSheetBlockDelegate

- (id)initWithClickButtonBlock:(ActionSheetClickButtonBlock)clickBlock
  {
  self = [super init];
  if (self)
    {
    _clickBlock = [clickBlock copy];
    }
    
  return self;
  }

- (void)notifyCloseAlert:(ActionSheet*)alert
  {
  if (!_clickInProgress)
    {
    sCurrentActionSheet = nil;
    _clickBlock(alert, kActionSheetCancelButtonIndex);
    }
  }

#pragma mark Alert View delegate

- (void)actionSheet:(ActionSheet *)ActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
  {
  sCurrentActionSheet = nil;
  _clickInProgress = YES;
  _clickBlock(ActionSheet, buttonIndex);
  _clickInProgress = NO;
  }

- (void)willPresentActionSheet:(ActionSheet *)ActionSheet
  {
  sCurrentActionSheet = ActionSheet;
  }

- (void)actionSheet:(ActionSheet *)ActionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  sCurrentActionSheet = nil;
  }

- (void)actionSheet:(ActionSheet *)ActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  [[NSNotificationCenter defaultCenter] postNotificationName:ActionSheetDidDismissNotification object:ActionSheet 
    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:buttonIndex] forKey:ActionSheetButtonIndexUserInfo]];
  }

@end

@implementation ActionSheetRedirectDelegate

- (id)initWithDelegate:(id)delegate;
  {
  self = [super init];
  if (self)
    {
    _delegate = delegate;

    _flags.delegateClickedButtonAtIndex = [_delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)];
    _flags.delegateCancel = [_delegate respondsToSelector:@selector(actionSheetCancel:)];
    _flags.delegateWillPresent = [_delegate respondsToSelector:@selector(willPresentActionSheet:)];
    _flags.delegateDidPresent = [_delegate respondsToSelector:@selector(didPresentActionSheet:)];
    _flags.delegateWillDismiss = [_delegate respondsToSelector:@selector(actionSheet:illDismissWithButtonIndex:)];
    _flags.delegateDidDismiss = [_delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)];
    }
    
  return self;
  }

- (void)notifyCloseAlert:(ActionSheet*)alert
  {
  if (!_clickInProgress)
    {
    [self actionSheet:alert clickedButtonAtIndex:kActionSheetCancelButtonIndex];
    sCurrentActionSheet = nil;
    }
  }

#pragma mark Alert View delegate

- (void)actionSheet:(ActionSheet *)ActionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
  {
  if (_flags.delegateClickedButtonAtIndex)
    {
    sCurrentActionSheet = nil;
    _clickInProgress = YES;
    [_delegate actionSheet:ActionSheet clickedButtonAtIndex:buttonIndex];
    _clickInProgress = NO;
    }
  }

- (void)ActionSheetCancel:(ActionSheet *)ActionSheet
  {
  if (_flags.delegateCancel)
    {
    [_delegate ActionSheetCancel:ActionSheet];
    }
  }

- (void)willPresentActionSheet:(ActionSheet *)ActionSheet
  {
  if (_flags.delegateWillPresent)
    {
    [_delegate willPresentActionSheet:ActionSheet];
    }
  sCurrentActionSheet = ActionSheet;
  }
  
- (void)didPresentActionSheet:(ActionSheet *)ActionSheet
  {
  if (_flags.delegateDidPresent)
    {
    [_delegate didPresentActionSheet:ActionSheet];
    }
  }

- (void)actionSheet:(ActionSheet *)ActionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  sCurrentActionSheet = nil;
  if (_flags.delegateWillDismiss)
    {
    [_delegate actionSheet:ActionSheet willDismissWithButtonIndex:buttonIndex];
    }
  }
  
- (void)actionSheet:(ActionSheet *)ActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  if (_flags.delegateDidDismiss)
    {
    [_delegate actionSheet:ActionSheet didDismissWithButtonIndex:buttonIndex];
    }
  [[NSNotificationCenter defaultCenter] postNotificationName:ActionSheetDidDismissNotification object:ActionSheet 
    userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:buttonIndex] forKey:ActionSheetButtonIndexUserInfo]];
  }

@end

