//
//  StandardActionsPerformer.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "StandardActionsPerformer.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "ActionSheet.h"
#import "AlertView.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@implementation StandardActionsPerformer
  
+ (void)performStandardActionNamed:(NSString*)standardActionName onAssembly:(Assembly*)assemblyToInterpret inView:(UIView*)view withCompletionBlock:(void(^)(BOOL actionPerformed)) completion
  {
  BOOL isAssemblySplit = assemblyToInterpret.type.detailsInstalled.count && !assemblyToInterpret.type.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != assemblyToInterpret.type.assemblyBase;
  BOOL isAssemblyTransformed = nil != assemblyToInterpret.type.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != assemblyToInterpret.type.assemblyBeforeRotation;
  BOOL isAnyActionPerformedOnAssembly = isAssemblySplit || arePartsDetachedFromAssembly || isAssemblyTransformed || isAssemblyRotated;
  
  NSManagedObjectContext* managedObjectContext = assemblyToInterpret.managedObjectContext;
  
  NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
  
  void (^commitReinterpret)() = ^()
    {
    [managedObjectContext saveAndHandleError];
    completion(YES);
    };
          
  if (isAssemblySplit)
    {
    if ([standardActionOnAssembly_DetachSmallerParts isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretSplitAsDetached = [userDefaults stringForKey:preferredActionOnReinterpretSplitAsDetached];
      if (nil == actionOnReinterpretSplitAsDetached)
      actionOnReinterpretSplitAsDetached = preferredActionOnReinterpretSplitAsDetached_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBase = assembly;
        };
        
      void (^removeDetails)() = ^()
        {
        prepareReinterpret();
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
        void (^splitBaseAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBase.type.detailsInstalled = assemblyToInterpret.type.detailsInstalled;
        assemblyToInterpret.type.detailsInstalled = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_AskMe])
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
        [reinterpretSplitAsDetachedActionSheet showInView:view];
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
      }
    else if ([standardActionOnAssembly_Rotate isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretSplitAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretSplitAsRotatedOrTransformed];
      if (nil == actionOnReinterpretSplitAsRotatedOrTransformed)
        actionOnReinterpretSplitAsRotatedOrTransformed = preferredActionOnReinterpretSplitAsRotatedOrTransformed_Default;
        
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBeforeRotation = assembly;
        };
        
      void (^removeDetails)() = ^()
        {
        prepareReinterpret();
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      void (^splitAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBeforeRotation.type.detailsInstalled = assemblyToInterpret.type.detailsInstalled;
        assemblyToInterpret.type.detailsInstalled = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
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
        [reinterpretSplitAsRotatedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
        removeDetails();
      else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation])
        splitAssembly();
      }
    else if ([standardActionOnAssembly_Transform isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretSplitAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretSplitAsRotatedOrTransformed];
      if (nil == actionOnReinterpretSplitAsRotatedOrTransformed)
        actionOnReinterpretSplitAsRotatedOrTransformed = preferredActionOnReinterpretSplitAsRotatedOrTransformed_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBeforeTransformation = assembly;
        };
        
      void (^removeDetails)() = ^()
        {
        prepareReinterpret();
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      void (^splitAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBeforeTransformation.type.detailsInstalled = assemblyToInterpret.type.detailsInstalled;
        assemblyToInterpret.type.detailsInstalled = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
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
        [reinterpretSplitAsTransformedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
        removeDetails();
      else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_SplitAssemblyBeforeRotationOrTransformation])
        splitAssembly();
      }
    }
  else if (arePartsDetachedFromAssembly)
    {
    if ([standardActionOnAssembly_SplitToDetails isEqualToString:standardActionName])
      {
      BOOL askAboutImplicitPartsDeletion = preferredAskAboutImplicitPartsDeletion_Default;
      NSNumber* askAboutImplicitPartsDeletionNumber = [userDefaults objectForKey:preferredAskAboutImplicitPartsDeletion];
      if (askAboutImplicitPartsDeletionNumber)
        askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
        
      void (^deleteAllAssemblies)() = ^()
        {
        while (assemblyToInterpret.type.detailsInstalled.count < 2)//at list two details should be present in split assembly
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
          [assemblyToInterpret.type addDetailsInstalledObject:detail];
          }
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBase];
        [assemblyToInterpret.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
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
      }
    else if ([standardActionOnAssembly_Rotate isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretDetachedAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretDetachedAsRotatedOrTransformed];
      if (nil == actionOnReinterpretDetachedAsRotatedOrTransformed)
        actionOnReinterpretDetachedAsRotatedOrTransformed = preferredActionOnReinterpretDetachedAsRotatedOrTransformed_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBeforeRotation = assembly;
        };
        
      void (^removeAllParts)() = ^()
        {
        prepareReinterpret();
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyToInterpret.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBase];
        commitReinterpret();
        };
        
      void (^detachParts)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBeforeRotation.type.assemblyBase = assemblyToInterpret.type.assemblyBase;
        assemblyToInterpret.type.assemblyBase = nil;
        assemblyToInterpret.type.assemblyBeforeRotation.type.assembliesInstalled = assemblyToInterpret.type.assembliesInstalled;
        assemblyToInterpret.type.assembliesInstalled = nil;
        assemblyToInterpret.type.assemblyBeforeRotation.type.detailsInstalled = assemblyToInterpret.type.detailsInstalled;
        assemblyToInterpret.type.detailsInstalled = nil;
        commitReinterpret();
        };
        
      void (^useBaseAsRotatedAndRemoveOthers)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforeRotation
        assemblyToInterpret.type.assemblyBeforeRotation = assemblyToInterpret.type.assemblyBase;
        assemblyToInterpret.type.assemblyBase = nil;
        [assemblyToInterpret.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
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
        [reinterpretDetachedAsRotatedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
        removeAllParts();
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation])
        detachParts();
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation])
        useBaseAsRotatedAndRemoveOthers();
      }
    else if ([standardActionOnAssembly_Transform isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretDetachedAsRotatedOrTransformed = [userDefaults stringForKey:preferredActionOnReinterpretDetachedAsRotatedOrTransformed];
      if (nil == actionOnReinterpretDetachedAsRotatedOrTransformed)
        actionOnReinterpretDetachedAsRotatedOrTransformed = preferredActionOnReinterpretDetachedAsRotatedOrTransformed_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBeforeTransformation = assembly;
        };
        
      void (^removeAllParts)() = ^()
        {
        prepareReinterpret();
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyToInterpret.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBase];
        commitReinterpret();
        };
        
      void (^detachFromAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBeforeTransformation.type.assemblyBase = assemblyToInterpret.type.assemblyBase;
        assemblyToInterpret.type.assemblyBase = nil;
        assemblyToInterpret.type.assemblyBeforeTransformation.type.assembliesInstalled = assemblyToInterpret.type.assembliesInstalled;
        assemblyToInterpret.type.assembliesInstalled = nil;
        assemblyToInterpret.type.assemblyBeforeTransformation.type.detailsInstalled = assemblyToInterpret.type.detailsInstalled;
        assemblyToInterpret.type.detailsInstalled = nil;
        commitReinterpret();
        };
        
      void (^useBaseAsTransformed)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforeTransformation
        assemblyToInterpret.type.assemblyBeforeTransformation = assemblyToInterpret.type.assemblyBase;
        assemblyToInterpret.type.assemblyBase = nil;
        [assemblyToInterpret.type.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyToInterpret.type.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
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
        [reinterpretDetachedAsTransformedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
        removeAllParts();
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_DetachFromAssemblyBeforeRotationOrTransformation])
        detachFromAssembly();
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_UseBaseAssemblyAsAssemblyBeforeRotationOrTransformation])
        useBaseAsTransformed();
      }
    }
  else if (isAssemblyRotated)
    {
    if ([standardActionOnAssembly_DetachSmallerParts isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretRotatedOrTransformedAsDetached = [userDefaults stringForKey:preferredActionOnReinterpretRotatedOrTransformedAsDetached];
      if (nil == actionOnReinterpretRotatedOrTransformedAsDetached)
        actionOnReinterpretRotatedOrTransformedAsDetached = preferredActionOnReinterpretRotatedOrTransformedAsDetached_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBase = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBeforeRotation];
        commitReinterpret();
        };
        
      void (^rotateBaseAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBase.type.assemblyBeforeRotation = assemblyToInterpret.type.assemblyBeforeRotation;
        commitReinterpret();
        };
        
      void (^useRotatedAsBase)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBase
        assemblyToInterpret.type.assemblyBase = assemblyToInterpret.type.assemblyBeforeRotation;
        assemblyToInterpret.type.assemblyBeforeRotation = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
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
        [reinterpretSplitAsDetachedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly])
        rotateBaseAssembly();
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase])
        useRotatedAsBase();
      }
    else if ([standardActionOnAssembly_SplitToDetails isEqualToString:standardActionName])
      {
      BOOL askAboutImplicitPartsDeletion = preferredAskAboutImplicitPartsDeletion_Default;
      NSNumber* askAboutImplicitPartsDeletionNumber = [userDefaults objectForKey:preferredAskAboutImplicitPartsDeletion];
      if (askAboutImplicitPartsDeletionNumber)
        askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
        
      void (^removeAssembly)() = ^()
        {
        while (assemblyToInterpret.type.detailsInstalled.count < 2)//at list two details should be present in split assembly
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
          [assemblyToInterpret.type addDetailsInstalledObject:detail];
          }
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBeforeRotation];
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
      }
    else if ([standardActionOnAssembly_Transform isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretRotatedAsTransformedAndViceVersa = [userDefaults stringForKey:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa];
      if (nil == actionOnReinterpretRotatedAsTransformedAndViceVersa)
        actionOnReinterpretRotatedAsTransformedAndViceVersa = preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_Default;
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBeforeTransformation = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBeforeRotation];
        commitReinterpret();
        };
        
      void (^transformRotatedAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBeforeTransformation.type.assemblyBeforeRotation = assemblyToInterpret.type.assemblyBeforeRotation;
        assemblyToInterpret.type.assemblyBeforeRotation = nil;
        commitReinterpret();
        };
        
      void (^useRotatedAsTransformed)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforTransformation
        assemblyToInterpret.type.assemblyBeforeTransformation = assemblyToInterpret.type.assemblyBeforeRotation;
        assemblyToInterpret.type.assemblyBeforeRotation = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
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
        [reinterpretDetachedAsRotatedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly])
        transformRotatedAssembly();
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated])
        useRotatedAsTransformed();
      }
    }
  else if (isAssemblyTransformed)
    {
    if ([standardActionOnAssembly_DetachSmallerParts isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretRotatedOrTransformedAsDetached = [userDefaults stringForKey:preferredActionOnReinterpretRotatedOrTransformedAsDetached];
      if (nil == actionOnReinterpretRotatedOrTransformedAsDetached)
        actionOnReinterpretRotatedOrTransformedAsDetached = preferredActionOnReinterpretRotatedOrTransformedAsDetached_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBase = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBeforeTransformation];
        commitReinterpret();
        };
        
      void (^transformBaseAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBase.type.assemblyBeforeTransformation = assemblyToInterpret.type.assemblyBeforeTransformation;
        commitReinterpret();
        };
        
      void (^useTransformedAsBase)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBase!!!
        assemblyToInterpret.type.assemblyBase = assemblyToInterpret.type.assemblyBeforeTransformation;
        assemblyToInterpret.type.assemblyBeforeTransformation = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
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
        [reinterpretSplitAsDetachedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RotateOrTransformBaseAssembly])
        transformBaseAssembly();
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_UseAssemblyBeforeRotationOrTransformationAsBase])
        useTransformedAsBase();
      }
    else if ([standardActionOnAssembly_SplitToDetails isEqualToString:standardActionName])
      {
      BOOL askAboutImplicitPartsDeletion = preferredAskAboutImplicitPartsDeletion_Default;
      NSNumber* askAboutImplicitPartsDeletionNumber = [userDefaults objectForKey:preferredAskAboutImplicitPartsDeletion];
      if (askAboutImplicitPartsDeletionNumber)
        askAboutImplicitPartsDeletion = [askAboutImplicitPartsDeletionNumber boolValue];
      
      void (^removeAssembly)() = ^()
        {
        while (assemblyToInterpret.type.detailsInstalled.count < 2)//at list two details should be present in split assembly
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
          [assemblyToInterpret.type addDetailsInstalledObject:detail];
          }
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBeforeTransformation];
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
      }
    else if ([standardActionOnAssembly_Rotate isEqualToString:standardActionName])
      {
      NSString* actionOnReinterpretRotatedAsTransformedAndViceVersa = [userDefaults stringForKey:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa];
      if (nil == actionOnReinterpretRotatedAsTransformedAndViceVersa)
        actionOnReinterpretRotatedAsTransformedAndViceVersa = preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_Default;
      
      void (^prepareReinterpret)() = ^()
        {
        Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
        AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
        assembly.type = assemblyType;
        assemblyToInterpret.type.assemblyBeforeRotation = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyToInterpret.type.assemblyBeforeTransformation];
        commitReinterpret();
        };
        
      void (^transformRotatedAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyToInterpret.type.assemblyBeforeRotation.type.assemblyBeforeTransformation = assemblyToInterpret.type.assemblyBeforeTransformation;
        assemblyToInterpret.type.assemblyBeforeTransformation = nil;
        commitReinterpret();
        };
        
      void (^useTransformedAsRotated)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforeRotation
        assemblyToInterpret.type.assemblyBeforeRotation = assemblyToInterpret.type.assemblyBeforeTransformation;
        assemblyToInterpret.type.assemblyBeforeTransformation = nil;
        commitReinterpret();
        };
        
      if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
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
        [reinterpretDetachedAsRotatedActionSheet showInView:view];
        }
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_TransformeOrRotateRotatedOrTransformedAssembly])
        transformRotatedAssembly();
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_UseRotatedOrTransformedAssemblyAsTransformedOrRotated])
        useTransformedAsRotated();
      }
    }
  else if (!isAnyActionPerformedOnAssembly)
    {
    if ([standardActionOnAssembly_DetachSmallerParts isEqualToString:standardActionName])
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
      AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
      assembly.type = assemblyType;
      assemblyToInterpret.type.assemblyBase = assembly;
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    else if ([standardActionOnAssembly_SplitToDetails isEqualToString:standardActionName])
      {
      while (assemblyToInterpret.type.detailsInstalled.count < 2)//at list two details should be present in split assembly
        {
        Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
        [assemblyToInterpret.type addDetailsInstalledObject:detail];
        }
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    else if ([standardActionOnAssembly_Rotate isEqualToString:standardActionName])
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
      AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
      assembly.type = assemblyType;
      assemblyToInterpret.type.assemblyBeforeRotation = assembly;
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    else if ([standardActionOnAssembly_Transform isEqualToString:standardActionName])
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
      AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
      assembly.type = assemblyType;
      assemblyToInterpret.type.assemblyBeforeTransformation = assembly;
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    }
  else
    {
    completion(NO);
    return;
    }
  }

@end
