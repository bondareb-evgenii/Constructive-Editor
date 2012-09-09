//
//  ReinterpretActionHandler.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "ReinterpretActionHandler.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "ActionSheet.h"
#import "AlertView.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@interface ReinterpretActionHandler()
  {
  UIViewController* _viewController;
  NSString*         _segueName;
  __weak Assembly*         _assembly;
  }
@end

@interface ReinterpretActionHandler (UIActionSheetDelegate) <UIActionSheetDelegate>
@end

@implementation ReinterpretActionHandler

@synthesize assembly = _assembly;

- (id)initWithViewController:(UIViewController*)viewController andSegueToNextViewControllerName:(NSString*)segueName
  {
  self = [super init];
  if (self)
    {
    _viewController = viewController;
    _segueName = segueName;
    }
  return self;
  }
  
- (void)interpretAssembly:(Assembly*)assembly
  {
  _assembly = assembly;
  ActionSheet* interpretActionSheet = [[ActionSheet alloc]
           initWithTitle: NSLocalizedString(@"Interpret the assembly", @"Action sheet: title")
        clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
      {
      switch (buttonIndex)
        {
        case 0://Detach smaller parts
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBase = assembly;
          // Commit the change.
          [_assembly.managedObjectContext saveAndHandleError];
          [_viewController performSegueWithIdentifier:_segueName sender:nil];
          break;
          }
        case 1://Split to details
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:_assembly.managedObjectContext];
          [_assembly.type addDetailsInstalledObject:detail];
          // Commit the change.
          [_assembly.managedObjectContext saveAndHandleError];
          [_viewController performSegueWithIdentifier:_segueName sender:nil];
          break;
          }
        case 2://Rotate
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeRotation = assembly;
          // Commit the change.
          [_assembly.managedObjectContext saveAndHandleError];
          [_viewController performSegueWithIdentifier:_segueName sender:nil];
          break;
          }
        case 3://Transform
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeTransformation = assembly;
          // Commit the change.
          [_assembly.managedObjectContext saveAndHandleError];
          [_viewController performSegueWithIdentifier:_segueName sender:nil];
          break;
          }
        default:
          break;
        }
      }
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"Detach smaller parts", @"Action sheet: button"),
                        NSLocalizedString(@"Split to details", @"Action sheet: button"),
                        NSLocalizedString(@"Rotate", @"Action sheet: button"),
                        NSLocalizedString(@"Transform", @"Action sheet: button"),
                        nil];

  [interpretActionSheet showInView:_viewController.view];
  }
  
- (void)reinterpretAssembly:(Assembly*)assembly
  {
  _assembly = assembly;
  BOOL isAssemblySplit = _assembly.type.detailsInstalled.count && !_assembly.type.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != _assembly.type.assemblyBase;
  BOOL isAssemblyTransformed = nil != _assembly.type.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != _assembly.type.assemblyBeforeRotation;
  
  if (isAssemblySplit)
    {
    ActionSheet* reinterpretSplitActionSheet = [[ActionSheet alloc]
         initWithTitle: NSLocalizedString(@"The assembly is currently split to details. What would you like to do instead?", @"Action sheet: title")
              delegate: self
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"Detach smaller parts", @"Action sheet: button"),
                        NSLocalizedString(@"Rotate", @"Action sheet: button"),
                        NSLocalizedString(@"Transform", @"Action sheet: button"),
                        nil];
    [reinterpretSplitActionSheet showInView:_viewController.view];
    }
  else if (arePartsDetachedFromAssembly)
    {
    ActionSheet* reinterpretDetachedActionSheet = [[ActionSheet alloc]
         initWithTitle: NSLocalizedString(@"Smaller parts are currently detached from the assembly. What would you like to do instead?", @"Action sheet: title")
              delegate: self
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"Split to details", @"Action sheet: button"),
                        NSLocalizedString(@"Rotate", @"Action sheet: button"),
                        NSLocalizedString(@"Transform", @"Action sheet: button"),
                        nil];
    [reinterpretDetachedActionSheet showInView:_viewController.view];
    }
  else if (isAssemblyTransformed)
    {
    ActionSheet* reinterpretTransformedActionSheet = [[ActionSheet alloc]
         initWithTitle: NSLocalizedString(@"The assembly is currently transformed. What would you like to do instead?", @"Action sheet: title")
              delegate: self
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"Detach smaller parts", @"Action sheet: button"),
                        NSLocalizedString(@"Split to details", @"Action sheet: button"),
                        NSLocalizedString(@"Rotate", @"Action sheet: button"),
                        nil];
    [reinterpretTransformedActionSheet showInView:_viewController.view];
    }
  else if (isAssemblyRotated)
    {
    ActionSheet* reinterpretRotatedActionSheet = [[ActionSheet alloc]
         initWithTitle: NSLocalizedString(@"The assembly is currently rotated. What would you like to do instead?", @"Action sheet: title")
              delegate: self
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"Detach smaller parts", @"Action sheet: button"),
                        NSLocalizedString(@"Split to details", @"Action sheet: button"),
                        NSLocalizedString(@"Transform", @"Action sheet: button"),
                        nil];
    [reinterpretRotatedActionSheet showInView:_viewController.view];
    }
  }
  
