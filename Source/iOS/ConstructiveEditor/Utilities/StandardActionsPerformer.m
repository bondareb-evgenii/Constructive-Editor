//
//  StandardActionsPerformer.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "StandardActionsPerformer.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "Detail.h"
#import "DetailType.h"
#import "ActionSheet.h"
#import "AlertView.h"
#import "NSManagedObjectContextExtension.h"
#import "PreferencesKeys.h"

@implementation StandardActionsPerformer

+ (BOOL)isAnythingChangedInAssemblyType:(AssemblyType*)assemblyTypeToCheck
  {
  BOOL isAnythingChanged = NO;
  if (assemblyTypeToCheck.assemblyBase.type.pictureToShow ||
      assemblyTypeToCheck.assemblyBeforeRotation.type.pictureToShow ||
      assemblyTypeToCheck.assemblyBeforeTransformation.type.pictureToShow)
    isAnythingChanged = YES;
  else
    {
    for (Assembly* assembly in assemblyTypeToCheck.assembliesInstalled)
      if (assembly.type.pictureToShow)
        {
        isAnythingChanged = YES;
        break;
        }
    for (Detail* detail in assemblyTypeToCheck.detailsInstalled)
      if (detail.type.pictureToShow)
        {
        isAnythingChanged = YES;
        break;
        }
    }
  return isAnythingChanged;
  }
  
