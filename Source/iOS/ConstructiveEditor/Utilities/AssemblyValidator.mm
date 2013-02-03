//
//  AssemblyValidator.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "AssemblyValidator.h"

#import "ActionSheet.h"
#import "Assembly.h"
#import "AssemblyType.h"
#import "Detail.h"
#import "DetailType.h"
#import "NSManagedObjectContextExtension.h"

#import <vector>

struct SmallerAssembliesEnumerationCache
  {
  NSSet* smallerAssembliesCached;
  NSEnumerator* smallerAssembliesCachedEnumerator;
  BOOL enumeratingSmallerAssemblies;
  
  SmallerAssembliesEnumerationCache():
  smallerAssembliesCached(nil), smallerAssembliesCachedEnumerator(nil), enumeratingSmallerAssemblies(NO) {}
  };

@implementation AssemblyValidator

+ (Assembly*)rootAssemblyInContext:(NSManagedObjectContext*)managedObjectContext
  {
  Assembly* rootAssembly = nil;
  /*
   Fetch existing assemblies.
   Create a fetch request, add a sort descriptor, then execute the fetch.
   */
  NSFetchRequest *assembliesRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *assemblyEntity = [NSEntityDescription entityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
  [assembliesRequest setEntity:assemblyEntity];
  [assembliesRequest setPredicate:[NSPredicate predicateWithFormat:@"(assemblyToInstallTo = nil) AND (assemblyExtended = nil) AND (assemblyTransformed = nil) AND (assemblyRotated = nil)"]];
  
  // Execute the fetch -- create a mutable copy of the result.
  NSError *assembliesError = nil;
  NSArray* rootAssemblies = [[managedObjectContext executeFetchRequest:assembliesRequest error:&assembliesError] mutableCopy];
  if (rootAssemblies == nil)
    {
    NSLog(@"Error: %@", assembliesError.debugDescription);
    return nil;
    }

  if (1 == rootAssemblies.count)
    rootAssembly = [rootAssemblies objectAtIndex:0];
  else if (rootAssemblies.count > 1)
    NSLog(@"There is more then one root assembly in model: %@", rootAssemblies);
  else if (0 == rootAssemblies.count)
    {
    rootAssembly = (Assembly*)[NSEntityDescription insertNewObjectForEntityForName:@"Assembly" inManagedObjectContext:managedObjectContext];
    AssemblyType* assemblyType = (AssemblyType*)[NSEntityDescription insertNewObjectForEntityForName:@"AssemblyType" inManagedObjectContext:managedObjectContext];
    rootAssembly.type = assemblyType;
    rootAssembly.assemblyExtended = nil;
    rootAssembly.type.assemblyBase = nil;
    
    // Commit the change.
    [managedObjectContext saveAndHandleError];
    }
  rootAssemblies = nil;
  return rootAssembly;
  }

+ (BOOL)isAssemblyComplete:(Assembly*)assemblyToCheck withError:(NSError**)error
  {
  *error = nil;
    
  __block AssemblyType* currentAssemblyType = assemblyToCheck.type;
  
  //caching to speed up enumeration by the assemblies directly in a document
  __block std::vector<struct SmallerAssembliesEnumerationCache> cacheStack;
  __block std::vector<AssemblyType*> parentsStack;
  
  typedef enum
    {
    kLoopActionDoNothing = 0,
    kLoopActionContinue,
    kLoopActionBreak,
    } LoopAction;
    
  __block LoopAction (^levelUp)();
  
  __block LoopAction (^goToTheNextAssembly)() = [^()
    {
    struct SmallerAssembliesEnumerationCache& cache = cacheStack.back();
    if (cache.enumeratingSmallerAssemblies)
      {
      AssemblyType* assemblyType = ((Assembly*)cache.smallerAssembliesCachedEnumerator.nextObject).type;
      if (assemblyType)
        {
        cache.enumeratingSmallerAssemblies = YES;
        currentAssemblyType = assemblyType;
        return kLoopActionContinue;
        }
      else
        {
        cacheStack.pop_back();
        currentAssemblyType =  ((Assembly*)currentAssemblyType.assemblies.anyObject).assemblyToInstallTo;
        return kLoopActionContinue;
        }
      }
    else
      {
      AssemblyType* assemblyExtended = ((Assembly*)currentAssemblyType.assemblies.anyObject).assemblyExtended;
      if (assemblyExtended)//current assembly is the base one so let's try to go to the first smaller assembly if such ones exist or go to the extended assembly
        {
        NSSet* smallerAssemblies = assemblyExtended.assembliesInstalled;
        if (smallerAssemblies.count)
          {
          cache.smallerAssembliesCached = smallerAssemblies;
          cache.smallerAssembliesCachedEnumerator = cache.smallerAssembliesCached.objectEnumerator;
          AssemblyType* assemblyType = ((Assembly*)cache.smallerAssembliesCachedEnumerator.nextObject).type;
          if (assemblyType)
            {
            cache.enumeratingSmallerAssemblies = YES;
            currentAssemblyType = assemblyType;
            return kLoopActionContinue;
            }
          else
            {
            cacheStack.pop_back();
            currentAssemblyType = assemblyExtended;
            return kLoopActionContinue;
            }
          }
        }
      else
        return levelUp();
      }
    return kLoopActionDoNothing;
    } copy];
  
  levelUp = [^()
    {
    if (currentAssemblyType == assemblyToCheck.type)
      return kLoopActionBreak;
    AssemblyType* assemblyToInstallTo = ((Assembly*)currentAssemblyType.assemblies.anyObject).assemblyToInstallTo;
    if (assemblyToInstallTo)
      {
      parentsStack.pop_back();
      currentAssemblyType = assemblyToInstallTo;
      return kLoopActionContinue;
      }
    else
      {
      AssemblyType* assemblyRotated = ((Assembly*)currentAssemblyType.assemblies.anyObject).assemblyRotated;
      if (assemblyRotated)
        {
        parentsStack.pop_back();
        currentAssemblyType = assemblyRotated;
        return goToTheNextAssembly();
        }
      else
        {
        AssemblyType* assemblyTransformed = ((Assembly*)currentAssemblyType.assemblies.anyObject).assemblyTransformed;
        if (assemblyTransformed)
          {
          parentsStack.pop_back();
          currentAssemblyType = assemblyTransformed;
          return goToTheNextAssembly();
          }
        }
      }
    return kLoopActionDoNothing;
    } copy];
  
  do
    {
    BOOL isAssemblySplit = currentAssemblyType.detailsInstalled.count && !currentAssemblyType.assemblyBase;
    BOOL arePartsDetachedFromAssembly = nil != currentAssemblyType.assemblyBase;
    BOOL isAssemblyTransformed = nil != currentAssemblyType.assemblyBeforeTransformation;
    BOOL isAssemblyRotated = nil != currentAssemblyType.assemblyBeforeRotation;
    
    BOOL isAssemblyAlreadyChecked = !(0 == parentsStack.size() || currentAssemblyType != parentsStack.back());
    if (isAssemblyAlreadyChecked)
      {
      LoopAction loopAction = levelUp();
      if (loopAction == kLoopActionContinue)
        continue;
      else if (loopAction == kLoopActionBreak)
        break;
      }
    else
      {//do the check and go deeper if OK
      if (isAssemblySplit)
        {
        if (currentAssemblyType.detailsInstalled.count < 2)
          {
          *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeLessThenTwoDetailsInSplitAssembly userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"There are less then two details in a split assembly", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else if (isAssemblyTransformed || isAssemblyRotated)
          {
          *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else
          {
          BOOL allDetailsHaveConnectionPoint = YES;
          BOOL allDetailsHaveCompleteType = YES;
          Detail* problematicDetail = nil;
          for (Detail* detail in currentAssemblyType.detailsInstalled)
            {
            if (!detail.connectionPoint)
              {
              allDetailsHaveConnectionPoint = NO;
              problematicDetail = detail;
              break;
              }
            if (!detail.type)
              {
              allDetailsHaveCompleteType = NO;
              problematicDetail = detail;
              break;
              }
            }
          if (!allDetailsHaveConnectionPoint)
            {
            *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Connection point is not specified at least for one detail some assembly is split to", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
            return NO;
            }
          else if (!allDetailsHaveCompleteType)
            {
            *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"At least one detail some assembly is split to has no type selected", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
            return NO;
            }
          else//the assembly is split to details correctly
            {
            //go to the next assembly
            }
          }
        }
      else if (arePartsDetachedFromAssembly)
        if (!currentAssemblyType.detailsInstalled.count && !currentAssemblyType.assembliesInstalled.count)
          {
          *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeNoPartsDetachedFromAssembly userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"There are no parts detached from some assembly", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else if (isAssemblyTransformed || isAssemblyRotated)
          {
          *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else
          {
          BOOL allDetailsHaveConnectionPoint = YES;
          BOOL allDetailsHaveCompleteType = YES;
          Detail* problematicDetail = nil;
          for (Detail* detail in currentAssemblyType.detailsInstalled)
            {
            if (!detail.connectionPoint)
              {
              allDetailsHaveConnectionPoint = NO;
              problematicDetail = detail;
              break;
              }
            if (!detail.type)
              {
              allDetailsHaveCompleteType = NO;
              problematicDetail = detail;
              break;
              }
            }
          if (!allDetailsHaveConnectionPoint)
            {
            *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Connection point is not specified at least for one subdetail of some assembly", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
            return NO;
            }
          else if (!allDetailsHaveCompleteType)
            {
            *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"At least one subdetail of some assembly has no type selected", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
            return NO;
            }
          else
            {
            BOOL allSubassembliesHaveConnectionPoint = YES;
            Assembly* problematicSubassembly = nil;
            for (Assembly* subassembly in currentAssemblyType.assembliesInstalled)
              if (!subassembly.connectionPoint)
                {
                allSubassembliesHaveConnectionPoint = NO;
                problematicSubassembly = subassembly;
                break;
                }
            if (!allSubassembliesHaveConnectionPoint)
              {
              *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeSubassemblyHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Connection point is not specified at least for one subassembly of some assembly", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", problematicSubassembly, @"problematicSubassembly", nil]];
              return NO;
              }
            else//smaller parts are detached from the assembly correctly so let's go to the base assembly
              {
              parentsStack.push_back(currentAssemblyType);
              currentAssemblyType = currentAssemblyType.assemblyBase.type;
              struct SmallerAssembliesEnumerationCache cache;
              cacheStack.push_back(cache);
              continue;
              }
            }
          }
      else if (isAssemblyRotated)
        {
        if (isAssemblyTransformed || isAssemblySplit || arePartsDetachedFromAssembly)
          {
          *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else
          {
          parentsStack.push_back(currentAssemblyType);
          currentAssemblyType = currentAssemblyType.assemblyBeforeRotation.type;
          continue;
          }
        }
      else if (isAssemblyTransformed)
        {
        if (isAssemblyRotated || isAssemblySplit || arePartsDetachedFromAssembly)
          {
          *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Mutually exclusive properties of some assembly are set simultaneously", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else
          {
          parentsStack.push_back(currentAssemblyType);
          currentAssemblyType = currentAssemblyType.assemblyBeforeTransformation.type;
          continue;
          }
        }
      else
        {
        *error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kModelValidationErrorCodeAssemblyNotBrokenUp userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Some assembly hasn't been broken up yet", @"Model validation error message"), NSLocalizedDescriptionKey, currentAssemblyType, @"assemblyType", nil]];
        //don't return NO here!!!
        //let's continue checking the entire model for other types of errors as such situation is OK for exporting a model
        //we initialized an error so the method will return NO anyway
        //all the other error types have higher priority and will overwrite the error value
        }
        
      goToTheNextAssembly();
      }
      
    }
  while (currentAssemblyType != assemblyToCheck.type);//stop when we turn back to the assembly being checked
  return *error == nil;
  }

+ (void)showExportMenuForRootAssembly:(Assembly*)rootAssembly currentAssembly:(Assembly*)currentAssembly inView:(UIView *)view previewInstructionBlock:(PreviewInstructionBlock)previewInstructionBlock
  {
  //model is OK and can be exported if only one validation rule is broken: some assemblies are not broken up yet, all the other rules should be satisfied. For example if some assembly is split to 1 detail (less then 2) then the model cannot be expoted until the user removes the detail
  NSError* error = nil;
  BOOL isEntireModelValid = [self isAssemblyComplete:rootAssembly withError:&error];
  
  if (isEntireModelValid)
    {
    ActionSheet* actionSheet = [[ActionSheet alloc]
         initWithTitle: NSLocalizedString(@"Export instruction to:", @"Action sheet: title")
      clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
        {
        switch (buttonIndex)
          {
          case 0://PDF document
            {
            previewInstructionBlock(rootAssembly);
            break;
            }
          case 1://cancel
          default:
            break;
          }
        }
     cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
destructiveButtonTitle: nil
     otherButtonTitles: NSLocalizedString(@"PDF document", @"Action sheet: button"),
                        nil];
    [actionSheet showInView:view];
    }
  else
    {
    switch (error.code)
      {
      case kModelValidationErrorCodeAssemblyNotBrokenUp:
        {
        ActionSheet* actionSheet = [[ActionSheet alloc]
             initWithTitle: NSLocalizedString(@"Some assemblies are not broken up. Would you like to export instruction anyway to:", @"Action sheet: title")
          clickButtonBlock:^(ActionSheet* ActionSheet, NSInteger buttonIndex)
            {
            switch (buttonIndex)
              {
              case 0://PDF document
                {
                previewInstructionBlock(rootAssembly);
                break;
                }
              case 1://cancel
              default:
                break;
              }
            }
         cancelButtonTitle: NSLocalizedString(@"Cancel", @"Action sheet: button")
    destructiveButtonTitle: nil
         otherButtonTitles: NSLocalizedString(@"PDF document", @"Action sheet: button"),
                            nil];
        [actionSheet showInView:view];
        break;
        }
      case kModelValidationErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously:
      case kModelValidationErrorCodeLessThenTwoDetailsInSplitAssembly:
      case kModelValidationErrorCodeNoPartsDetachedFromAssembly:
      case kModelValidationErrorCodeDetailHasNoConnectionPoint:
      case kModelValidationErrorCodeSubassemblyHasNoConnectionPoint:
        {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Model is not valid.", @"Model validation error message") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil] show];
        break;
        }
      default:
        break;
      }
    }
  }

@end
