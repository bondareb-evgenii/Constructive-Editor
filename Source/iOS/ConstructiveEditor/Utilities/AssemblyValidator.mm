//
//  AssemblyValidator.m
//  ConstructiveEditor
//
//  Copyright (c) 2012 Openminded. All rights reserved.
//

#import "AssemblyValidator.h"
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

+ (BOOL)isAssemblyComplete:(Assembly*)assemblyToCheck withError:(NSError*)error
  {
  typedef enum
    {
    kErrorCodeOK = 0,
    kErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously,
    kErrorCodeLessThenTwoDetailsInSplitAssembly,
    kErrorCodeNoPartsDetachedFromAssembly,
    kErrorCodeAssemblyNotBrokenUp,
    kErrorCodeDetailHasNoConnectionPoint,
    kErrorCodeSubassemblyHasNoConnectionPoint,
    } ErrorCode;
    
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
          error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeLessThenTwoDetailsInSplitAssembly userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"There are less then two details in a split assembly", @"description", currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else if (isAssemblyTransformed || isAssemblyRotated)
          {
          error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Mutually exclusive properties of the assembly are set simultaneously", @"description", currentAssemblyType, @"assemblyType", nil]];
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
            error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Connection point is not specified at least for one detail the assembly is split to", @"description", currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
            return NO;
            }
          else if (!allDetailsHaveCompleteType)
            {
            error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"At least one detail the assembly is split to has no type selected", @"description", currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
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
          error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeNoPartsDetachedFromAssembly userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"There are no parts detached from assembly", @"description", currentAssemblyType, @"assemblyType", nil]];
          return NO;
          }
        else if (isAssemblyTransformed || isAssemblyRotated)
          {
          error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Mutually exclusive properties of the assembly are set simultaneously", @"description", currentAssemblyType, @"assemblyType", nil]];
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
            error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Connection point is not specified at least for one subdetail of the assembly", @"description", currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
            return NO;
            }
          else if (!allDetailsHaveCompleteType)
            {
            error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeDetailHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"At least one subdetail of the assembly has no type selected", @"description", currentAssemblyType, @"assemblyType", problematicDetail, @"problematicDetail", nil]];
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
              error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeSubassemblyHasNoConnectionPoint userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Connection point is not specified at least for one subassembly of the assembly", @"description", currentAssemblyType, @"assemblyType", problematicSubassembly, @"problematicSubassembly", nil]];
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
          error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Mutually exclusive properties of the assembly are set simultaneously", @"description", currentAssemblyType, @"assemblyType", nil]];
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
          error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeMutuallyExclusivePropertiesAreSetSimultaneously userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Mutually exclusive properties of the assembly are set simultaneously", @"description", currentAssemblyType, @"assemblyType", nil]];
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
        error = [NSError errorWithDomain:@"Assembly description is incomplete" code:kErrorCodeAssemblyNotBrokenUp userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"The assembly hasn't been broken up yet", @"description", currentAssemblyType, @"assemblyType", nil]];
        return NO;
        }
        
      goToTheNextAssembly();
      }
      
    }
  while (currentAssemblyType != assemblyToCheck.type);//stop when we turn back to the assembly being checked
  return YES;
  }

@end