+ (void)performStandardActionNamed:(NSString*)standardActionName onAssemblyType:(AssemblyType*)assemblyTypeToInterpret inView:(UIView*)view withCompletionBlock:(void(^)(BOOL actionPerformed)) completion
  {
  BOOL isAssemblySplit = assemblyTypeToInterpret.detailsInstalled.count && !assemblyTypeToInterpret.assemblyBase;
  BOOL arePartsDetachedFromAssembly = nil != assemblyTypeToInterpret.assemblyBase;
  BOOL isAssemblyTransformed = nil != assemblyTypeToInterpret.assemblyBeforeTransformation;
  BOOL isAssemblyRotated = nil != assemblyTypeToInterpret.assemblyBeforeRotation;
  BOOL isAnyActionPerformedOnAssembly = isAssemblySplit || arePartsDetachedFromAssembly || isAssemblyTransformed || isAssemblyRotated;
  
  NSManagedObjectContext* managedObjectContext = assemblyTypeToInterpret.managedObjectContext;
  
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
        assemblyTypeToInterpret.assemblyBase = assembly;
        };
        
      void (^removeDetails)() = ^()
        {
        prepareReinterpret();
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
        void (^splitBaseAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBase.type.detailsInstalled = assemblyTypeToInterpret.detailsInstalled;
        assemblyTypeToInterpret.detailsInstalled = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_RemoveDetails])
        removeDetails();
      else if ([actionOnReinterpretSplitAsDetached isEqualToString:preferredActionOnReinterpretSplitAsDetached_AskMe])
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
        assemblyTypeToInterpret.assemblyBeforeRotation = assembly;
        };
        
      void (^removeDetails)() = ^()
        {
        prepareReinterpret();
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      void (^splitAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBeforeRotation.type.detailsInstalled = assemblyTypeToInterpret.detailsInstalled;
        assemblyTypeToInterpret.detailsInstalled = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
        removeDetails();
      else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
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
        assemblyTypeToInterpret.assemblyBeforeTransformation = assembly;
        };
        
      void (^removeDetails)() = ^()
        {
        prepareReinterpret();
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      void (^splitAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBeforeTransformation.type.detailsInstalled = assemblyTypeToInterpret.detailsInstalled;
        assemblyTypeToInterpret.detailsInstalled = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_RemoveDetails])
        removeDetails();
      else if ([actionOnReinterpretSplitAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretSplitAsRotatedOrTransformed_AskMe])
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
        if (!assemblyTypeToInterpret.detailsInstalled.count)//at list two details should be present in split assembly, but we don't actually know wheter those two details should have the same type or different ones so we will create only one detail for user automatically
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
          [assemblyTypeToInterpret addDetailsInstalledObject:detail];
          }
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBase];
        [assemblyTypeToInterpret.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };

      if ([self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] && askAboutImplicitPartsDeletion)
        {
        ActionSheet* reinterpretActionSheet = [[ActionSheet alloc]
           initWithTitle: NSLocalizedString(@"Smaller parts are currently detached from the assembly. Splitting it to details instead needs the base assembly and all the smaller assemblies to be removed. Would you like to:", @"Action sheet: title")
        clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
          {
          switch (buttonIndex)
            {
            case 0:
              deleteAllAssemblies();
              break;
            default:
              break;
            }
          }
       cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
  destructiveButtonTitle: NSLocalizedString(@"Remove all the assemblies", @"Action sheet: button")
       otherButtonTitles: nil];
        [reinterpretActionSheet showInView:view];
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
        assemblyTypeToInterpret.assemblyBeforeRotation = assembly;
        };
        
      void (^removeAllParts)() = ^()
        {
        prepareReinterpret();
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyTypeToInterpret.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBase];
        commitReinterpret();
        };
        
      void (^detachParts)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBeforeRotation.type.assemblyBase = assemblyTypeToInterpret.assemblyBase;
        assemblyTypeToInterpret.assemblyBase = nil;
        assemblyTypeToInterpret.assemblyBeforeRotation.type.assembliesInstalled = assemblyTypeToInterpret.assembliesInstalled;
        assemblyTypeToInterpret.assembliesInstalled = nil;
        assemblyTypeToInterpret.assemblyBeforeRotation.type.detailsInstalled = assemblyTypeToInterpret.detailsInstalled;
        assemblyTypeToInterpret.detailsInstalled = nil;
        commitReinterpret();
        };
        
      void (^useBaseAsRotatedAndRemoveOthers)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforeRotation
        assemblyTypeToInterpret.assemblyBeforeRotation = assemblyTypeToInterpret.assemblyBase;
        assemblyTypeToInterpret.assemblyBase = nil;
        [assemblyTypeToInterpret.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
        removeAllParts();
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
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
        assemblyTypeToInterpret.assemblyBeforeTransformation = assembly;
        };
        
      void (^removeAllParts)() = ^()
        {
        prepareReinterpret();
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyTypeToInterpret.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBase];
        commitReinterpret();
        };
        
      void (^detachFromAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBeforeTransformation.type.assemblyBase = assemblyTypeToInterpret.assemblyBase;
        assemblyTypeToInterpret.assemblyBase = nil;
        assemblyTypeToInterpret.assemblyBeforeTransformation.type.assembliesInstalled = assemblyTypeToInterpret.assembliesInstalled;
        assemblyTypeToInterpret.assembliesInstalled = nil;
        assemblyTypeToInterpret.assemblyBeforeTransformation.type.detailsInstalled = assemblyTypeToInterpret.detailsInstalled;
        assemblyTypeToInterpret.detailsInstalled = nil;
        commitReinterpret();
        };
        
      void (^useBaseAsTransformed)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforeTransformation
        assemblyTypeToInterpret.assemblyBeforeTransformation = assemblyTypeToInterpret.assemblyBase;
        assemblyTypeToInterpret.assemblyBase = nil;
        [assemblyTypeToInterpret.assembliesInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        [assemblyTypeToInterpret.detailsInstalled enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
          {
          [managedObjectContext deleteObject:obj];
          }];
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_RemoveEverything])
        removeAllParts();
      else if ([actionOnReinterpretDetachedAsRotatedOrTransformed isEqualToString:preferredActionOnReinterpretDetachedAsRotatedOrTransformed_AskMe])
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
        assemblyTypeToInterpret.assemblyBase = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBeforeRotation];
        commitReinterpret();
        };
        
      void (^rotateBaseAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBase.type.assemblyBeforeRotation = assemblyTypeToInterpret.assemblyBeforeRotation;
        commitReinterpret();
        };
        
      void (^useRotatedAsBase)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBase
        assemblyTypeToInterpret.assemblyBase = assemblyTypeToInterpret.assemblyBeforeRotation;
        assemblyTypeToInterpret.assemblyBeforeRotation = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
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
        while (assemblyTypeToInterpret.detailsInstalled.count < 2)//at list two details should be present in split assembly
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
          [assemblyTypeToInterpret addDetailsInstalledObject:detail];
          }
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBeforeRotation];
        commitReinterpret();
        };

      if ([self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] && askAboutImplicitPartsDeletion)
        {
        ActionSheet* reinterpretActionSheet = [[ActionSheet alloc]
           initWithTitle: NSLocalizedString(@"The assembly is currently rotated. Splitting it to details instead needs the rotated assembly to be removed. Would you like to:", @"Action sheet: title")
        clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
          {
          switch (buttonIndex)
            {
            case 0:
              removeAssembly();
              break;
            default:
              break;
            }
          }
       cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
  destructiveButtonTitle: NSLocalizedString(@"Remove the rotated assembly", @"Action sheet: button")
       otherButtonTitles: nil];
        [reinterpretActionSheet showInView:view];
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
        assemblyTypeToInterpret.assemblyBeforeTransformation = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBeforeRotation];
        commitReinterpret();
        };
        
      void (^transformRotatedAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBeforeTransformation.type.assemblyBeforeRotation = assemblyTypeToInterpret.assemblyBeforeRotation;
        assemblyTypeToInterpret.assemblyBeforeRotation = nil;
        commitReinterpret();
        };
        
      void (^useRotatedAsTransformed)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforTransformation
        assemblyTypeToInterpret.assemblyBeforeTransformation = assemblyTypeToInterpret.assemblyBeforeRotation;
        assemblyTypeToInterpret.assemblyBeforeRotation = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe])
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
        assemblyTypeToInterpret.assemblyBase = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBeforeTransformation];
        commitReinterpret();
        };
        
      void (^transformBaseAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBase.type.assemblyBeforeTransformation = assemblyTypeToInterpret.assemblyBeforeTransformation;
        commitReinterpret();
        };
        
      void (^useTransformedAsBase)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBase!!!
        assemblyTypeToInterpret.assemblyBase = assemblyTypeToInterpret.assemblyBeforeTransformation;
        assemblyTypeToInterpret.assemblyBeforeTransformation = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedOrTransformedAsDetached isEqualToString:preferredActionOnReinterpretRotatedOrTransformedAsDetached_AskMe])
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
        while (assemblyTypeToInterpret.detailsInstalled.count < 2)//at list two details should be present in split assembly
          {
          Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
          [assemblyTypeToInterpret addDetailsInstalledObject:detail];
          }
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBeforeTransformation];
        commitReinterpret();
        };

      if ([self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] && askAboutImplicitPartsDeletion)
        {
        ActionSheet* reinterpretActionSheet = [[ActionSheet alloc]
           initWithTitle: NSLocalizedString(@"The assembly is currently transformed. Splitting it to details instead needs the transformed assembly to be removed. Would you like to:", @"Action sheet: title")
        clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
          {
          switch (buttonIndex)
            {
            case 0:
              removeAssembly();
              break;
            default:
              break;
            }
          }
       cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
  destructiveButtonTitle: NSLocalizedString(@"Remove the transformed assembly", @"Action sheet: button")
       otherButtonTitles: nil];
        [reinterpretActionSheet showInView:view];
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
        assemblyTypeToInterpret.assemblyBeforeRotation = assembly;
        };
        
      void (^removeAssembly)() = ^()
        {
        prepareReinterpret();
        [managedObjectContext deleteObject:assemblyTypeToInterpret.assemblyBeforeTransformation];
        commitReinterpret();
        };
        
      void (^transformRotatedAssembly)() = ^()
        {
        prepareReinterpret();
        assemblyTypeToInterpret.assemblyBeforeRotation.type.assemblyBeforeTransformation = assemblyTypeToInterpret.assemblyBeforeTransformation;
        assemblyTypeToInterpret.assemblyBeforeTransformation = nil;
        commitReinterpret();
        };
        
      void (^useTransformedAsRotated)() = ^()
        {
        //prepareReinterpret(); don't create an assemblyBeforeRotation
        assemblyTypeToInterpret.assemblyBeforeRotation = assemblyTypeToInterpret.assemblyBeforeTransformation;
        assemblyTypeToInterpret.assemblyBeforeTransformation = nil;
        commitReinterpret();
        };
        
      if (![self isAnythingChangedInAssemblyType:assemblyTypeToInterpret] || [actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_RemoveRotatedOrTransformedAssembly])
        removeAssembly();
      else if ([actionOnReinterpretRotatedAsTransformedAndViceVersa isEqualToString:preferredActionOnReinterpretRotatedAsTransformedAndViceVersa_AskMe])
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
      assemblyTypeToInterpret.assemblyBase = assembly;
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    else if ([standardActionOnAssembly_SplitToDetails isEqualToString:standardActionName])
      {
      while (assemblyTypeToInterpret.detailsInstalled.count < 2)//at list two details should be present in split assembly
        {
        Detail* detail = (Detail*)[NSEntityDescription insertNewObjectForEntityForName:@"Detail" inManagedObjectContext:managedObjectContext];
        [assemblyTypeToInterpret addDetailsInstalledObject:detail];
        }
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    else if ([standardActionOnAssembly_Rotate isEqualToString:standardActionName])
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
      AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
      assembly.type = assemblyType;
      assemblyTypeToInterpret.assemblyBeforeRotation = assembly;
      // Commit the change.
      [managedObjectContext saveAndHandleError];
      }
    else if ([standardActionOnAssembly_Transform isEqualToString:standardActionName])
      {
      Assembly* assembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
      AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
      assembly.type = assemblyType;
      assemblyTypeToInterpret.assemblyBeforeTransformation = assembly;
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