@end

@implementation ReinterpretActionHandler (UIActionSheetDelegate)

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
  {
  BOOL isAssemblySplit = _assembly.type.detailsInstalled.count && !_assembly.type.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != _assembly.type.assemblyBase;
  BOOL isAssemblyTransformed = nil != _assembly.type.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != _assembly.type.assemblyBeforeRotation;

  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  
  void (^commitReinterpret)() = ^()
    {
    [_assembly.managedObjectContext saveAndHandleError];
    [_viewController performSegueWithIdentifier:_segueName sender:nil];
    };
          
  if (isAssemblySplit)
    {
    switch (buttonIndex)
      {
      case 0://Detach smaller parts
        {
        NSString* actionOnReinterpretSplitAsDetached = [userDefaults stringForKey:preferredActionOnReinterpretSplitAsDetached];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBase = assembly;
          };
          
        void (^removeDetails)() = ^()
          {
          prepareReinterpret();
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          commitReinterpret();
          };
          
          void (^splitBaseAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBase.type.detailsInstalled = _assembly.type.detailsInstalled;
          _assembly.type.detailsInstalled = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretSplitAsDetached || [actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_AskMe])
          {
          ActionSheet* reinterpretSplitAsDetachedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently split to details. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeDetails();
                break;
              case 1:
                splitBaseAssembly();
                break;
              case 2://Use details as detached details
                prepareReinterpret();
                commitReinterpret();
                break;
              default:
                break;
              }
            }
           cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
      destructiveButtonTitle: NSLocalizedString(@"Remove them", @"Action sheet: button")
           otherButtonTitles: NSLocalizedString(@"Split the base assembly to them", @"Action sheet: button"),
                              NSLocalizedString(@"Use them as detached details", @"Action sheet: button"),
                              nil];
          [reinterpretSplitAsDetachedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_RemoveDetails])
          removeDetails();
        else if ([actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_SplitBaseAssembly])
          splitBaseAssembly();
        else if ([actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_UseDetailsAsDetachedParts])
          {
          prepareReinterpret();
          commitReinterpret();
          }
        break;
        }
      case 1://Rotate
        {
        NSString* actionOnReinterpretSplitAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretSplitAsRotatedOrTransformed];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeRotation = assembly;
          };
          
        void (^removeDetails)() = ^()
          {
          prepareReinterpret();
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          commitReinterpret();
          };
          
        void (^splitAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBeforeRotation.type.detailsInstalled = _assembly.type.detailsInstalled;
          _assembly.type.detailsInstalled = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretSplitAsRotatedOrTransformed || [actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
          {
          ActionSheet* reinterpretSplitAsRotatedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently split to details. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeDetails();
                break;
              case 1:
                splitAssembly();
                break;
              default:
                break;
              }
            }
           cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
      destructiveButtonTitle: NSLocalizedString(@"Remove them", @"Action sheet: button")
           otherButtonTitles: NSLocalizedString(@"Split the rotated assembly to them", @"Action sheet: button"),
                              nil];
          [reinterpretSplitAsRotatedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
          removeDetails();
        else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation])
          splitAssembly();
        break;
        }
      case 2://Transform
        {
        NSString* actionOnReinterpretSplitAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretSplitAsRotatedOrTransformed];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeTransformation = assembly;
          };
          
        void (^removeDetails)() = ^()
          {
          prepareReinterpret();
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          commitReinterpret();
          };
          
        void (^splitAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBeforeTransformation.type.detailsInstalled = _assembly.type.detailsInstalled;
          _assembly.type.detailsInstalled = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretSplitAsRotatedOrTransformed || [actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
          {
          ActionSheet* reinterpretSplitAsTransformedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently split to details. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeDetails();
                break;
              case 1:
                splitAssembly();
                break;
              default:
                break;
              }
            }
           cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
      destructiveButtonTitle: NSLocalizedString(@"Remove them", @"Action sheet: button")
           otherButtonTitles: NSLocalizedString(@"Split the transformed assembly to them", @"Action sheet: button"),
                              nil];
          [reinterpretSplitAsTransformedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
          removeDetails();
        else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation])
          splitAssembly();
        break;
        }
      default:
        break;
      }
    }
  else if (arePartsDetachedFromAssembly)
    {
    switch (buttonIndex)
      {
      case 0://Split to details
        {
        BOOL askAboutImplicitPartsDeletion = YES;
        NSNumber* askAboutImplicitPartsDeletionNumber = [userDefaults objectForKey:preferredAskAboutImplicitPartsDeletion];
        if (askAboutImplicitPartsDeletionNumber)
          askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
          
        void (^deleteAllAssemblies)() = ^()
          {
          if (!_assembly.type.detailsInstalled.count)//at list one detail should be present in split assembly
            {
            Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:_assembly.managedObjectContext];
            [_assembly.type addDetailsInstalledObject:detail];
            }
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBase];
          [_assembly.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          commitReinterpret();
          };
          
        AlertViewClickButtonBlock clickButtonBlock = ^(AlertView *alertView, NSInteger buttonIndex)
          {
          if (kAlertViewCloseButtonIndex != buttonIndex &&
              0 != buttonIndex)
            deleteAllAssemblies();
          };

        if (askAboutImplicitPartsDeletion)
          {
          AlertView* alert = [[AlertView alloc]
            initWithTitle:NSLocalizedString(@"Confirm removal", @"Alert view: title")
                  message:NSLocalizedString(@"Base assembly and all the smaller assemblies will be removed (details detached will still be available).", @"Alert view: message")
         clickButtonBlock:clickButtonBlock
        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert view: cancel")
        otherButtonTitles:NSLocalizedString(@"OK", @"Alert view: button"), nil];
        [alert show];
          }
        else
          deleteAllAssemblies();
        break;
        }
      case 1://Rotate
        {
        NSString* actionOnReinterpretDetachedAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretDetachedAsRotatedOrTransformed];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeRotation = assembly;
          };
          
        void (^removeAllParts)() = ^()
          {
          prepareReinterpret();
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          [_assembly.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBase];
          commitReinterpret();
          };
          
        void (^detachParts)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBeforeRotation.type.assemblyBase = _assembly.type.assemblyBase;
          _assembly.type.assemblyBase = nil;
          _assembly.type.assemblyBeforeRotation.type.assembliesInstalled = _assembly.type.assembliesInstalled;
          _assembly.type.assembliesInstalled = nil;
          _assembly.type.assemblyBeforeRotation.type.detailsInstalled = _assembly.type.detailsInstalled;
          _assembly.type.detailsInstalled = nil;
          commitReinterpret();
          };
          
        void (^useBaseAsRotatedAndRemoveOthers)() = ^()
          {
          //prepareReinterpret(); don't create an assemblyBeforeRotation
          _assembly.type.assemblyBeforeRotation = _assembly.type.assemblyBase;
          _assembly.type.assemblyBase = nil;
          [_assembly.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretDetachedAsRotatedOrTransformed || [actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
          {
          ActionSheet* reinterpretDetachedAsRotatedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"Smaller parts are currently detached from the assembly. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeAllParts();
                break;
              case 1:
                detachParts();
                break;
              case 2:
                useBaseAsRotatedAndRemoveOthers();
                break;
              default:
                break;
              }
            }
           cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
      destructiveButtonTitle: NSLocalizedString(@"Remove all parts", @"Action sheet: button")
           otherButtonTitles: NSLocalizedString(@"Detach them from the rotated assembly", @"Action sheet: button"),
                              NSLocalizedString(@"Use bigger part as rotated; remove others", @"Action sheet: button"),
                              nil];
          [reinterpretDetachedAsRotatedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
          removeAllParts();
        else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation])
          detachParts();
        else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation])
          useBaseAsRotatedAndRemoveOthers();
        break;
        }
      case 2://Transform
        {
        NSString* actionOnReinterpretDetachedAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretDetachedAsRotatedOrTransformed];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeTransformation = assembly;
          };
          
        void (^removeAllParts)() = ^()
          {
          prepareReinterpret();
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          [_assembly.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBase];
          commitReinterpret();
          };
          
        void (^detachFromAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBeforeTransformation.type.assemblyBase = _assembly.type.assemblyBase;
          _assembly.type.assemblyBase = nil;
          _assembly.type.assemblyBeforeTransformation.type.assembliesInstalled = _assembly.type.assembliesInstalled;
          _assembly.type.assembliesInstalled = nil;
          _assembly.type.assemblyBeforeTransformation.type.detailsInstalled = _assembly.type.detailsInstalled;
          _assembly.type.detailsInstalled = nil;
          commitReinterpret();
          };
          
        void (^useBaseAsTransformed)() = ^()
          {
          //prepareReinterpret(); don't create an assemblyBeforeTransformation
          _assembly.type.assemblyBeforeTransformation = _assembly.type.assemblyBase;
          _assembly.type.assemblyBase = nil;
          [_assembly.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          [_assembly.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
            {
            [_assembly.managedObjectContext deleteObject:obj];
            }];
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretDetachedAsRotatedOrTransformed || [actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
          {
          ActionSheet* reinterpretDetachedAsTransformedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"Smaller parts are currently detached from the assembly. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeAllParts();
                break;
              case 1:
                detachFromAssembly();
                break;
              case 2:
                useBaseAsTransformed();
                break;
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: NSLocalizedString(@"Remove all parts", @"Action sheet: button")
         otherButtonTitles: NSLocalizedString(@"Detach them from the transformed assembly", @"Action sheet: button"),
                            NSLocalizedString(@"Use bigger part as transformed; remove others", @"Action sheet: button"),
                            nil];
          [reinterpretDetachedAsTransformedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
          removeAllParts();
        else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation])
          detachFromAssembly();
        else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation])
          useBaseAsTransformed();
        break;
        }
      default:
        break;
      }
    }
  else if (isAssemblyRotated)
    {
    switch (buttonIndex)
      {
      case 0://Detach smaller parts
        {
        NSString* actionOnReinterpretRotatedOrTransformedAsDetached = [userDefaults stringForKey:preferredActionOnReinterpretRotatedOrTransformedAsDetached];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBase = assembly;
          };
          
        void (^removeAssembly)() = ^()
          {
          prepareReinterpret();
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBeforeRotation];
          commitReinterpret();
          };
          
        void (^rotateBaseAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBase.type.assemblyBeforeRotation = _assembly.type.assemblyBeforeRotation;
          commitReinterpret();
          };
          
        void (^useRotatedAsBase)() = ^()
          {
          //prepareReinterpret(); don't create an assemblyBase
          _assembly.type.assemblyBase = _assembly.type.assemblyBeforeRotation;
          _assembly.type.assemblyBeforeRotation = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretRotatedOrTransformedAsDetached || [actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
          {
          ActionSheet* reinterpretSplitAsDetachedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently rotated. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeAssembly();
                break;
              case 1:
                rotateBaseAssembly();
                break;
              case 2:
                useRotatedAsBase();
                break;
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: NSLocalizedString(@"Remove the rotated assembly", @"Action sheet: button")
         otherButtonTitles: NSLocalizedString(@"Rotate the bigger part", @"Action sheet: button"),
                            NSLocalizedString(@"Use rotated assembly as a bigger part", @"Action sheet: button"),
                            nil];
          [reinterpretSplitAsDetachedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
          removeAssembly();
        else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly])
          rotateBaseAssembly();
        else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase])
          useRotatedAsBase();
        break;
        }
      case 1://Split to details
        {
        BOOL askAboutImplicitPartsDeletion = YES;
        NSNumber* askAboutImplicitPartsDeletionNumber = [userDefaults objectForKey:preferredAskAboutImplicitPartsDeletion];
        if (askAboutImplicitPartsDeletionNumber)
          askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
          
        void (^removeAssembly)() = ^()
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:_assembly.managedObjectContext];
          [_assembly.type addDetailsInstalledObject:detail];
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBeforeRotation];
          commitReinterpret();
          };
          
        AlertViewClickButtonBlock clickButtonBlock = ^(AlertView *alertView, NSInteger buttonIndex)
          {
          if (kAlertViewCloseButtonIndex != buttonIndex &&
              0 != buttonIndex)
            removeAssembly();
          };

        if (askAboutImplicitPartsDeletion)
          {
          AlertView* alert = [[AlertView alloc]
            initWithTitle:NSLocalizedString(@"Confirm removal", @"Alert view: title")
                  message:NSLocalizedString(@"Rotated assembly will be removed.", @"Alert view: message")
         clickButtonBlock:clickButtonBlock
        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert view: cancel")
        otherButtonTitles:NSLocalizedString(@"OK", @"Alert view: button"), nil];
        [alert show];
          }
        else
          {
          removeAssembly();
          }
        break;
        }
      case 2://Transform
        {
        NSString* actionOnReinterpretRotatedAsTransformedAndViceVersa = [userDefaults stringForKey:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeTransformation = assembly;
          };
          
        void (^removeAssembly)() = ^()
          {
          prepareReinterpret();
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBeforeRotation];
          commitReinterpret();
          };
          
        void (^transformRotatedAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBeforeTransformation.type.assemblyBeforeRotation = _assembly.type.assemblyBeforeRotation;
          _assembly.type.assemblyBeforeRotation = nil;
          commitReinterpret();
          };
          
        void (^useRotatedAsTransformed)() = ^()
          {
          //prepareReinterpret(); don't create an assemblyBeforTransformation
          _assembly.type.assemblyBeforeTransformation = _assembly.type.assemblyBeforeRotation;
          _assembly.type.assemblyBeforeRotation = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretRotatedAsTransformedAndViceVersa || [actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
          {
          ActionSheet* reinterpretDetachedAsRotatedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently rotated. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeAssembly();
                break;
              case 1:
                transformRotatedAssembly();
                break;
              case 2:
                useRotatedAsTransformed();
                break;
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: NSLocalizedString(@"Remove the rotated assembly", @"Action sheet: button")
         otherButtonTitles: NSLocalizedString(@"Transform the rotated assembly", @"Action sheet: button"),
                            NSLocalizedString(@"Use rotated assembly as transformed one", @"Action sheet: button"),
                            nil];
          [reinterpretDetachedAsRotatedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
          removeAssembly();
        else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly])
          transformRotatedAssembly();
        else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated])
          useRotatedAsTransformed();
        break;
        }
      default:
        break;
      }
    }
  else if (isAssemblyTransformed)
    {
    switch (buttonIndex)
      {
      case 0://Detach smaller parts
        {
        NSString* actionOnReinterpretRotatedOrTransformedAsDetached = [userDefaults stringForKey:preferredActionOnReinterpretRotatedOrTransformedAsDetached];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBase = assembly;
          };
          
        void (^removeAssembly)() = ^()
          {
          prepareReinterpret();
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBeforeTransformation];
          commitReinterpret();
          };
          
        void (^transformBaseAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBase.type.assemblyBeforeTransformation = _assembly.type.assemblyBeforeTransformation;
          commitReinterpret();
          };
          
        void (^useTransformedAsBase)() = ^()
          {
          //prepareReinterpret(); don't create an assemblyBase!!!
          _assembly.type.assemblyBase = _assembly.type.assemblyBeforeTransformation;
          _assembly.type.assemblyBeforeTransformation = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretRotatedOrTransformedAsDetached || [actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
          {
          ActionSheet* reinterpretSplitAsDetachedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently transformed. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeAssembly();
                break;
              case 1:
                transformBaseAssembly();
                break;
              case 2:
                useTransformedAsBase();
                break;
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: NSLocalizedString(@"Remove the transformed assembly", @"Action sheet: button")
         otherButtonTitles: NSLocalizedString(@"Transform the bigger part", @"Action sheet: button"),
                            NSLocalizedString(@"Use transformed assembly as a bigger part", @"Action sheet: button"),
                            nil];
          [reinterpretSplitAsDetachedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
          removeAssembly();
        else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly])
          transformBaseAssembly();
        else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase])
          useTransformedAsBase();
        break;
        }
      case 1://Split to details
        {
        BOOL askAboutImplicitPartsDeletion = YES;
        NSNumber* askAboutImplicitPartsDeletionNumber = [userDefaults objectForKey:preferredAskAboutImplicitPartsDeletion];
        if (askAboutImplicitPartsDeletionNumber)
          askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
        
        void (^removeAssembly)() = ^()
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:_assembly.managedObjectContext];
          [_assembly.type addDetailsInstalledObject:detail];
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBeforeTransformation];
          commitReinterpret();
          };
          
        AlertViewClickButtonBlock clickButtonBlock = ^(AlertView *alertView, NSInteger buttonIndex)
          {
          if (kAlertViewCloseButtonIndex != buttonIndex &&
              0 != buttonIndex)
            removeAssembly();
          };

        if (askAboutImplicitPartsDeletion)
          {
          AlertView* alert = [[AlertView alloc]
            initWithTitle:NSLocalizedString(@"Confirm removal", @"Alert view: title")
                  message:NSLocalizedString(@"Transformed assembly will be removed.", @"Alert view: message")
         clickButtonBlock:clickButtonBlock
        cancelButtonTitle:NSLocalizedString(@"Cancel", @"Alert view: cancel")
        otherButtonTitles:NSLocalizedString(@"OK", @"Alert view: button"), nil];
        [alert show];
          }
        else
          {
          removeAssembly();
          }
        break;
        }
      case 2://Rotate
        {
        NSString* actionOnReinterpretRotatedAsTransformedAndViceVersa = [userDefaults stringForKey:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa];
        
        void (^prepareReinterpret)() = ^()
          {
          Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:_assembly.managedObjectContext];
          AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:self.assembly.managedObjectContext];
          assembly.type = assemblyType;
          _assembly.type.assemblyBeforeRotation = assembly;
          };
          
        void (^removeAssembly)() = ^()
          {
          prepareReinterpret();
          [_assembly.managedObjectContext deleteObject:_assembly.type.assemblyBeforeTransformation];
          commitReinterpret();
          };
          
        void (^transformRotatedAssembly)() = ^()
          {
          prepareReinterpret();
          _assembly.type.assemblyBeforeRotation.type.assemblyBeforeTransformation = _assembly.type.assemblyBeforeTransformation;
          _assembly.type.assemblyBeforeTransformation = nil;
          commitReinterpret();
          };
          
        void (^useTransformedAsRotated)() = ^()
          {
          //prepareReinterpret(); don't create an assemblyBeforeRotation
          _assembly.type.assemblyBeforeRotation = _assembly.type.assemblyBeforeTransformation;
          _assembly.type.assemblyBeforeTransformation = nil;
          commitReinterpret();
          };
          
        if (nil == actionOnReinterpretRotatedAsTransformedAndViceVersa || [actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
          {
          ActionSheet* reinterpretDetachedAsRotatedActionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"The assembly is currently transformed. Would you like to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0:
                removeAssembly();
                break;
              case 1:
                transformRotatedAssembly();
                break;
              case 2:
                useTransformedAsRotated();
                break;
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: NSLocalizedString(@"Remove the transformed assembly", @"Action sheet: button")
         otherButtonTitles: NSLocalizedString(@"Transform the rotated assembly", @"Action sheet: button"),
                            NSLocalizedString(@"Use transformed assembly as rotated one", @"Action sheet: button"),
                            nil];
          [reinterpretDetachedAsRotatedActionSheet showInView:_viewController.view];
          }
        else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
          removeAssembly();
        else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly])
          transformRotatedAssembly();
        else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated])
          useTransformedAsRotated();
        break;
        }
      default:
        break;
      }
    }
  }

@end
